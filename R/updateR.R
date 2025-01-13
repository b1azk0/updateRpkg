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

    # Generate summary report
    summary_report <- list(
        timestamp = Sys.time(),
        updates = list(
            total = length(update_results),
            successful = sum(grepl("updated|up to date", unlist(update_results))),
            failed = sum(grepl("failed", unlist(update_results)))
        ),
        rebuilds = list(
            total = length(rebuild_results),
            successful = sum(grepl("rebuilt", unlist(rebuild_results))),
            failed = sum(grepl("failed", unlist(rebuild_results)))
        ),
        details = list(
            updates = update_results,
            rebuilds = rebuild_results
        ),
        warnings = warnings(),
        errors = geterrmessage()
    )

    # Print formatted summary
    cat("\n=== Package Update Summary ===\n")
    cat(sprintf("Time: %s\n\n", format(summary_report$timestamp)))
    
    cat("Updates:\n")
    cat(sprintf("- Total packages processed: %d\n", summary_report$updates$total))
    cat(sprintf("- Successfully updated/current: %d\n", summary_report$updates$successful))
    cat(sprintf("- Failed updates: %d\n\n", summary_report$updates$failed))
    
    cat("Rebuilds:\n")
    cat(sprintf("- Total packages processed: %d\n", summary_report$rebuilds$total))
    cat(sprintf("- Successfully rebuilt: %d\n", summary_report$rebuilds$successful))
    cat(sprintf("- Failed rebuilds: %d\n\n", summary_report$rebuilds$failed))
    
    if (summary_report$updates$failed > 0 || summary_report$rebuilds$failed > 0) {
        cat("Failed Operations:\n")
        failed_updates <- names(which(grepl("failed", unlist(update_results))))
        failed_rebuilds <- names(which(grepl("failed", unlist(rebuild_results))))
        
        if (length(failed_updates) > 0) {
            cat("- Update failures:", paste(failed_updates, collapse=", "), "\n")
        }
        if (length(failed_rebuilds) > 0) {
            cat("- Rebuild failures:", paste(failed_rebuilds, collapse=", "), "\n")
        }
    }
    
    if (length(summary_report$warnings) > 0 || nchar(summary_report$errors) > 0) {
        cat("\nWarnings and Errors:\n")
        if (length(summary_report$warnings) > 0) {
            cat("Warnings:\n")
            print(summary_report$warnings)
        }
        if (nchar(summary_report$errors) > 0) {
            cat("Errors:\n")
            cat(summary_report$errors)
        }
    }
    
    invisible(summary_report)
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