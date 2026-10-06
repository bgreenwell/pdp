# Synthetic Diabetes Data

A fully synthetic diabetes data set created by Matthias Templ to mimic
the Pima Indians diabetes data analyzed by Smith et al. (1988). Every
value is synthetic and no row corresponds to a real person. The data
were taken directly from
[mlbench::SynthDiabetes2](https://rdrr.io/pkg/mlbench/man/SynthDiabetes.html),
which mimics the missing-value pattern of the original data (physically
impossible zeros are coded as `NA`).

## Usage

``` r
data(pima)
```

## Format

A data frame with 768 observations on 9 variables.

- `pregnant` Number of times pregnant.

- `glucose` Plasma glucose concentration (glucose tolerance test).

- `pressure` Diastolic blood pressure (mm Hg).

- `triceps` Triceps skin fold thickness (mm).

- `insulin` 2-Hour serum insulin (mu U/ml).

- `mass` Body mass index (weight in kg/(height in m)^2).

- `pedigree` Diabetes pedigree function.

- `age` Age (years).

- `diabetes` Factor indicating the diabetes test result (`neg`/`pos`).

## Details

Earlier versions of pdp shipped a copy of the original data (taken from
`mlbench::PimaIndiansDiabetes2`) under this name. The original data had
most likely been shared without the consent of the participants, and
both the UCI repository and mlbench (as of version 2.1-11) have stopped
distributing it. The `pima` name is kept so existing code continues to
run, but results will differ from those based on the original data.

## References

Smith, J.W., Everhart, J.E., Dickson, W.C., Knowler, W.C., and Johannes,
R.S. (1988). Using the ADAP Learning Algorithm to Forecast the Onset of
Diabetes Mellitus. In Proceedings of the Symposium on Computer
Applications and Medical Care, 261-265.

Brian D. Ripley (1996), Pattern Recognition and Neural Networks,
Cambridge University Press, Cambridge.

Grace Whaba, Chong Gu, Yuedong Wang, and Richard Chappell (1995), Soft
Classification a.k.a. Risk Estimation via Penalized Log Likelihood and
Smoothing Spline Analysis of Variance, in D. H. Wolpert (1995), The
Mathematics of Generalization, 331-359, Addison-Wesley, Reading, MA.

Friedrich Leisch & Evgenia Dimitriadou (2026). mlbench: Machine Learning
Benchmark Problems. R package version 2.1-11.

## Examples

``` r
head(pima)
#>   pregnant glucose pressure triceps insulin mass pedigree age diabetes
#> 1        0     194       50      45      NA 28.5    0.240  28      neg
#> 2        8     129       84      NA      NA 27.6    0.828  44      pos
#> 3        2     132       72      42      NA 38.2    0.696  26      neg
#> 4        6     184       62      NA      NA 24.7    0.192  39      neg
#> 5        4     108       58      32      NA 31.6    0.178  22      neg
#> 6       10     117       80      13      NA 30.1    0.383  58      pos
```
