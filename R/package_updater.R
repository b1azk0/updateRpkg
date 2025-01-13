
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

    results <- list()
    if (parallel && requireNamespace("parallel", quietly = TRUE)) {
        num_cores <- parallel::detectCores() - 1
        cl <- parallel::makeCluster(num_cores)
        on.exit(parallel::stopCluster(cl))
        
        pb <- txtProgressBar(min = 0, max = length(packages), style = 3)
        results <- parallel::parLapply(cl, packages, function(pkg) {
            tryCatch({
                install.packages(pkg, type = "source")
                return("updated from source")
            }, error = function(e) {
                message(sprintf("Source installation failed for %s, trying binary...", pkg))
                tryCatch({
                    install.packages(pkg, type = "binary")
                    return("updated from binary")
                }, error = function(e) {
                    return("update failed")
                })
            })
        })
        names(results) <- packages
    } else {
        pb <- txtProgressBar(min = 0, max = length(packages), style = 3)

    for(pkg in 1:length(packages)) {
        version_info <- checkPackageVersion(packages[pkg])
        if (!version_info$needs_update) {
            results[[packages[pkg]]] <- "up to date"
            setTxtProgressBar(pb, pkg)
            next
        }

        tryCatch({
            install.packages(packages[pkg], type = "source")
            results[[packages[pkg]]] <- "updated from source"
        }, error = function(e) {
            message(sprintf("Source installation failed for %s, trying binary...", packages[pkg]))
            tryCatch({
                install.packages(packages[pkg], type = "binary")
                results[[packages[pkg]]] <- "updated from binary"
            }, error = function(e) {
                results[[packages[pkg]]] <- "update failed"
            })
        })
        setTxtProgressBar(pb, pkg)
    }
    close(pb)
    return(results)
}

#' Rebuild Packages
#'
#' Rebuilds packages that were built with a different R version
#' @return Named list of rebuild results
#' @export
rebuildPackages <- function() {
    installed <- installed.packages()
    outdated <- installed[installed[, "Built"] != R.version$version.string, ]

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
