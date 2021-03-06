% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tidy.R
\name{by_row_plot}
\alias{by_row_plot}
\title{Apply a function to each row of a data frame and return a data frame with new column of plots}
\usage{
by_row_plot(.d, ..f, .to = "panel")
}
\arguments{
\item{.d}{A data frame.}

\item{..f}{A function to apply to each row. It should return a valid panel object (such as a ggplot2 / lattice / htmlwidget object).}

\item{.to}{Name of output column (defaults to "panel").}
}
\description{
Apply a function to each row of a data frame and return a data frame with new column of plots
}
\details{
See \code{\link[purrrlyr]{by_row}}
}
\examples{
\dontrun{
library(tidyr)
library(purrr)
library(rbokeh)
iris \%>\%
  nest(-Species) \%>\%
  mutate(mod = map(data, ~ lm(Sepal.Length ~ Sepal.Width, data = .x))) \%>\%
  by_row_panel(function(x) {
    figure(xlab = "Sepal.Width", ylab = "Sepal.Length") \%>\%
      ly_points(x$data[[1]]$Sepal.Width, x$data[[1]]$Sepal.Length) \%>\%
      ly_abline(x$mod[[1]])
  }) \%>\%
  trelliscope(name = "iris")
}
}
