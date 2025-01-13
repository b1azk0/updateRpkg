#' Update and Rebuild R Packages
#'
#' Updates all installed R packages and rebuilds if necessary
#' @importFrom utils installed.packages update.packages install.packages packageVersion available.packages
#' @export
updateRpackages <- function() {
    # Set CRAN mirror directly
    options(repos = c(CRAN = "https://cloud.r-project.org"))

    # Ensure parallel backend is properly initialized
    if (requireNamespace("parallel", quietly = TRUE)) {
        options(mc.cores = parallel::detectCores() - 1)
    }

    # Check for updates to the updater itself
    updater_status <- checkUpdaterVersion()
    if (!is.na(updater_status$remote_version) && updater_status$needs_update) {
        message(sprintf("\nNewer version of SourcePackageUpgrader available: %s (current: %s)\n", 
                       updater_status$remote_version, updater_status$local_version))
    }

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

    if (length(summary_report$warnings) > 0 ) {
        cat("\nWarnings:\n")
        print(summary_report$warnings)
    }
    if (nchar(summary_report$errors) > 0) {
        cat("\nErrors:\n")
        cat(summary_report$errors)
    }


    invisible(summary_report)
}


#' Helper function to rebuild outdated packages
#' @importFrom utils install.packages
rebuildPackages <- function() {
    if (!requireNamespace("crayon", quietly = TRUE)) {
        install.packages("crayon", quiet = TRUE)
    }
    library(crayon)

    installed_packages <- installed.packages()
    outdated_builds <- installed_packages[installed_packages[, "Built"] != R.version$version.string, "Package"]

    cat(blue$bold("\n🔄 Package Rebuild Process Started\n"))
    cat(blue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"))

    results <- list()
    if (length(outdated_builds) > 0) {
        pb <- txtProgressBar(min = 0, max = length(outdated_builds), style = 3)

        for (i in seq_along(outdated_builds)) {
            pkg <- outdated_builds[i]
            cat(blue(paste0("→ Rebuilding ", bold(pkg), "...\n")))

            tryCatch({
                install.packages(pkg, type = "source", quiet = TRUE)
                cat(green(paste0("✓ ", bold(pkg), " ", blue("rebuilt successfully from source"), "\n")))
                results[[pkg]] <- "Successfully rebuilt from source"
            }, error = function(e) {
                cat(yellow(paste0("! ", bold(pkg), " source build failed, trying binary\n")))
                tryCatch({
                    install.packages(pkg, type = "binary", quiet = TRUE)
                    cat(green(paste0("✓ ", bold(pkg), " ", blue("rebuilt successfully from binary"), "\n")))
                    results[[pkg]] <- "Successfully rebuilt from binary"
                }, error = function(e) {
                    cat(red(paste0("✗ ", bold(pkg), " rebuild failed\n")))
                    cat(red("  → Error: ", conditionMessage(e), "\n"))
                    results[[pkg]] <- paste("Failed to rebuild:", e$message)
                })
            })
            setTxtProgressBar(pb, i)
        }
        close(pb)
    } else {
        cat(green("No packages need rebuilding\n"))
    }
    results
}