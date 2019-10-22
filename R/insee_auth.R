#' @include token.R
NULL

# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Authenticate to an Insee application
#'
#' @param token optional; an actual token object or the path to a valid token
#'   stored as an `.rds` file.
#' @param new_app logical, defaults to `FALSE`. Set to `TRUE` if you
#'   want to wipe the slate clean and re-authenticate with the same or different
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
  token = .state$token,
  new_app = FALSE,
  appname = "DefaultApplication",
  key = Sys.getenv("INSEE_API_KEY"),
  secret = Sys.getenv("INSEE_API_SECRET"),
  validity_period = 86400,
  cache = getOption("httr_oauth_cache"),
  verbose = TRUE
) {

  if (new_app) {
    insee_deauth(clear_cache = TRUE, verbose = verbose)
  }

  if (is.null(token)) {

    app <- httr::oauth_app(appname = appname, key = key, secret = secret)

    fetched_token <- insee_token(
      app = app,
      cache = cache,
      validity_period = validity_period
    )

    stopifnot(is_legit_token(fetched_token, verbose = TRUE))
    .state$token <- fetched_token

  } else if (inherits(token, "TokenInsee")) {

    stopifnot(is_legit_token(token, verbose = TRUE))
    .state$token <- token

  } else if (inherits(token, "character")) {

    cached_token <- try(suppressWarnings(readRDS(token)), silent = TRUE)
    if (inherits(cached_token, "try-error")) {
      stop(sprintf("Cannot read token from alleged .rds file:\n%s", token), call. = FALSE)
    } else if (!is_legit_token(cached_token, verbose = TRUE)) {
      stop(sprintf("File does not contain a proper token:\n%s", token), call. = FALSE)
    }
    .state$token <- cached_token
  } else {
    stop("Input provided via 'token' is neither a",
        "token,\nnor a path to an .rds file containing a token.", call. = FALSE)
  }

  invisible(.state$token)

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
    .state$token$revoke()
    rm("token", envir = .state)
  } else {
    message("No token currently in force.")
  }

  invisible(NULL)

}

token_available <- function(verbose = TRUE) {

  if (is.null(.state$token)) {
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
