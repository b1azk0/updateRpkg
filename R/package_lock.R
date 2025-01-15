
#' Lock Package Versions
#'
#' Creates or updates package version lock file
#' @param packages Character vector of package names
#' @return Invisible NULL
#' @export
lockPackageVersions <- function(packages = NULL) {
    if (is.null(packages)) {
        packages <- rownames(installed.packages())
    }
    
    lock_data <- list()
    for (pkg in packages) {
        lock_data[[pkg]] <- list(
            version = as.character(packageVersion(pkg)),
            dependencies = as.list(packageDescription(pkg)$Depends),
            built = installed.packages()[pkg, "Built"]
        )
    }
    
    saveRDS(lock_data, "package.lock")
    invisible(NULL)
}

#' Check Lock File
#'
#' Verifies installed packages against lock file
#' @return List of package version mismatches
#' @export
checkLockFile <- function() {
    if (!file.exists("package.lock")) {
        stop("No lock file found")
    }
    
    lock_data <- readRDS("package.lock")
    mismatches <- list()
    
    for (pkg in names(lock_data)) {
        if (packageVersion(pkg) != lock_data[[pkg]]$version) {
            mismatches[[pkg]] <- list(
                locked = lock_data[[pkg]]$version,
                current = as.character(packageVersion(pkg))
            )
        }
    }
    
    return(mismatches)
}
