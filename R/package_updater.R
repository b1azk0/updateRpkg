
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
