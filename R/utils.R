# environment to store credentials
.memory_cache <- rlang::new_environment()

cache_in_memory <- function(token) {
  rlang::env_bind(.memory_cache, !!token$app$key := token)
}

load_from_memory_cache <- function(key) {
  rlang::env_get(.memory_cache, key, NULL)
}
