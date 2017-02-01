detect_granularity <- function(date_times) {
  if (length(date_times) == 1) {
    stop("Cannot detect granularity from just one datetime.")
  }
  differences <- diff(date_times)
  units(differences) <- "secs"
  differences <- as.numeric(differences)
  if (length(differences) > 1) {
    if (stats::var(differences) > 0) {
      if (all(differences <= 604800)) {
        stop("Observations are not evenly spaced in time.")
      } else if (all(differences > 604800 & differences <= 31536000)) {
        if (all(date_times[-1] == date_times[-length(date_times)] + base::months(1))) {
          return("month")
        } else {
          stop("Observations are seemingly not evenly spaced in time.")
        }
      } else {
        if (all(date_times[-1] == date_times[-length(date_times)] + lubridate::years(1))) {
          return("year")
        } else {
          stop("Observations are seemingly not evenly spaced in time.")
        }
      }
    }
  } else {
    if (date_times[1] + base::months(1) == date_times[2]) {
      return("month")
    } else if (date_times[1] + lubridate::years(1) == date_times[2]) {
      return("year")
    }
  }
  return(switch(
    as.character(differences[1]),
    `1` = "second",
    `60` = "minute",
    `3600` = "hour",
    `86400` = "day",
    `604800` = "week",
    as.character(NA)
  ))
}
