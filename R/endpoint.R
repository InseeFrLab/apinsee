#' Get Insee endpoint
#'
#' Cette fonction renvoie le point d'accès aux API de l'Insee.
#'
#' @return Un objet de classe `oauth_endpoint`.
#' @export
#'
#' @encoding UTF-8
#' @examples
#' insee_endpoint()
insee_endpoint <- function() {
  httr::oauth_endpoint(
    base_url = "https://api.insee.fr",
    access = "token",
    revoke = "revoke",
    request = NULL,
    authorize = NULL
  )
}
