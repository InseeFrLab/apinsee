revoke_apinsee <- function(endpoint, credentials, app) {
  response <- httr::POST(
    endpoint$revoke,
    encode = "form",
    body = list(token = credentials$access_token),
    httr::authenticate(app$key, app$secret, type = "basic")
  )
  httr::stop_for_status(response)
  invisible(TRUE)
}

