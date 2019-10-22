#' Get Insee endpoint
#'
#' Cette fonction renvoie les points d'accès définis par
#' [api.insee.fr](https://api.insee.fr).
#'
#' @return Un objet de classe [oauth_endpoint][httr::oauth_endpoint].
#' @export
#'
#' @encoding UTF-8
#' @keywords internal
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
