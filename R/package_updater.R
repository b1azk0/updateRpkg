#' Update Packages
#'
#' Updates packages from source with binary fallback
#' @param packages Character vector of package names. If NULL, updates all packages
#' @return Named list of update results
#' @export
updatePackages <- function(packages = NULL) {
    if (is.null(packages)) {
        packages <- rownames(installed.packages())
    }

    results <- list()
    pb <- txtProgressBar(min = 0, max = length(packages), style = 3) # Initialize progress bar

    for(pkg in packages) {
        version_info <- checkPackageVersion(pkg)
        if (!version_info$needs_update) {
            results[[pkg]] <- "up to date"
            pb$tick() # Increment progress bar
            next
        }

        tryCatch({
            install.packages(pkg, type = "source")
            results[[pkg]] <- "updated from source"
        }, error = function(e) {
            message(sprintf("Source installation failed for %s, trying binary...", pkg))
            tryCatch({
                install.packages(pkg, type = "binary")
                results[[pkg]] <- "updated from binary"
            }, error = function(e) {
                results[[pkg]] <- "update failed"
            })
        })
        pb$tick() # Increment progress bar
    }
    close(pb) # Close progress bar
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
    pb <- txtProgressBar(min = 0, max = nrow(outdated), style = 3) # Initialize progress bar

    for(pkg in rownames(outdated)) {
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
        pb$tick() # Increment progress bar
    }
    close(pb) # Close progress bar
    return(results)
}