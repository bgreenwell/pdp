# Boston Housing Data

Data on median housing values from 506 census tracts in the suburbs of
Boston from the 1970 census. This data frame is a corrected version of
the original data by Harrison and Rubinfeld (1978) with additional
spatial information. The data were taken directly from
[`mlbench::BostonHousing2()`](https://rdrr.io/pkg/mlbench/man/BostonHousing.html)
and unneeded columns (i.e., name of town, census tract, and the
uncorrected median home value) were removed.

## Usage

``` r
data(boston)
```

## Format

A data frame with 506 rows and 16 variables.

- `lon` Longitude of census tract.

- `lat` Latitude of census tract.

- `cmedv` Corrected median value of owner-occupied homes in USD 1000's

- `crim` Per capita crime rate by town.

- `zn` Proportion of residential land zoned for lots over 25,000 sq.ft.

- `indus` Proportion of non-retail business acres per town.

- `chas` Charles River dummy variable (= 1 if tract bounds river; 0
  otherwise).

- `nox` Nitric oxides concentration (parts per 10 million).

- `rm` Average number of rooms per dwelling.

- `age` Proportion of owner-occupied units built prior to 1940.

- `dis` Weighted distances to five Boston employment centers.

- `rad` Index of accessibility to radial highways.

- `tax` Full-value property-tax rate per USD 10,000.

- `ptratio` Pupil-teacher ratio by town.

- `b` \$1000(B - 0.63)^2\$ where B is the proportion of blacks by town.

- `lstat` Percentage of lower status of the population.

## References

Harrison, D. and Rubinfeld, D.L. (1978). Hedonic prices and the demand
for clean air. Journal of Environmental Economics and Management, 5,
81-102.

Gilley, O.W., and R. Kelley Pace (1996). On the Harrison and Rubinfeld
Data. Journal of Environmental Economics and Management, 31, 403-405.

Newman, D.J. & Hettich, S. & Blake, C.L. & Merz, C.J. (1998). UCI
Repository of machine learning databases
[http://www.ics.uci.edu/~mlearn/MLRepository.html](http://www.ics.uci.edu/~mlearn/MLRepository.md)
Irvine, CA: University of California, Department of Information and
Computer Science.

Pace, R. Kelley, and O.W. Gilley (1997). Using the Spatial Configuration
of the Data to Improve Estimation. Journal of the Real Estate Finance
and Economics, 14, 333-340.

Friedrich Leisch & Evgenia Dimitriadou (2010). mlbench: Machine Learning
Benchmark Problems. R package version 2.1-1.

## Examples

``` r
head(boston)
#>        lon     lat cmedv    crim zn indus chas   nox    rm  age    dis rad tax
#> 1 -70.9550 42.2550  24.0 0.00632 18  2.31    0 0.538 6.575 65.2 4.0900   1 296
#> 2 -70.9500 42.2875  21.6 0.02731  0  7.07    0 0.469 6.421 78.9 4.9671   2 242
#> 3 -70.9360 42.2830  34.7 0.02729  0  7.07    0 0.469 7.185 61.1 4.9671   2 242
#> 4 -70.9280 42.2930  33.4 0.03237  0  2.18    0 0.458 6.998 45.8 6.0622   3 222
#> 5 -70.9220 42.2980  36.2 0.06905  0  2.18    0 0.458 7.147 54.2 6.0622   3 222
#> 6 -70.9165 42.3040  28.7 0.02985  0  2.18    0 0.458 6.430 58.7 6.0622   3 222
#>   ptratio      b lstat
#> 1    15.3 396.90  4.98
#> 2    17.8 396.90  9.14
#> 3    17.8 392.83  4.03
#> 4    18.7 394.63  2.94
#> 5    18.7 396.90  5.33
#> 6    18.7 394.12  5.21
```
