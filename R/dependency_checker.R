
#' Check Package Dependencies
#'
#' Validates package dependencies and their versions
#' @param pkg_name Character string of package name
#' @return List with dependency status
#' @importFrom utils available.packages packageVersion installed.packages
#' @export
checkDependencies <- function(pkg_name) {
    pkg_desc <- packageDescription(pkg_name)
    if (is.null(pkg_desc)) {
        return(list(status = "error", message = "Package not found"))
    }
    
    deps <- pkg_desc$Depends
    if (!is.null(deps)) {
        deps <- unlist(strsplit(deps, ","))
        deps <- gsub("\\s+", "", deps)
        deps <- deps[deps != "R"]
        
        dep_status <- lapply(deps, function(dep) {
            tryCatch({
                ver <- packageVersion(dep)
                list(status = "installed", version = as.character(ver))
            }, error = function(e) {
                list(status = "missing")
            })
        })
        names(dep_status) <- deps
        return(list(status = "success", dependencies = dep_status))
    }
    return(list(status = "success", dependencies = list()))
}
