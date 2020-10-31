#' @importFrom rlang :=
NULL

# environment to store credentials
.memory_cache <- rlang::new_environment()

cache_in_memory <- function(token) {
  rlang::env_bind(.memory_cache, !!token$app$key := token)
  rlang::env_bind(.memory_cache, last_token = token)
}

load_from_memory_cache <- function(app_key) {
  if (missing(app_key) || !nzchar(app_key)) {
    return(rlang::env_get(.memory_cache, "last_token", NULL))
  }
  rlang::env_get(.memory_cache, app_key, NULL)
}

clear_memory_cache <- function() {
  rlang::env_unbind(.memory_cache, rlang::env_names(.memory_cache))
}
