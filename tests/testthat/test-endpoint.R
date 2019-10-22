test_that("returned object is of class oauth_endpoint", {
  endpoint <- insee_endpoint()
  expect_s3_class(endpoint, "oauth_endpoint")
})
