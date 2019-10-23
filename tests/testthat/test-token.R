test_that("insee_token() returns an OAuth2.0 token", {
  check_configuration()
  app <- httr::oauth_app("Test", Sys.getenv("INSEE_APP_KEY"), Sys.getenv("INSEE_APP_SECRET"))
  token <- insee_token(app, cache = FALSE)
  expect_s3_class(token, "TokenInsee")
  expect_s3_class(token, "Token2.0")
})
