#' @include token.R
NULL

# environment to store credentials
.mem_cache <- rlang::new_environment()

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
  verbose = TRUE
) {

  if (new_auth) {
    insee_deauth(clear_cache = TRUE, verbose = verbose)
  }

  if (is.null(.mem_cache$token)) {

    app <- httr::oauth_app(appname = appname, key = key, secret = secret)

    fetched_token <- insee_token(
      app = app,
      cache = cache,
      validity_period = validity_period
    )

    stopifnot(is_legit_token(fetched_token, verbose = TRUE))
    .mem_cache$token <- fetched_token

  }

  invisible(.mem_cache$token)

}

#' Suspend authentication
#'
#' Suspend access to an application.
#'
#' @param clear_cache logical indicating whether to disable the
#'   `.httr-oauth` file in working directory, if such exists, by renaming
#'   to `.httr-oauth-SUSPENDED`
#' @param verbose logical; do you want informative messages?
#'
#' @return NULL, invisibly.
#' @export
insee_deauth <- function(clear_cache = TRUE, verbose = TRUE) {

  if (clear_cache && file.exists(".httr-oauth")) {
    if (verbose) {
      message("Disabling .httr-oauth by renaming to .httr-oauth-SUSPENDED")
    }
    file.rename(".httr-oauth", ".httr-oauth-SUSPENDED")
  }

  if (token_available(verbose = FALSE)) {
    if (verbose) {
      message("Removing token stashed internally in 'apinsee'.")
    }
    .mem_cache$token$revoke()
    rm("token", envir = .mem_cache)
  } else {
    message("No token currently in force.")
  }

  invisible(NULL)

}

token_available <- function(verbose = TRUE) {

  if (is.null(.mem_cache$token)) {
    if (verbose) {
      if (file.exists(".httr-oauth")) {
        message("A .httr-oauth file exists in current working ",
                "directory.\nWhen/if needed, the credentials cached in ",
                ".httr-oauth will be used for this session.\nOr run insee_auth() ",
                "for explicit authentication and authorization.")
      } else {
        message("No .httr-oauth file exists in current working directory.\n",
                "When/if needed, 'apinsee' will initiate authentication ",
                "and authorization.\nOr run insee_auth() to trigger this ",
                "explicitly.")
      }
    }
    return(FALSE)
  }

  TRUE

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
