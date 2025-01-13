#' Update Packages
#'
#' Updates packages from source with binary fallback
#' @param packages Character vector of package names. If NULL, updates all packages
#' @return Named list of update results
#' @importFrom utils install.packages packageVersion available.packages installed.packages txtProgressBar setTxtProgressBar update.packages
#' @export
#' @importFrom crayon green red yellow blue bold
updatePackages <- function(packages = NULL, parallel = TRUE) {
    if (!requireNamespace("crayon", quietly = TRUE)) {
        install.packages("crayon", quiet = TRUE)
    }
    library(crayon)

    if (is.null(packages)) {
        packages <- rownames(installed.packages())
    }

    if (!getOption("updateRpkg.debug", FALSE)) {
        cat(blue$bold("\n📦 Package Update Process Started\n"))
        cat(blue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"))
    }

    results <- list()
    if (parallel && requireNamespace("parallel", quietly = TRUE)) {
        num_cores <- min(parallel::detectCores() - 1, length(packages), 8)  # Cap at 8 cores
        cl <- parallel::makeCluster(num_cores)
        parallel::clusterExport(cl, c("checkPackageVersion"))
        parallel::clusterEvalQ(cl, {
            options(repos = c(CRAN = "https://cloud.r-project.org"))
        })
        on.exit(parallel::stopCluster(cl))

        # Split packages into batches for better memory management
        batch_size <- ceiling(length(packages) / num_cores)
        pkg_batches <- split(packages, ceiling(seq_along(packages) / batch_size))

        pb <- txtProgressBar(min = 0, max = length(packages), style = 3)
        results <- unlist(parallel::parLapply(cl, pkg_batches, function(pkg_batch) {
            batch_results <- list()
            for (pkg in pkg_batch) {
                version_info <- checkPackageVersion(pkg)
                if (!version_info$needs_update) {
                    if(getOption("updateRpkg.debug", FALSE)) cat(paste0("Package ", pkg, " is up to date.\n"))
                    batch_results[[pkg]] <- "up to date"
                    next
                }

                if(getOption("updateRpkg.debug", FALSE)) cat(blue(paste0("→ Processing ", bold(pkg), "...\n")))
                result <- tryCatch({
                    install.packages(pkg, type = "source", quiet = TRUE)
                    if(getOption("updateRpkg.debug", FALSE)) cat(green(paste0("✓ ", bold(pkg), " ", blue("updated successfully from source"), "\n")))
                    if(getOption("updateRpkg.debug", FALSE)) cat(blue("  → Version: ", packageVersion(pkg), "\n"))
                    batch_results[[pkg]] <- "updated from source"
                    }, error = function(e) {
                        if(getOption("updateRpkg.debug", FALSE)) cat(yellow(paste0("! ", bold(pkg), " source build failed, trying binary\n")))
                        tryCatch({
                            install.packages(pkg, type = "binary", quiet = TRUE)
                            if(getOption("updateRpkg.debug", FALSE)) cat(green(paste0("✓ ", bold(pkg), " ", blue("updated successfully from binary"), "\n")))
                            if(getOption("updateRpkg.debug", FALSE)) cat(blue("  → Version: ", packageVersion(pkg), "\n"))
                            batch_results[[pkg]] <- "updated from binary"
                        }, error = function(e) {
                            if(getOption("updateRpkg.debug", FALSE)) cat(red(paste0("✗ ", bold(pkg), " update failed\n")))
                            if(getOption("updateRpkg.debug", FALSE)) cat(red("  → Error: ", conditionMessage(e), "\n"))
                            batch_results[[pkg]] <- "update failed"
                        })
                    }) 
            }
            batch_results
        }), recursive = FALSE)
        close(pb)
    } else {
        pb <- txtProgressBar(min = 0, max = length(packages), style = 3)
        for(pkg in 1:length(packages)) {
            version_info <- checkPackageVersion(packages[pkg])
            if (!version_info$needs_update) {
                if(getOption("updateRpkg.debug", FALSE)) cat(paste0("Package ", packages[pkg], " is up to date.\n"))
                results[[packages[pkg]]] <- "up to date"
                setTxtProgressBar(pb, pkg)
                next
            }

            if(getOption("updateRpkg.debug", FALSE)) cat(blue(paste0("→ Processing ", bold(packages[pkg]), "...\n")))
            tryCatch({
                install.packages(packages[pkg], type = "source")
                if(getOption("updateRpkg.debug", FALSE)) cat(green(paste0("✓ ", bold(packages[pkg]), " ", blue("updated successfully from source"), "\n")))
                if(getOption("updateRpkg.debug", FALSE)) cat(blue("  → Version: ", packageVersion(packages[pkg]), "\n"))
                results[[packages[pkg]]] <- "updated from source"
            }, error = function(e) {
                message(sprintf("Source installation failed for %s, trying binary...", packages[pkg]))
                tryCatch({
                    install.packages(packages[pkg], type = "binary")
                    if(getOption("updateRpkg.debug", FALSE)) cat(green(paste0("✓ ", bold(packages[pkg]), " ", blue("updated successfully from binary"), "\n")))
                    if(getOption("updateRpkg.debug", FALSE)) cat(blue("  → Version: ", packageVersion(packages[pkg]), "\n"))
                    results[[packages[pkg]]] <- "updated from binary"
                }, error = function(e) {
                    if(getOption("updateRpkg.debug", FALSE)) cat(red(paste0("✗ ", bold(packages[pkg]), " update failed\n")))
                    if(getOption("updateRpkg.debug", FALSE)) cat(red("  → Error: ", conditionMessage(e), "\n"))
                    results[[packages[pkg]]] <- "update failed"
                })
            })
            setTxtProgressBar(pb, pkg)
        }
        close(pb)
    }
    return(results)
}

#' Rebuild Packages
#'
#' Rebuilds packages that were built with a different R version or all packages
#' @param rebuild_all Logical. If TRUE, rebuilds all packages. If FALSE, only rebuilds packages built with different R version
#' @return Named list of rebuild results
#' @export
rebuildPackages <- function(rebuild_all = FALSE) {
    if (!requireNamespace("crayon", quietly = TRUE)) {
        install.packages("crayon", quiet = TRUE)
    }

    installed <- installed.packages()
    if (rebuild_all) {
        outdated <- installed
    } else {
        outdated <- installed[installed[, "Built"] != R.version$version.string, ]
    }

    if (!getOption("updateRpkg.debug", FALSE)) {
        cat(blue$bold("\n🔄 Package Rebuild Process Started\n"))
        cat(blue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"))
    }

    if (nrow(outdated) == 0) {
        message("No packages need rebuilding")
        return(list())
    }

    results <- list()
    pb <- txtProgressBar(min = 0, max = nrow(outdated), style = 3)

    for(i in 1:nrow(outdated)) {
        pkg <- rownames(outdated)[i]
        if(getOption("updateRpkg.debug", FALSE)) cat(blue(paste0("→ Rebuilding ", bold(pkg), "...\n")))
        utils::capture.output({
            tryCatch({
                install.packages(pkg, type = "source", quiet = TRUE)
                if(getOption("updateRpkg.debug", FALSE)) cat(green(paste0("✓ ", bold(pkg), " ", blue("rebuilt successfully from source"), "\n")))
                if(getOption("updateRpkg.debug", FALSE)) cat(blue("  → Version: ", packageVersion(pkg), "\n"))
                results[[pkg]] <- "rebuilt from source"
            }, error = function(e) {
                if(getOption("updateRpkg.debug", FALSE)) cat(yellow(paste0("! ", bold(pkg), " source rebuild failed, trying binary\n")))
                tryCatch({
                    install.packages(pkg, type = "binary", quiet = TRUE)
                    if(getOption("updateRpkg.debug", FALSE)) cat(green(paste0("✓ ", bold(pkg), " ", blue("rebuilt successfully from binary"), "\n")))
                    if(getOption("updateRpkg.debug", FALSE)) cat(blue("  → Version: ", packageVersion(pkg), "\n"))
                    results[[pkg]] <- "rebuilt from binary"
                }, error = function(e) {
                    if(getOption("updateRpkg.debug", FALSE)) cat(red(paste0("✗ ", bold(pkg), " rebuild failed\n")))
                    if(getOption("updateRpkg.debug", FALSE)) cat(red("  → Error: ", conditionMessage(e), "\n"))
                    results[[pkg]] <- "rebuild failed"
                })
            })
        }, type = "message")
        setTxtProgressBar(pb, i)
    }
    close(pb)
    return(results)
}