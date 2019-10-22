#' @include revoke.R endpoint.R
NULL

#' Token objects for access to applications
#'
#' Cette classe représente les jetons d'accès aux applications créées sur
#' [api.insee.fr](https://api.insee.fr) et hérite de la classe
#' [Token2.0][httr::Token-class] du package [httr][httr::httr-package]. Les
#' objets de cette classe doivent être créés en appelant le constructeur
#' `get_insee_token()`.
#'
#' @format Un objet de classe `R6`.
#' @section Methods:
#' * `cache()` : sauvegarde le jeton d'accès dans un cache
#' * `revoke()` : révoque le jeton d'accès
#' @inheritSection httr::Token Caching
#' @docType class
#' @keywords internal
#' @encoding UTF-8
#' @export
TokenInsee <- R6::R6Class("TokenInsee", inherit = httr::Token2.0, list(
  revoke = function() {
    revoke_apinsee(self$endpoint, self$credentials, self$app)
  }
))

get_insee_token <- function(app, user_params, cache) {

  scope <- c(
    .state$nomenclatures_url,
    .state$sirene_url,
    "https://api.insee.fr/entreprises/sirene/"
  )

  params <- list(
    scope = scope,
    user_params = user_params,
    type = NULL,
    use_oob = getOption("httr_oob_default"),
    oob_value = NULL,
    as_header = TRUE,
    use_basic_auth = TRUE,
    config_init = list(),
    client_credentials = TRUE,
    query_authorize_extra = list()
  )

  TokenInsee$new(
    app = app,
    endpoint = insee_endpoint(),
    params = params,
    credentials = NULL,
    cache_path = cache
  )
}

