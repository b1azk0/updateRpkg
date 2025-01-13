#' Update and Rebuild R Packages
#'
#' Updates all installed R packages from source, rebuilds outdated ones, and retries using binaries if necessary.
#' @importFrom utils installed.packages update.packages install.packages packageVersion available.packages
#' @export

#' Check Package Version
#'
#' Compares installed and available versions of a package
#' @param pkg_name Character string of package name
#' @return List with installed and available versions
#' @export
checkPackageVersion <- function(pkg_name) {
    available <- available.packages()
    installed_version <- packageVersion(pkg_name)
    available_version <- available[pkg_name, "Version"]
    
    list(
        package = pkg_name,
        installed = as.character(installed_version),
        available = available_version,
        needs_update = installed_version < available_version
    )
}

#' Update Specific Packages
#'
#' Updates specified packages from source with binary fallback
#' @param packages Character vector of package names
#' @return Named list of update results
#' @export
updateSpecificPackages <- function(packages) {
    results <- list()
    
    for(pkg in packages) {
        tryCatch({
            install.packages(pkg, type = "source")
            results[[pkg]] <- "success"
        }, error = function(e) {
            tryCatch({
                install.packages(pkg, type = "binary")
                results[[pkg]] <- "success (binary)"
            }, error = function(e) {
                results[[pkg]] <- "failed"
            })
        })
    }
    return(results)
}
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
