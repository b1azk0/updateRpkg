#' Update and Rebuild R Packages
#'
#' Updates all installed R packages from source, rebuilds outdated ones, and retries using binaries if necessary.
#' @importFrom utils installed.packages update.packages install.packages
#' @export
updateRpackages <- function() {
    options(repos = c(CRAN = "https://cloud.r-project.org"))
    
    # Retrieve installed packages
    message("Retrieving installed packages...")
    installed_packages <- installed.packages()
    outdated_builds <- installed_packages[installed_packages[, "Built"] != R.version$version.string, "Package"]
    
    # Track success and failure
    success_updates <- character()
    failed_updates <- character()
    
    # Update packages
    message("Updating all packages from source...")
    update.packages(ask = FALSE, checkBuilt = TRUE, type = "source")
    
    # Rebuild outdated packages
    if (length(outdated_builds) > 0) {
        message("Rebuilding outdated packages...")
        for (pkg in outdated_builds) {
            tryCatch({
                install.packages(pkg, type = "source")
                success_updates <- c(success_updates, pkg)
            }, error = function(e) {
                message(sprintf("Failed to build %s from source. Retrying with binaries...", pkg))
                tryCatch({
                    install.packages(pkg, type = "binary")
                    success_updates <- c(success_updates, pkg)
                }, error = function(e) {
                    failed_updates <- c(failed_updates, pkg)
                })
            })
        }
    }
    
    # Summary
    if (length(success_updates) > 0) {
        message("Successfully updated packages: ", paste(success_updates, collapse = ", "))
    } else {
        message("No packages were successfully updated.")
    }
    
    if (length(failed_updates) > 0) {
        message("Packages that failed to update: ", paste(failed_updates, collapse = ", "))
    } else {
        message("All packages were updated successfully.")
    }
}
