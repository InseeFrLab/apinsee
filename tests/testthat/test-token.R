test_that("insee_token returns an OAuth2.0 token", {
  skip_if_offline("api.insee.fr")
  skip_if_no_app()
  app <- httr::oauth_app("Test", Sys.getenv("INSEE_API_KEY"), Sys.getenv("INSEE_API_SECRET"))
  token <- insee_token(app, cache = TRUE)
  expect_s3_class(token, "TokenInsee")
})
