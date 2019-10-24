test_that("insee_token() returns an OAuth2.0 token", {
  token <- fetch_token_maybe()
  expect_s3_class(token, "TokenInsee")
  expect_s3_class(token, "Token2.0")
})

test_that("When revoked has_expired() method returns TRUE", {
  token <- fetch_token_maybe()
  token$revoke()
  Sys.sleep(0.1)
  expect_true(token$has_expired())
})

test_that("validity_period must be a positive integer", {
  expect_error(insee_token(mocked_app, validity_period = 1.5))
  expect_error(insee_token(mocked_app, validity_period = -1L))
})
