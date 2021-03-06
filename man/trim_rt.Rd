% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trimming-functions.R
\name{trim_rt}
\alias{trim_rt}
\alias{trim_rt.mz}
\alias{trim_rt.monoMass}
\title{Trims by retention time}
\usage{
trim_rt(object, Peak.list, void.rt, rt.list)

\method{trim_rt}{mz}(object, Peak.list, void.rt, rt.list = Peak.list["rt"][[1]])

\method{trim_rt}{monoMass}(object, Peak.list, void.rt, rt.list = Peak.list["rt"][[1]])
}
\arguments{
\item{object}{used for method dispatch. Can be any object. See usage for
details}

\item{Peak.list}{data frame. Must have column \code{Correlation.stat}.
Should contain output columns from XCMS and CAMERA, and additional columns
from \code{match_Annotation}, \code{calc_minfrac}, \code{calc_corrstat} and
\code{plot_metgroup} functions.}

\item{void.rt}{numeric retention time cutoff value corresponding to the LC
void volume}

\item{rt.list}{numeric vector containing retention times for all features or
compounds}
}
\description{
Removes components with retention times smaller than the user
  specified threshold. See \code{remove_void_volume} and
  \code{CullVoidVolume} for examples that use this function.
}
