
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
}
