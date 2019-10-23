skip_if_no_app <- function() {
  if (nzchar(Sys.getenv("INSEE_APP_KEY")) && nzchar(Sys.getenv("INSEE_APP_SECRET"))) {
    return(invisible(TRUE))
  }
  testthat::skip("Environment variables INSEE_APP_KEY and INSEE_APP_SECRET are not defined.")
}
