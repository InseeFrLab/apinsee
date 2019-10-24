test_that("insee_token() returns an OAuth2.0 token", {
  token <- fetch_token_maybe()
  expect_s3_class(token, "TokenInsee")
  expect_s3_class(token, "Token2.0")
})

test_that("When revoked has_expired() method returns TRUE", {
  token <- fetch_token_maybe()
  token$revoke()
  expect_true(token$has_expired())
})
