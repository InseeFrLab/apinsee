skip_if_no_app <- function() {
  if (nzchar(Sys.getenv("INSEE_APP_KEY")) && nzchar(Sys.getenv("INSEE_APP_SECRET"))) {
    return(invisible(TRUE))
  }
  testthat::skip("Environment variables INSEE_APP_KEY and INSEE_APP_SECRET are not defined.")
}

check_configuration <- function() {
  skip_if_no_app()
  skip_if_offline("api.insee.fr")
  skip_if_not_installed("httpuv")
}

fetch_token_maybe <- function() {
  check_configuration()
  app <- httr::oauth_app("Test", Sys.getenv("INSEE_APP_KEY"), Sys.getenv("INSEE_APP_SECRET"))
  insee_token(app, cache = FALSE)
}
