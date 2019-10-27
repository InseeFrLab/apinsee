test_that("insee_token() returns an OAuth2.0 token", {
  token <- fetch_token_maybe()
  expect_s3_class(token, "TokenInsee")
  expect_s3_class(token, "Token2.0")
})

test_that("When a token is revoked, has_expired() method returns TRUE", {
  credentials <- list(
    access_tokens = "aaa",
    scope = "am_application_scope default",
    token_type = "Bearer",
    expires_in = "100000",
    expiration_time = Sys.time() - 1
  )
  token <- insee_token(app = mocked_app, credentials = credentials)
  expect_true(token$has_expired())

  token <- fetch_token_maybe()
  token$revoke()
  Sys.sleep(0.1)
  expect_true(token$has_expired())
})

test_that("refresh() method works", {
  token <- fetch_token_maybe()
  token$revoke()
  Sys.sleep(0.1)
  expect_true(token$has_expired())
  expect_true(token$can_refresh())
  token$refresh()
  expect_false(token$has_expired())
})

test_that("print() method works", {
  token <- fetch_token_maybe()
  expect_output(print(token))
  token$revoke()
  Sys.sleep(0.1)
  expect_output(print(token), "expired")
})

test_that("validity_period must be a positive integer", {
  expect_error(insee_token(mocked_app, validity_period = 1.5))
  expect_error(insee_token(mocked_app, validity_period = -1L))
})
