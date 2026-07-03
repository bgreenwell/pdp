# Pima Indians Diabetes Data

Diabetes test results collected by the the US National Institute of
Diabetes and Digestive and Kidney Diseases from a population of women
who were at least 21 years old, of Pima Indian heritage, and living near
Phoenix, Arizona. The data were taken directly from
[`PimaIndiansDiabetes2`](https://rdrr.io/pkg/mlbench/man/PimaIndiansDiabetes.html).

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

## References

Newman, D.J. & Hettich, S. & Blake, C.L. & Merz, C.J. (1998). UCI
Repository of machine learning databases
\[http://www.ics.uci.edu/~mlearn/MLRepository.html\]. Irvine, CA:
University of California, Department of Information and Computer
Science.

Brian D. Ripley (1996), Pattern Recognition and Neural Networks,
Cambridge University Press, Cambridge.

Grace Whaba, Chong Gu, Yuedong Wang, and Richard Chappell (1995), Soft
Classification a.k.a. Risk Estimation via Penalized Log Likelihood and
Smoothing Spline Analysis of Variance, in D. H. Wolpert (1995), The
Mathematics of Generalization, 331-359, Addison-Wesley, Reading, MA.

Friedrich Leisch & Evgenia Dimitriadou (2010). mlbench: Machine Learning
Benchmark Problems. R package version 2.1-1.

## Examples

``` r
head(pima)
#>   pregnant glucose pressure triceps insulin mass pedigree age diabetes
#> 1        6     148       72      35      NA 33.6    0.627  50      pos
#> 2        1      85       66      29      NA 26.6    0.351  31      neg
#> 3        8     183       64      NA      NA 23.3    0.672  32      pos
#> 4        1      89       66      23      94 28.1    0.167  21      neg
#> 5        0     137       40      35     168 43.1    2.288  33      pos
#> 6        5     116       74      NA      NA 25.6    0.201  30      neg
```
