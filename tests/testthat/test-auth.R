test_that("insee_auth() and insee_deauth() works", {
  check_configuration()
  skip_if_no_app()
  token <- insee_auth()
  expect_reference(token, insee_auth())
  expect_s3_class(token, "TokenInsee")
  expect_message(insee_deauth())
})

test_that("insee_deauth() works", {
  check_configuration()
  skip_if_no_app()
  expect_silent(insee_deauth(FALSE))
  expect_message(insee_deauth(TRUE))
})

test_that("memory cache works", {
  check_configuration()
  skip_if_no_app()
  insee_deauth(FALSE)
  debug_conf <- httr::config(
    verbose = TRUE,
    debugfunction = function(type, msg) cat(readBin(msg, character()))
  )
  with_debug_conf <- function(expr) httr::with_config(config = debug_conf, expr)
  expect_output(with_debug_conf(insee_auth()))
  expect_silent(with_debug_conf(insee_auth()))
  insee_deauth(FALSE)
})

test_that("insee_auth() new_auth parameter works", {
  check_configuration()
  skip_if_no_app()
  insee_deauth(FALSE)
  expect_message(insee_auth(new_auth = TRUE))
})
