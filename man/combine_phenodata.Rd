% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parser-functions.R
\name{combine_phenodata}
\alias{combine_phenodata}
\title{Combine phenotype data in Peak.list}
\usage{
combine_phenodata(
  Sample.df,
  Peak.list,
  Summed.list,
  search.par,
  QC.id,
  BLANK,
  IonMode
)
}
\arguments{
\item{Sample.df}{a data frame with class info as columns.  Must contain a
separate row entry for each unique sex/class combination. Must contain the
columns \code{"Sex","Class","n","Endogenous"}.}

\item{Peak.list}{data frame. Must have the columns \code{"Correlation.stat",
"metabolite_group", "mono_mass"}.  Should contain output columns from
\code{XCMS} and ]code{CAMERA}, and additional columns from functions
\code{match_Annotation()}, \code{calc_minfrac()}, \code{CAMERAParser()},
\code{plot_metgroup()}.}

\item{Summed.list}{data frame containing metabolite group as first column and
the rest summed intensities for each sample}

\item{search.par}{a single-row data frame with 11 variables containing
user-defined search parameters. Must contain the columns
\code{"ppm"},\code{"rt"},\code{"Voidrt"},\code{"Corr.stat.pos"},\code{"Corr.stat.neg"},
 \code{"CV"},\code{"Minfrac"}, \code{"Endogenous"},
\code{"Solvent"},\code{"gen.plots"}, \code{"keep.singletons"}.}

\item{QC.id}{character vector specifying identifier in filename designating a
Pooled QC sample.  Only the first value will be used.  Default is
\code{"Pooled_QC_"}}

\item{BLANK}{a logical indicating whether blanks are being evaluated}

\item{IonMode}{a character string defining the ionization mode.  Must be one
of \code{c("Positive","Negative")}.}
}
\value{
Peak.list.summed with the munged phenotype columns up front followed
  by QC and sample columns
}
\description{
Combine phenotype data for each metabolite group in Peak.list
  with summed intensity values
}
\examples{
library(LUMA)
file <- system.file('extdata','Search_Parameters.txt', package = "LUMA") # is
# case sensitive on Linux
search.par <- read.table(file, sep = "\t", header = TRUE) #Ignore Warning message
file2 <- system.file('extdata','Sample_Class.txt', package = "LUMA") # is
# case sensitive on Linux
Sample.df <- read.table(file2, sep = "\t", header = TRUE) #Ignore Warning message
Peak.list <- LUMA::Peaklist_Pos$output_parsed
Summed.list <- sum_features(Peak.list = Peak.list, Sample.df = Sample.df ,
                       search.par = search.par, BLANK = FALSE, IonMode = "Positive")
test <- combine_phenodata(Sample.df = Sample.df, Peak.list = Peak.list,
Summed.list = Summed.list, search.par = search.par, BLANK = FALSE, IonMode =
"Positive")
nrow(Peak.list) - nrow(test) ##Combines multiple features into single entries per metabolite
}
