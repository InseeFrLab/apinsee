#' Addresses of the Insee APIs
#'
#' Cette fonction renvoie les adresses des API de l'Insee.
#'
#' @param api Un vecteur de chaînes de caractères dont chaque élément comprend
#'   le nom d'une API. La correspondance partielle est acceptée.
#' @inheritParams insee_endpoint
#' @inheritSection insee_endpoint Utilisation interne à l'Insee
#'
#' @return Un vecteur de chaînes de caractères comprenant les adresses des API
#'   de l'Insee.
#' @keywords internal
#' @export
#'
#' @examples
#' insee_scopes()
#' insee_scopes("Sirene")
#' insee_scopes("Nomenclatures")
#' insee_scopes(c("Sirene", "Nomenclatures", "DonneesLocales", "BDM"))
insee_scopes <- function(api = c("Sirene - V3",
                                 "Nomenclatures - v1",
                                 "DonneesLocales - V0.1",
                                 "BDM - V1"),
                         insee_url = getOption("apinsee.url")) {
  api <- match.arg(api, several.ok = TRUE)

  paths <- list(
    `Nomenclatures - v1` = list(
      c("metadonnees", "nomenclatures", "v1"),
      c("metadonnees", "nomenclatures")
    ),
    `Sirene - V3` = list(
      c("entreprises", "sirene", "V3"),
      c("entreprises", "sirene")
    ),
    `DonneesLocales - V0.1` = list(
      c("donnees-locales", "V0.1")
    ),
    `BDM - V1` = list(
      c("series", "BDM", "V1"),
      c("series", "BDM")
    )
  )

  modify_insee_url <- function(path) {
    vapply(path,
           function(x) httr::modify_url(url = insee_url, path = x),
           character(1))
  }

  urls <- lapply(paths, modify_insee_url)

  unlist(urls[api], use.names = FALSE)
}
