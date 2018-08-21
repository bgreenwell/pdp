# Write all pdp R package dependencies to a bib file
pkgs <- c(desc::desc_get_deps()$package, "doMC", "doParallel", "ICEbox", "grid",
          "latticeExtra", "pdp", "plotmo")
knitr::write_bib(pkgs, file = "tools/pdp-pkg.bib")
