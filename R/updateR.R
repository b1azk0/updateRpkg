#' Update and Rebuild R Packages
#'
#' Updates all installed R packages and rebuilds if necessary
#' @importFrom utils installed.packages update.packages install.packages packageVersion available.packages
#' @export
updateRpackages <- function() {
    options(repos = c(CRAN = "https://cloud.r-project.org"))

    message("Updating packages...")
    update_results <- updatePackages()

    message("Checking for packages that need rebuilding...")
    rebuild_results <- rebuildPackages()

    # Summary
    message("\nUpdate Summary:")
    for (pkg in names(update_results)) {
        message(sprintf("%s: %s", pkg, update_results[[pkg]]))
    }

    message("\nRebuild Summary:")
    if (length(rebuild_results) > 0) {
        for (pkg in names(rebuild_results)) {
            message(sprintf("%s: %s", pkg, rebuild_results[[pkg]]))
        }
    } else {
        message("No packages needed rebuilding")
    }
}


#' Helper function to update packages
#' @importFrom utils installed.packages update.packages
updatePackages <- function(packages = NULL) {
  if (is.null(packages)) {
    installed_packages <- installed.packages()
    packages <- installed_packages[, "Package"]
  }
  update_results <- update.packages(ask = FALSE, checkBuilt = TRUE, type = "source", oldPkgs = installed_packages[, "Package"])
  
  results <- list()
  for(i in 1:length(update_results)){
    pkg <- names(update_results)[i]
    if(is.na(update_results[[i]])){
      results[[pkg]] <- "Already up to date"
    } else if (update_results[[i]] == "OK"){
      results[[pkg]] <- "Successfully updated"
    } else {
      results[[pkg]] <- paste("Update failed:", update_results[[i]])
    }
  }
  results
}


#' Helper function to rebuild outdated packages
#' @importFrom utils install.packages
rebuildPackages <- function() {
    installed_packages <- installed.packages()
    outdated_builds <- installed_packages[installed_packages[, "Built"] != R.version$version.string, "Package"]
    
    results <- list()
    if (length(outdated_builds) > 0) {
        for (pkg in outdated_builds) {
            tryCatch({
                install.packages(pkg, type = "source")
                results[[pkg]] <- "Successfully rebuilt from source"
            }, error = function(e) {
                message(sprintf("Failed to build %s from source. Retrying with binaries...", pkg))
                tryCatch({
                    install.packages(pkg, type = "binary")
                    results[[pkg]] <- "Successfully rebuilt from binary"
                }, error = function(e) {
                    results[[pkg]] <- paste("Failed to rebuild:", e$message)
                })
            })
        }
    }
    results
}