# maltese: machine learning for time series

## Installing

```R
# install.packages("devtools")
devtools::install_github("bearloga/maltese")
```

## Example

### Data

The included dataset is a tidy time series of pageviews for R's article on English Wikipedia from 2015-10-01 to 2017-01-30.

```R
library(maltese)
head(r_enwiki)
```

|date       | pageviews|
|:----------|---------:|
|2015-10-01 |      3072|
|2015-10-02 |      2575|
|2015-10-03 |      1431|
|2015-10-04 |      1540|
|2015-10-05 |      3041|
|2015-10-06 |      3695|

We can use `mlts_transform` to convert the data into a machine learning-friendly format with a 7-day lag:

```R
mlts <- mlts_transform(
  dt = r_enwiki$date,
  y = r_enwiki$pageviews,
  p = 7, # how many previous points of data to use as features
  extrasAsFactors = TRUE, # FALSE by default :D
  granularity = "day" # optional, can be automatically detected
)
head(mlts)
```

|   |dt         |    y| mlts_lag_1| mlts_lag_2| mlts_lag_3| mlts_lag_4| mlts_lag_5| mlts_lag_6| mlts_lag_7|mlts_extras_monthday |mlts_extras_weekday |mlts_extras_week |mlts_extras_month |mlts_extras_year |
|:--|:----------|----:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|:--------------------|:-------------------|:----------------|:-----------------|:----------------|
|8  |2015-10-08 | 3278|       3385|       3695|       3041|       1540|       1431|       2575|       3072|8                    |Thursday            |41               |October           |2015             |
|9  |2015-10-09 | 2886|       3278|       3385|       3695|       3041|       1540|       1431|       2575|9                    |Friday              |41               |October           |2015             |
|10 |2015-10-10 | 1692|       2886|       3278|       3385|       3695|       3041|       1540|       1431|10                   |Saturday            |41               |October           |2015             |
|11 |2015-10-11 | 1902|       1692|       2886|       3278|       3385|       3695|       3041|       1540|11                   |Sunday              |41               |October           |2015             |
|12 |2015-10-12 | 3030|       1902|       1692|       2886|       3278|       3385|       3695|       3041|12                   |Monday              |41               |October           |2015             |
|13 |2015-10-13 | 3245|       3030|       1902|       1692|       2886|       3278|       3385|       3695|13                   |Tuesday             |41               |October           |2015             |

### Results

![Example forecast using a neural network](https://github.com/bearloga/maltese/raw/master/neuralnet.png)

See [the vignette](https://bearloga.github.io/maltese/neuralnet.html) for a detailed walkthrough.

## Additional Information

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/bearloga/maltese/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.
