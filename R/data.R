#' Boston Housing Data
#'
#' Data on median housing values from 506 census tracts in the suburbs of Boston
#' from the 1970 census. This data frame is a corrected version of the original
#' data by Harrison and Rubinfeld (1978) with additional spatial information.
#' The data were taken directly from \code{\link[mlbench]{BostonHousing2}} and
#' unneeded columns (i.e., name of town, census tract, and the uncorrected
#' median home value) were removed.
#'
#' @docType data
#' @keywords datasets
#' @format A data frame with 506 rows and 16 variables.
#' \itemize{
#'   \item \code{lon} Longitude of census tract.
#'   \item \code{lat} Latitude of census tract.
#'   \item \code{cmedv} Corrected median value of owner-occupied homes in USD 1000's
#'   \item \code{crim} Per capita crime rate by town.
#'   \item \code{zn} Proportion of residential land zoned for lots over 25,000 sq.ft.
#'   \item \code{indus} Proportion of non-retail business acres per town.
#'   \item \code{chas} Charles River dummy variable (= 1 if tract bounds river; 0 otherwise).
#'   \item \code{nox} Nitric oxides concentration (parts per 10 million).
#'   \item \code{rm} Average number of rooms per dwelling.
#'   \item \code{age} Proportion of owner-occupied units built prior to 1940.
#'   \item \code{dis} Weighted distances to five Boston employment centers.
#'   \item \code{rad} Index of accessibility to radial highways.
#'   \item \code{tax} Full-value property-tax rate per USD 10,000.
#'   \item \code{ptratio} Pupil-teacher ratio by town.
#'   \item \code{b} $1000(B - 0.63)^2$ where B is the proportion of blacks by town.
#'   \item \code{lstat} Percentage of lower status of the population.
#' }
#' @name boston
#'
#' @usage
#' data(boston)
#'
#' @examples
#' head(boston)
#'
#' @references
#' Harrison, D. and Rubinfeld, D.L. (1978). Hedonic prices and the demand for
#' clean air. Journal of Environmental Economics and Management, 5, 81-102.
#'
#' Gilley, O.W., and R. Kelley Pace (1996). On the Harrison and Rubinfeld Data.
#' Journal of Environmental Economics and Management, 31, 403-405.
#'
#' Newman, D.J. & Hettich, S. & Blake, C.L. & Merz, C.J. (1998). UCI Repository
#' of machine learning databases
#' [http://www.ics.uci.edu/~mlearn/MLRepository.html] Irvine, CA: University of
#' California, Department of Information and Computer Science.
#'
#' Pace, R. Kelley, and O.W. Gilley (1997). Using the Spatial Configuration of
#' the Data to Improve Estimation. Journal of the Real Estate Finance and
#' Economics, 14, 333-340.
#'
#' Friedrich Leisch & Evgenia Dimitriadou (2010). mlbench: Machine Learning
#' Benchmark Problems. R package version 2.1-1.
NULL


#' Pima Indians Diabetes Data
#'
#' Diabetes test results collected by the the US National Institute of Diabetes
#' and Digestive and Kidney Diseases from a population of women who were at
#' least 21 years old, of Pima Indian heritage, and living near Phoenix,
#' Arizona. The data were taken directly from
#' \code{\link[mlbench]{PimaIndiansDiabetes2}}.
#'
#' @docType data
#' @keywords datasets
#' @format A data frame with 768 observations on 9 variables.
#' \itemize{
#'   \item \code{pregnant} Number of times pregnant.
#'   \item \code{glucose} Plasma glucose concentration (glucose tolerance test).
#'   \item \code{pressure} Diastolic blood pressure (mm Hg).
#'   \item \code{triceps} Triceps skin fold thickness (mm).
#'   \item \code{insulin} 2-Hour serum insulin (mu U/ml).
#'   \item \code{mass} Body mass index (weight in kg/(height in m)^2).
#'   \item \code{pedigree} Diabetes pedigree function.
#'   \item \code{age} Age (years).
#'   \item \code{diabetes} Factor indicating the diabetes test result (\code{neg}/\code{pos}).
#' }
#' @name pima
#'
#' @usage
#' data(pima)
#'
#' @examples
#' head(pima)
#'
#' @references
#' Newman, D.J. & Hettich, S. & Blake, C.L. & Merz, C.J. (1998). UCI Repository
#' of machine learning databases
#' [http://www.ics.uci.edu/~mlearn/MLRepository.html]. Irvine, CA: University of
#' California, Department of Information and Computer Science.
#'
#' Brian D. Ripley (1996), Pattern Recognition and Neural Networks, Cambridge
#' University Press, Cambridge.
#'
#' Grace Whaba, Chong Gu, Yuedong Wang, and Richard Chappell (1995), Soft
#' Classification a.k.a. Risk Estimation via Penalized Log Likelihood and
#' Smoothing Spline Analysis of Variance, in D. H. Wolpert (1995), The
#' Mathematics of Generalization, 331-359, Addison-Wesley, Reading, MA.
#'
#' Friedrich Leisch & Evgenia Dimitriadou (2010). mlbench: Machine Learning
#' Benchmark Problems. R package version 2.1-1.
NULL
