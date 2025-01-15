#' Update Packages
#'
#' Updates packages from source with binary fallback
#' @param packages Character vector of package names. If NULL, updates all packages
#' @return Named list of update results
#' @importFrom utils install.packages packageVersion available.packages installed.packages txtProgressBar setTxtProgressBar update.packages
#' @export
updatePackages <- function(packages = NULL, parallel = TRUE) {
    if (is.null(packages)) {
        packages <- rownames(installed.packages())
    }

    # Track already rebuilt packages
    rebuilt_pkgs <- new.env(hash = TRUE)

    results <- list()
    if (parallel && requireNamespace("parallel", quietly = TRUE)) {
        num_cores <- min(parallel::detectCores() - 1, length(packages), 8)
        cl <- parallel::makeCluster(num_cores)
        parallel::clusterExport(cl, c("checkPackageVersion", "rebuilt_pkgs"))
        on.exit(parallel::stopCluster(cl))

        batch_size <- ceiling(length(packages) / num_cores)
        pkg_batches <- split(packages, ceiling(seq_along(packages) / batch_size))

        pb <- txtProgressBar(min = 0, max = length(packages), style = 3)
        results <- unlist(parallel::parLapply(cl, pkg_batches, function(pkg_batch) {
            batch_results <- list()
            for (pkg in pkg_batch) {
                # Skip if already rebuilt with current R version
                if (!is.null(rebuilt_pkgs[[pkg]])) {
                    batch_results[[pkg]] <- "already rebuilt"
                    next
                }

                version_info <- checkPackageVersion(pkg)
                if (!version_info$needs_update) {
                    batch_results[[pkg]] <- "up to date"
                    next
                }

                tryCatch({
                    install.packages(pkg, type = "source", quiet = TRUE)
                    rebuilt_pkgs[[pkg]] <- TRUE
                    batch_results[[pkg]] <- "updated from source"
                }, error = function(e) {
                    message(sprintf("Source installation failed for %s, trying binary...", pkg))
                    tryCatch({
                        install.packages(pkg, type = "binary", quiet = TRUE)
                        rebuilt_pkgs[[pkg]] <- TRUE
                        batch_results[[pkg]] <- "updated from binary"
                    }, error = function(e) {
                        batch_results[[pkg]] <- sprintf("update failed: %s", conditionMessage(e))
                    })
                })
            }
            batch_results
        }), recursive = FALSE)
        close(pb)
    } else {
        pb <- txtProgressBar(min = 0, max = length(packages), style = 3)

        for(pkg_idx in 1:length(packages)) {
            pkg <- packages[pkg_idx]

            # Skip if already rebuilt with current R version
            if (!is.null(rebuilt_pkgs[[pkg]])) {
                results[[pkg]] <- "already rebuilt"
                setTxtProgressBar(pb, pkg_idx)
                next
            }

            version_info <- checkPackageVersion(pkg)
            if (!version_info$needs_update) {
                results[[pkg]] <- "up to date"
                setTxtProgressBar(pb, pkg_idx)
                next
            }

            tryCatch({
                install.packages(pkg, type = "source", quiet = TRUE)
                rebuilt_pkgs[[pkg]] <- TRUE
                results[[pkg]] <- "updated from source"
            }, error = function(e) {
                message(sprintf("Source installation failed for %s, trying binary...", pkg))
                tryCatch({
                    install.packages(pkg, type = "binary", quiet = TRUE)
                    rebuilt_pkgs[[pkg]] <- TRUE
                    results[[pkg]] <- "updated from binary"
                }, error = function(e) {
                    results[[pkg]] <- sprintf("update failed: %s", conditionMessage(e))
                })
            })
            setTxtProgressBar(pb, pkg_idx)
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
    installed <- installed.packages()
    if (rebuild_all) {
        outdated <- installed
    } else {
        outdated <- installed[installed[, "Built"] != R.version$version.string, ]
    }

    if (nrow(outdated) == 0) {
        message("No packages need rebuilding")
        return(list())
    }

    results <- list()
    pb <- txtProgressBar(min = 0, max = nrow(outdated), style = 3)

    for(i in 1:nrow(outdated)) {
        pkg <- rownames(outdated)[i]
        tryCatch({
            install.packages(pkg, type = "source")
            results[[pkg]] <- "rebuilt from source"
        }, error = function(e) {
            message(sprintf("Source rebuild failed for %s, trying binary...", pkg))
            tryCatch({
                install.packages(pkg, type = "binary")
                results[[pkg]] <- "rebuilt from binary"
            }, error = function(e) {
                results[[pkg]] <- "rebuild failed"
            })
        })
        setTxtProgressBar(pb, i)
    }
    close(pb)
    return(results)
}