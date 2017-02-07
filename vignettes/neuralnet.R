## ----options, include = FALSE--------------------------------------------
knitr::opts_chunk$set(message = FALSE, warning = FALSE)

## ----setup---------------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
library(maltese)
library(neuralnet)
suppressPackageStartupMessages(library(dummy))

## ----data----------------------------------------------------------------
data("r_enwiki", package = "maltese")
head(r_enwiki)

## ----normalization-------------------------------------------------------
# How much of the data to use for training vs validation:
split_point <- "2016-11-01"
table(ifelse(r_enwiki$date < split_point, "training set", "testing set"))
# Save for later use (when converting back to original scale):
normalization_constants <- lapply(
  list(median = median, mad = mad, mean = mean, std.dev = sd),
  do.call, args = list(x = r_enwiki$pageviews[r_enwiki$date < split_point])
)
r_enwiki$normalized <- (r_enwiki$pageviews - normalization_constants$mean)/normalization_constants$std.dev

## ----building_features---------------------------------------------------
mlts <- mlts_transform(r_enwiki, date, normalized, p = 7, extras = TRUE, extrasAsFactors = TRUE)
str(mlts)

# Convert factors to dummy variables because neuralnet only supports numeric features:
mlts_categories <- categories(mlts[, c("mlts_extras_weekday", "mlts_extras_month", "mlts_extras_monthday", "mlts_extras_week"), drop = FALSE])
mlts_dummied <- cbind(mlts, dummy(
  mlts[, c("mlts_extras_weekday", "mlts_extras_month", "mlts_extras_monthday", "mlts_extras_week"),
       drop = FALSE],
  object = mlts_categories, int = TRUE
))
str(mlts_dummied, list.len = 30)

## ----splitting_data------------------------------------------------------
# Split:
training_idx <- which(mlts_dummied$dt < split_point)
testing_idx <- which(mlts_dummied$dt >= split_point)

## ----training------------------------------------------------------------
# neuralnet does not support the "y ~ ." formula syntax, so we cheat:
nn_features <- grep("(mlts_lag_[0-9]+)|(mlts_extras_((weekday)|(month)|(monthday)|(week))_.*)", names(mlts_dummied), value = TRUE)
nn_formula <- as.formula(paste("y ~", paste(nn_features, collapse = " + ")))

# Train:
set.seed(0)
nn_model <- neuralnet(
  nn_formula, mlts_dummied[training_idx, c("y", nn_features)],
  linear.output = TRUE, hidden = c(5, 3), algorithm = "sag"
)

## ----forecasting---------------------------------------------------------
# Predict:
nn_predictions <- as.numeric(neuralnet::compute(
  nn_model, mlts_dummied[testing_idx, nn_features])$net.result
)
# Re-scale:
predictions <- data.frame(
  date = mlts_dummied$dt[testing_idx],
  normalized = nn_predictions,
  denormalized = (nn_predictions * normalization_constants$std.dev) + normalization_constants$mean
)

## ----assessment, fig.width = 10, fig.height = 5, out.width = "100%", out.extra='style="border:none;"'----
ggplot(dplyr::filter(r_enwiki, date >= "2016-10-01"),
       aes(x = date, y = pageviews)) +
  geom_line() +
  geom_line(aes(y = denormalized), color = "red",
            data = predictions) +
  theme_minimal() +
  labs(x = "Date", y = "Pageviews",
       title = "Forecast of <https://en.wikipedia.org/wiki/R_(programming_language)> pageviews",
       subtitle = "Red is for predictions made with a neural network with 2 layers containing 5 and 3 hidden neurons, respectively")

## ----application---------------------------------------------------------
new_data <- rbind(
  tail(r_enwiki, 8),
  data.frame(
    date = as.Date("2017-01-31"),
    pageviews = NA,
    normalized = NA
  )
)
# new_data will have two rows, only the second of which we actually care about
new_mlts <- mlts_transform(new_data, date, normalized, p = 7, extras = TRUE, extrasAsFactors = TRUE)
new_mlts <- cbind(
  new_mlts[-1, ], # don't need to forecast known outcome
  dummy(
    new_mlts[, c("mlts_extras_weekday", "mlts_extras_month", "mlts_extras_monthday", "mlts_extras_week"),
             drop = FALSE],
    object = mlts_categories, int = TRUE
  )[-1, ]
)

# Forecast on normalized scale:
nn_forecast <- as.numeric(neuralnet::compute(
  nn_model, new_mlts[, nn_features])$net.result
)

# Re-scale forecast to original scale:
(nn_forecast * normalization_constants$std.dev) + normalization_constants$mean

