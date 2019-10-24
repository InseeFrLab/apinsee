# nocov start
.onLoad <- function(libname, pkgname) {

  op <- options()
  op.apinsee <- list(
    httr_oauth_cache = NA
  )
  toset <- !(names(op.apinsee) %in% names(op))
  if(any(toset)) options(op.apinsee[toset])

  httr::set_config(httr::user_agent("https://github.com/RLesur/apinsee"))

  invisible()

}
# nocov end
