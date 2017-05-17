#' @title R's pageviews on English Wikipedia
#' @description The daily pageviews of the
#'   \href{https://en.wikipedia.org/wiki/R_(programming_language)}{English Wikipedia article on R}.
#' @details \preformatted{
#' r_enwiki <- pageviews::article_pageviews(
#'   project = "en.wikipedia", article = "R (programming language)",
#'   platform = "desktop", user_type = "user",
#'   end = "2017051600")[, c("date", "views")]
#' names(r_enwiki) <- c("date", "pageviews")
#' }
#' @format A \code{data.frame} with columns "date" and "pageviews"
"r_enwiki"
