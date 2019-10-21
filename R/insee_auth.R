# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Authenticate to an Insee application
#'
#' @param token optional; an actual token object or the path to a valid token
#'   stored as an \code{.rds} file.
#' @param new_app logical, defaults to \code{FALSE}. Set to \code{TRUE} if you
#'   want to wipe the slate clean and re-authenticate with the same or different
#'   application. This disables the \code{.httr-oauth} file in current
#'   working directory.
#' @param appname application name.
#' @param key,secret consumer key and secret of the application.
#' @param validity_period integer, length of the validity period in seconds.
#' @param cache logical indicating if \code{apinsee} should cache
#'   credentials in the default cache file \code{.httr-oauth}.
#' @param verbose print message.
#'
#' @return A token.
#' @export
insee_auth <- function(
  token = NULL,
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

    scope_list <- c(.state$nomenclatures_url,
                    .state$sirene_url,
                    "https://api.insee.fr/entreprises/sirene/")

    insee_endpoint <- httr::oauth_endpoint(
      base_url = "https://api.insee.fr",
      request = NULL,
      authorize = NULL,
      access = "token",
      revoke = "revoke"
    )

    user_app <- httr::oauth_app(appname = appname, key = key, secret = secret)

    insee_token <- httr::oauth2.0_token(
      insee_endpoint,
      user_app,
      scope = scope_list,
      user_params = list(grant_type = "client_credentials",
                         validity_period = validity_period
                         ),
      use_basic_auth = TRUE,
      cache = cache,
      client_credentials = TRUE
    )
    stopifnot(is_legit_token(insee_token, verbose = TRUE))
    .state$token <- insee_token

  } else if (inherits(token, "Token2.0")) {

    stopifnot(is_legit_token(token, verbose = TRUE))
    .state$token <- token

  } else if (inherits(token, "character")) {

    insee_token <- try(suppressWarnings(readRDS(token)), silent = TRUE)
    if (inherits(insee_token, "try-error")) {
      stop(sprintf("Cannot read token from alleged .rds file:\n%s", token), call. = FALSE)
    } else if (!is_legit_token(insee_token, verbose = TRUE)) {
      stop(sprintf("File does not contain a proper token:\n%s", token), call. = FALSE)
    }
    .state$token <- insee_token
  } else {
    stop("Input provided via 'token' is neither a",
        "token,\nnor a path to an .rds file containing a token.", call. = FALSE)
  }

  invisible(.state$token)

}

insee_deauth <- function(
  clear_cache = TRUE, verbose = TRUE
) {

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

  if (!inherits(x, "Token2.0")) {
    if (verbose) message("Not a Token2.0 object.")
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
