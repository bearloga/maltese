mlts 0.1.1
----------

- Made extras (e.g. day of week) optional:

```R
mlts_transform(head(r_enwiki), date, pageviews)
```

|dt         |    y| mlts_lag_1|
|:----------|----:|----------:|
|2015-10-02 | 2575|       3072|
|2015-10-03 | 1431|       2575|
|2015-10-04 | 1540|       1431|
|2015-10-05 | 3041|       1540|
|2015-10-06 | 3695|       3041|

vs.

```R
mlts_transform(head(r_enwiki), "date", "pageviews", extras = TRUE, extrasAsFactors = TRUE)
```

|dt         |    y|mlts_extras_monthday |mlts_extras_weekday |mlts_extras_week |mlts_extras_month |mlts_extras_year | mlts_lag_1|
|:----------|----:|:--------------------|:-------------------|:----------------|:-----------------|:----------------|----------:|
|2015-10-02 | 2575|2                    |Friday              |40               |October           |2015             |       3072|
|2015-10-03 | 1431|3                    |Saturday            |40               |October           |2015             |       2575|
|2015-10-04 | 1540|4                    |Sunday              |40               |October           |2015             |       1431|
|2015-10-05 | 3041|5                    |Monday              |40               |October           |2015             |       1540|
|2015-10-06 | 3695|6                    |Tuesday             |40               |October           |2015             |       3041|

- Made `mlts_transform` more tidyversal (pipe-friendly). For example:

```R
library(magrittr)

mlts <- r_enwiki %>%
  mlts_transform(date, pageviews)
```

mlts 0.1.0
----------

- Initial MVP release
- [Vignette](https://bearloga.github.io/maltese/neuralnet.html) for using [neuralnet package](https://cran.r-project.org/package=neuralnet)
