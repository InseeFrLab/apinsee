test_that("insee_auth() works", {
  check_configuration()
  skip_if_no_app()
  expect_invisible(insee_auth())
  #token <- insee_auth()
  #expect_reference(token, insee_auth())
})

test_that("insee_deauth() works", {
  check_configuration()
  skip_if_no_app()
  expect_silent(insee_deauth(FALSE))
})

# test_that("memory cache works", {
#   check_configuration()
#   skip_if_no_app()
#   insee_deauth(FALSE)
#   expect_message(httr::with_verbose(insee_auth()))
#   expect_silent(httr::with_verbose(insee_auth()))
# })
