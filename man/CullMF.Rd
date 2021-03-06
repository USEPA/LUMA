% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Data_Culling-Modules.R
\name{CullMF}
\alias{CullMF}
\title{Culls the Peak.list by Minimum Fraction}
\usage{
CullMF(from.table, to.table, method)
}
\arguments{
\item{from.table}{from which table should LUMA pull the Peak.list}

\item{to.table}{to which should LUMA save the modified Peak.list}

\item{method}{which method to apply to trim by minimum fraction values.  See
\code{trim_minfrac()} for details.}
}
\description{
Culls the Peak.list by removing all components with minimum
  fraction less than the user-specified cutoff. See \code{trim_minfrac()} for
  more details. For examples, see \code{InitWorkflow()} and vignettes.
}
