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

# store base urls in the '.state' internal environment (created in insee_auth.R)
.state$sirene_url <- "https://api.insee.fr/entreprises/sirene/V3"
.state$nomenclatures_url <- "https://api.insee.fr/metadonnees/nomenclatures/v1"
# nocov end
