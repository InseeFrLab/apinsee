# nocov start
.onLoad <- function(libname, pkgname) {
  op <- options()
  op.apinsee <- list(
    apinsee.httr_oauth_cache = TRUE,
    apinsee.url = "https://api.insee.fr/"
  )
  toset <- !(names(op.apinsee) %in% names(op))
  if (any(toset)) options(op.apinsee[toset])

  httr::set_config(httr::user_agent("https://github.com/InseeFrLab/apinsee"))

  invisible()
}
# nocov end
