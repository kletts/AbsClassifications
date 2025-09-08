
source("R/overview.R")


purrr::pwalk(classifications, \(Abbrev, Version, Function, ...) {
        if (Version=="") {
          fn <- file.path("extdata", paste(Abbrev, "parquet", sep="."))
          args <- list()
        } else {
          args <- list(version=Version)
          fn <- file.path("extdata", paste(Version, "parquet", sep="."))
        }
        data <- do.call(Function, args=args)
        arrow::write_parquet(data, fn)
    })
