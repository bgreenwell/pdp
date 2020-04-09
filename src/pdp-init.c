#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>
#include "pdp.h"

/* FIXME:
 Check these declarations against the C/Fortran source code.
 */

/* .Call calls */
extern SEXP PartialGBM(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"PartialGBM", (DL_FUNC) &PartialGBM, 10},
  {NULL, NULL, 0}
};

R_CMethodDef CEntries[] = {
  {"in_out", (DL_FUNC) &in_out, 8},
  {NULL, NULL, 0}
};

void R_init_pdp(DllInfo *dll)
{
  R_registerRoutines(dll, CEntries, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
