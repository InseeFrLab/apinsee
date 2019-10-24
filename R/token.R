#' @include endpoint.R
NULL

#' Generate a token for an Insee application
#'
#' Cette fonction génère un jeton d'accès à une application créée sur le site
#' [api.insee.fr](https://api.insee.fr/).
#'
#' @inheritParams httr::oauth2.0_token
#' @param validity_period A positive integer; token validity period in seconds.
#'
#' @return Un objet de classe [TokenInsee].
#' @keywords internal
#' @encoding UTF-8
#' @export
insee_token <- function(
  app, cache = getOption("httr_oauth_cache"),
  config_init = list(), credentials = NULL,
  validity_period = 86400
) {

  stopifnot(
    rlang::is_scalar_integerish(validity_period, finite = TRUE),
    validity_period > 0
  )

  scope <- c(
    "https://api.insee.fr/metadonnees/nomenclatures/v1",
    "https://api.insee.fr/entreprises/sirene/V3",
    "https://api.insee.fr/entreprises/sirene/"
  )

  user_params <- list(
    grant_type = "client_credentials",
    validity_period = validity_period
  )

  params <- list(
    scope = scope,
    user_params = user_params,
    type = NULL,
    use_oob = getOption("httr_oob_default"),
    oob_value = NULL,
    as_header = TRUE,
    use_basic_auth = TRUE,
    config_init = config_init,
    client_credentials = TRUE,
    query_authorize_extra = list()
  )

  TokenInsee$new(
    app = app,
    endpoint = insee_endpoint(),
    params = params,
    credentials = credentials,
    cache_path = if (is.null(credentials)) cache else FALSE
  )
}

#' Token objects for Insee applications
#'
#' Cette classe représente les jetons d'accès aux applications créées sur
#' [api.insee.fr](https://api.insee.fr) et hérite de la classe
#' [Token2.0][httr::Token-class] du package [httr][httr::httr-package]. Les
#' objets de cette classe doivent être créés en appelant le constructeur
#' `get_insee_token()`.
#'
#' @format Un objet de classe `R6`.
#' @section Methods:
#' * `has_expired()` : le jeton d'accès a-t-il expiré ?
#' * `cache()` : sauvegarde le jeton d'accès dans un cache
#' * `revoke()` : révoque le jeton d'accès
#' * `refresh()` : rafraichit le jeton d'accès (le point d'accès de
#' rafraichissement OAuth2 n'étant pas disponible, le jeton d'accès
#' courant est révoqué puis un nouveau jeton d'accès est généré)
#' @inheritSection httr::Token Caching
#' @docType class
#' @keywords internal
#' @encoding UTF-8
#' @export
TokenInsee <- R6::R6Class("TokenInsee", inherit = httr::Token2.0, list(

  print = function(...) {
    super$print()

    if(self$has_expired()) {
      cat("expired token\n")
    } else {
      cat("expiration date:", format(self$credentials$expiration_time), "\n")
    }
    cat("---\n")
  },

  init_credentials = function() {
    super$init_credentials()

    if (is.null(self$credentials$expiration_time)) {
      self$credentials$expiration_time <-
        Sys.time() + self$credentials$expires_in
    }
  },

  has_expired = function() {
    if (is.null(self$credentials$expiration_time)) return(TRUE)

    Sys.time() > self$credentials$expiration_time
  },

  load_from_cache = function() {
    super$load_from_cache() && !self$has_expired()
  },

  revoke = function() {
    # httr:::revoke_oauth2.0() does not implement correctly the following specification:
    # https://tools.ietf.org/html/rfc7009#section-2.1
    # I will open an issue in r-lib/httr
    res <- httr::POST(
      self$endpoint$revoke,
      encode = "form",
      body = list(token = self$credentials$access_token),
      httr::authenticate(self$app$key, self$app$secret, type = "basic")
    )

    httr::stop_for_status(res)

    self$credentials$expiration_time <- Sys.time()
    self$cache()
    invisible(self)
  },

  refresh = function() {
    self$revoke()
    self$init_credentials()
    self$cache()
    invisible(self)
  },

  can_refresh = function() {
    TRUE
  }
))
