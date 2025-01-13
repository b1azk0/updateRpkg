
#' Backup Installed Packages
#'
#' Creates a backup of installed packages and their versions
#' @param file_path Character string for backup file location
#' @return Invisible NULL
#' @importFrom utils installed.packages write.csv
#' @export
backupPackages <- function(file_path = "package_backup.csv") {
    installed <- installed.packages()
    pkg_data <- data.frame(
        Package = rownames(installed),
        Version = installed[, "Version"],
        Built = installed[, "Built"]
    )
    write.csv(pkg_data, file = file_path, row.names = FALSE)
    invisible(NULL)
}

#' Restore Packages from Backup
#'
#' Restores packages from a backup file
#' @param file_path Character string for backup file location
#' @return List of restoration results
#' @importFrom utils read.csv install.packages
#' @export
restorePackages <- function(file_path = "package_backup.csv") {
    if (!file.exists(file_path)) {
        stop("Backup file not found")
    }
    pkg_data <- read.csv(file_path)
    updatePackages(pkg_data$Package)
}
