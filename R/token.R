#' @include revoke.R endpoint.R
NULL

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

TokenInsee <- R6::R6Class("TokenInsee", inherit = httr::Token2.0, list(
  revoke = function() {
    revoke_apinsee(self$endpoint, self$credentials, self$app)
  }
))
