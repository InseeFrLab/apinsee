#' Get Insee endpoints
#'
#' Cette fonction renvoie les points d'accès définis par
#' [api.insee.fr](https://api.insee.fr).
#'
#' @section Utilisation interne à l'Insee:
#' Dans le cas d'utilisation standard, la valeur de l'option `apinsee.url` est
#' `"https://api.insee.fr/"`. Il n'est pas utile de la modifier sauf pour les
#' agents de l'Insee qui souhaiteraient utiliser les plateformes de test, de
#' recette ou de pré-production. Dans ce cas, il est préférable de déclarer
#' l'adresse en modifiant l'option `apinsee.url` :
#' `options(apinsee.url = "<URL>")`. Les programmes seront ainsi facilement
#' portables d'un environnement à un autre.
#'
#' @param insee_url Adresse du site fournissant les API. Ce paramètre n'est
#'   utile que pour un usage interne à l'Insee, voir la section "Utilisation
#'   interne à l'Insee".
#' @return Un objet de classe [oauth_endpoint][httr::oauth_endpoint].
#' @export
#'
#' @encoding UTF-8
#' @keywords internal
#' @examples
#' insee_endpoint()
insee_endpoint <- function(insee_url = getOption("apinsee.url")) {
  httr::oauth_endpoint(
    base_url = insee_url,
    access = "token",
    revoke = "revoke",
    request = NULL,
    authorize = NULL
  )
}

insee_scope <- function(insee_url = getOption("apinsee.url")) {
  modify_insee_url <- function(path) {
    httr::modify_url(url = insee_url, path = path)
  }

  paths <- list(
    c("metadonnees", "nomenclatures", "v1"),
    c("entreprises", "sirene", "V3"),
    c("entreprises", "sirene")
  )

  vapply(paths, modify_insee_url, character(1))

}
