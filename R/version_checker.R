
#' Check Package Version
#'
#' Compares installed and available versions of a package
#' @param pkg_name Character string of package name
#' @return List with installed and available versions
#' @importFrom utils available.packages packageVersion installed.packages
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


#' Check Package Update Version
#'
#' Checks if there's a newer version of the package on GitHub
#' @return List with local and remote versions and update status
#' @importFrom utils download.file packageVersion
#' @export
checkUpdaterVersion <- function() {
    temp_file <- tempfile()
    tryCatch({
        download.file("https://raw.githubusercontent.com/b1azk0/SourcePackageUpgrader/main/DESCRIPTION", temp_file, quiet = TRUE)
        desc_lines <- readLines(temp_file)
        remote_version <- gsub("Version:\\s*", "", grep("^Version:", desc_lines, value = TRUE)[1])
        local_version <- as.character(utils::packageVersion("SourcePackageUpgrader"))
        
        list(
            local_version = local_version,
            remote_version = remote_version,
            needs_update = package_version(local_version) < package_version(remote_version)
        )
    }, error = function(e) {
        list(
            local_version = as.character(utils::packageVersion("SourcePackageUpgrader")),
            remote_version = NA,
            needs_update = FALSE
        )
    }, finally = {
        if (file.exists(temp_file)) unlink(temp_file)
    })
}

}
