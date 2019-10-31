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
  expect_silent(insee_deauth(verbose = FALSE))
  expect_message(insee_deauth(verbose = TRUE))
})

test_that("memory cache works", {
  check_configuration()
  skip_if_no_app()
  clear_memory_cache()
  debug_conf <- httr::config(
    verbose = TRUE,
    debugfunction = function(type, msg) cat(readBin(msg, character()))
  )
  with_debug_conf <- function(expr) httr::with_config(config = debug_conf, expr)
  expect_output(token <- with_debug_conf(insee_auth()))
  expect_silent(with_debug_conf(insee_auth()))
  expect_reference(insee_auth(), token)
  expect_silent(with_debug_conf(insee_auth(key = "", secret = "")))
  expect_reference(insee_auth(key = "", secret = ""), token)
  expect_length(as.list(apinsee:::.memory_cache), 2L)
  clear_memory_cache()
  expect_length(as.list(apinsee:::.memory_cache), 0L)
})

test_that("insee_auth() new_auth parameter works", {
  check_configuration()
  skip_if_no_app()
  clear_memory_cache()
  expect_message(insee_auth(new_auth = TRUE))
})

test_that("insee_auth() fetches seamlessly a new fresh token", {
  check_configuration()
  skip_if_no_app()
  clear_memory_cache()
  token <- insee_auth()
  token$revoke()
  expect_true(token$has_expired())
  token2 <- insee_auth()
  expect_false(token2$has_expired())
})

test_that("insee_auth() can be used with several applications", {
  check_configuration()
  skip_if_no_app()
  clear_memory_cache()
  token <- insee_auth()
  token2 <- insee_auth(key = Sys.getenv("INSEE_APP2_KEY"), secret = Sys.getenv("INSEE_APP2_SECRET"))
  expect_false(token$has_expired())
  expect_false(token2$has_expired())
  expect_length(as.list(apinsee:::.memory_cache), 3L)
  clear_memory_cache()
})
