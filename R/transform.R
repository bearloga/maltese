#' @title Transform a time series to a machine learning-friendly format
#' @description Performs the necessary transformations to make a univariate
#'   time series acceptable for use with machine learning models like neural
#'   networks.
#' @param .data A tidy data.frame/tbl
#' @param .dt Name of the column in \code{.data} containing the date-times;
#'   does not need to be a character
#' @param .y Name of the column in \code{.data} containing an evenly spaced
#'   time series as a numeric vector or factor; does not need to be a character
#' @param p Number of previous observations to turn into features (think AR(p))
#' @param xreg A character vector of column names of external regressors in \code{.data}
#' @param granularity One of: seconds, minutes, hours, days, weeks, months,
#'   quarters, years. If not specified, will attempt to detect.
#' @param extras Whether maltese will create new features (like day of week)
#' @param extrasAsFactors Whether to output extra features as factors or
#'   numeric (default). If TRUE, some (like day of week or month) will be
#'   ordered factors.
#' @param start Which day does the week start? "Sun"day or "Mon"day (default)?
#' @return A \code{data.frame} suitable for supervised learners with columns:
#'   \describe{
#'     \item{dt}{The date or date-time (same as \code{dt})}
#'     \item{y}{The time series}
#'     \item{mlts_lag_k}{The previous k-th observation}
#'     \item{mlts_extras_?}{Extra features like hour of day, day of the week, month of the year, etc.}
#'   }
#' @examples
#' data("r_enwiki", package = "maltese")
#' mlts <- mlts_transform(head(r_enwiki), date, pageviews)
#' @export
mlts_transform <- function(.data, .dt, .y, p = 1, xreg = NULL, granularity = NULL, extras = FALSE, extrasAsFactors = FALSE, start = c("Mon", "Sun")) {
  dt <- .data[, deparse(substitute(.dt)), drop = TRUE]
  y <- .data[, deparse(substitute(.y)), drop = TRUE]
  if (!is.null(xreg)) {
    xreg <- .data[, .xreg, drop = FALSE]
  }
  if (typeof(dt) == "character") {
    message("Provided 'dt' is a character vector, coercing to POSIXct")
    dt <- lubridate::ymd_hms(dt)
  }
  n <- length(y)
  wide <- do.call(cbind, lapply(1:p, function(k) {
    return(as.data.frame(dplyr::lag(y, k)))
  }))
  colnames(wide) <- paste0("mlts_lag_", 1:p)
  if (extras) {
    if (is.null(granularity)) {
      message("Attempting to detect granularity based on index...")
      granularity <- detect_granularity(dt)
      message("Granularity detected as \"", granularity, "\".")
    }
    granularity <- as.numeric(factor(granularity, levels = c("second", "minute", "hour", "day", "week", "month", "year")))
    extra_features <- as.list(numeric(granularity))
    names(extra_features) <- c("second", "minute", "hour", "day", "week", "month", "year")[(granularity):7]
    if (extrasAsFactors) {
      extra_features[["year"]] <- data.frame(mlts_extras_year = ordered(lubridate::year(dt)))
    } else {
      extra_features[["year"]] <- data.frame(mlts_extras_year = lubridate::year(dt))
    }
    if (granularity < 7) {
      if (extrasAsFactors) {
        extra_features[["month"]] <- data.frame(
          mlts_extras_month = factor(
            x = lubridate::month(dt, label = TRUE, abbr = FALSE),
            levels = base::month.name,
            ordered = TRUE
          )
        )
      } else {
        extra_features[["month"]] <- data.frame(mlts_extras_month = lubridate::month(dt, label = FALSE))
      }
    }
    if (granularity < 6) {
      if (extrasAsFactors) {
        extra_features[["week"]] <- data.frame(mlts_extras_week = ordered(lubridate::week(dt), levels = 1:53))
      } else {
        extra_features[["week"]] <- data.frame(mlts_extras_week = lubridate::week(dt))
      }
    }
    if (granularity < 5) {
      if (extrasAsFactors) {
        if (start[1] == "Mon") {
          extra_features[["day"]] <- data.frame(
            mlts_extras_monthday = ordered(lubridate::mday(dt)),
            mlts_extras_weekday = factor(
              x = lubridate::wday(dt, label = TRUE, abbr = FALSE),
              levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"),
              ordered = TRUE
            )
          )
        } else if (start[1] == "Sun") {
          extra_features[["day"]] <- data.frame(
            mlts_extras_monthday = ordered(lubridate::mday(dt)),
            mlts_extras_weekday = factor(
              x = lubridate::wday(dt, label = TRUE, abbr = FALSE),
              levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"),
              ordered = TRUE
            )
          )
        } else {
          stop("Start of the week can only be \"Mon\" or \"Sun.\"")
        }
      } else {
        extra_features[["day"]] <- data.frame(
          mlts_extras_monthday = lubridate::mday(dt),
          mlts_extras_weekday = lubridate::wday(dt, label = FALSE)
        )
      }
    }
    if (granularity < 4) {
      if (extrasAsFactors) {
        extra_features[["hour"]] <- data.frame(mlts_extras_hour = ordered(lubridate::hour(dt)))
      } else {
        extra_features[["hour"]] <- data.frame(mlts_extras_hour = lubridate::hour(dt))
      }
    }
    if (granularity < 3) {
      if (extrasAsFactors) {
        extra_features[["minute"]] <- data.frame(mlts_extras_minute = ordered(lubridate::minute(dt)))
      } else {
        extra_features[["minute"]] <- data.frame(mlts_extras_minute = lubridate::minute(dt))
      }
    }
    if (granularity < 2) {
      if (extrasAsFactors) {
        extra_features[["second"]] <- data.frame(mlts_extras_second = ordered(lubridate::second(dt)))
      } else {
        extra_features[["second"]] <- data.frame(mlts_extras_second = lubridate::second(dt))
      }
    }
    extra_features <- dplyr::bind_cols(extra_features)
  } else {
    extra_features <- NULL
  }
  # Output:
  return(dplyr::bind_cols(data.frame(dt = dt, y = y), xreg, extra_features, as.data.frame(wide))[-(1:p), ])
}
