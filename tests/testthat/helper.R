skip_if_no_app <- function() {
  if (nzchar(Sys.getenv("INSEE_API_KEY")) && nzchar(Sys.getenv("INSEE_API_SECRET"))) {
    return(invisible(TRUE))
  }
  testthat::skip("Environment variables INSEE_API_KEY and INSEE_API_SECRET are not defined.")
}
