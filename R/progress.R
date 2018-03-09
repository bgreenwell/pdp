#' Progress bar
#'
#' More informative progress bar powered by
#' \code{\link[progress]{progress_bar}}.
#'
#' @param ... Additional optional arguments to be passed onto
#' \code{\link[progress]{progress_bar}}.
#'
#' @export
progress_progress <- function(...) {
  pb <- NULL
  list(
    init = function(x, ...) {
      pb <<- progress::progress_bar$new(
        total = x,
        format = "  Computing partial dependence [:bar] :percent eta: :eta",
        clear = FALSE, width = 80, ...
      )
    },
    step = function() {
      pb$tick()
    },
    term = function() NULL
  )
}
