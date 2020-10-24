#' @include token.R utils.R
NULL

#' Authenticate to an Insee application
#'
#' Cette fonction permet de s'authentifier via une application créée sur
#' [api.insee.fr](https://api.insee.fr/) : elle renvoie un jeton d'accès
#' valide qui peut ensuite être passé en valeur du paramètre `token` de
#' la fonction [httr::config()][httr::config].
#'
#' @details
#' Le couple clef du consommateur/secret du consommateur de l'application
#' devant rester secret, il est vivement recommandé de ne jamais l'inclure
#' dans un programme. La pratique recommandée est d'utiliser des variables
#' d'environnement pour stocker ces informations. La fonction `insee_auth()`
#' utilise deux variables d'environnement nommées `INSEE_APP_KEY` et
#' `INSEE_APP_SECRET`. Une fois renseignées, l'authentification s'effectue par
#' un simple appel à la fonction `insee_auth()`.
#'
#' @details
#' Les variables d'environnement peuvent être déclarées dans le fichier
#' [`.Renviron`][base::Startup]. La modification de ce fichier peut s'effectuer
#' facilement grâce la fonction [usethis::edit_r_environ()][usethis::edit].
#'
#' @param new_auth booléen, valeur par défaut : `FALSE`. Passer `TRUE` si vous
#'   souhaitez révoquer le jeton d'accès et vous authentifier à nouveau.
#' @param appname nom de l'application.
#' @param key,secret clef et secret du consommateur.
#' @param validity_period entier, durée de validité du jeton d'accès en secondes.
#' @param cache booléen indiquant si `apinsee` doit sauvegarder les jetons
#'   d'accès dans un fichier cache, par défaut `.httr-oauth`.
#' @param verbose booléen; souhaitez-vous des messages d'information ?
#' @inheritParams insee_token
#' @inheritParams insee_endpoint
#' @inheritSection insee_endpoint Utilisation interne à l'Insee
#' @encoding UTF-8
#'
#' @return Un objet représentant un token pouvant être passé en valeur du
#'     paramètre `token` de la fonction [httr::config()][httr::config].
#' @seealso [insee_deauth], [TokenInsee], [httr::config].
#' @export
#' @examples
#' # Modify the following option to access to a different url
#' # options(apinsee.url = "https://api.insee.fr/")
#'
#' library(apinsee)
#' library(httr)
#'
#' # Set the environment variables INSEE_APP_KEY and INSEE_APP_SECRET in the .Renviron file
#' if (all(nzchar(Sys.getenv(c("INSEE_APP_KEY", "INSEE_APP_SECRET"))))) {
#'   # retrieve the token
#'   token <- insee_auth()
#'   # use the token
#'   set_config(config(token = token))
#' }
insee_auth <- function(
                       new_auth = FALSE,
                       appname = "DefaultApplication",
                       key = Sys.getenv("INSEE_APP_KEY"),
                       secret = Sys.getenv("INSEE_APP_SECRET"),
                       validity_period = 86400,
                       api = c("Sirene V3", "Nomenclatures v1"),
                       cache = FALSE,
                       verbose = TRUE,
                       insee_url = getOption("apinsee.url")) {
  if (new_auth) {
    insee_deauth(verbose = verbose)
  }

  token <- load_from_memory_cache(key)

  if (is.null(token) || token$has_expired()) {
    app <- httr::oauth_app(appname = appname, key = key, secret = secret)

    token <- insee_token(
      app = app,
      cache = cache,
      validity_period = validity_period,
      insee_url = insee_url,
      api = api
    )

    stopifnot(is_legit_token(token, verbose = TRUE))

    cache_in_memory(token)
  }

  invisible(token)
}

#' Suspend authentication
#'
#' Suspend access to an application.
#'
#' @param verbose logical; do you want informative messages?
#'
#' @return NULL, invisibly.
#' @export
insee_deauth <- function(verbose = TRUE) {
  tokens <- as.list(.memory_cache)
  lapply(tokens, function(token) {
    if (verbose) {
      message("Revoking token for application ", token$app$key)
    }
    token$revoke()
    if (verbose) {
      message("Removing token for application ", token$app$key, " stashed internally in 'apinsee'.")
    }
    rlang::env_unbind(.memory_cache, token$app$key)
  })

  if (verbose && length(tokens) == 0) {
    message("No token currently in force.")
  }

  invisible(NULL)
}

is_legit_token <- function(x, verbose = FALSE) {
  if (!inherits(x, "TokenInsee")) {
    if (verbose) message("Not a TokenInsee object.")
    return(FALSE)
  }

  if ("invalid_client" %in% unlist(x$credentials)) {
    if (verbose) {
      message("Authorization error. Please check application key and secret.")
    }
    return(FALSE)
  }

  if ("invalid_request" %in% unlist(x$credentials)) {
    if (verbose) message("Authorization error. No access token obtained.")
    return(FALSE)
  }

  TRUE
}
