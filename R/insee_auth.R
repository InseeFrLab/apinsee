#' @include token.R utils.R
NULL

#' Authenticate to an Insee application
#'
#' @param new_auth logical, defaults to `FALSE`. Set to `TRUE` if you
#'   want to wipe the slate clean and re-authenticate with the same
#'   application. This disables the `.httr-oauth` file in current
#'   working directory.
#' @param appname application name.
#' @param key,secret consumer key and secret of the application.
#' @param validity_period integer, length of the validity period in seconds.
#' @param cache logical indicating if `apinsee` should cache
#'   credentials in the default cache file `.httr-oauth`.
#' @param verbose logical; do you want informative messages?
#' @inheritParams insee_endpoint
#'
#' @return A token.
#' @export
insee_auth <- function(
  new_auth = FALSE,
  appname = "DefaultApplication",
  key = Sys.getenv("INSEE_APP_KEY"),
  secret = Sys.getenv("INSEE_APP_SECRET"),
  validity_period = 86400,
  cache = FALSE,
  verbose = TRUE,
  insee_url = getOption("apinsee.url")
) {

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
      insee_url = insee_url
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
      message("Removing token for application ", token$app$key ," stashed internally in 'apinsee'.")
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

