## internal constructor utility functions ----
.SameElements <- function(a, b) return(identical(sort(a), sort(b)))

.get_DataFiles = function(mzdatapath,IonMode,BLANK,ion.id,ion.mode) {

  ##Sanity check
  dirnames <- c("SamplesDir","BlanksDir","PooledQCsDir")

  if(is.list(mzdatapath)) {#mzdatapath must be a list

    if(!.SameElements(dirnames,names(mzdatapath))) { #list names must be correct

      stop("Error: Check the names of your DataDir list")

    }

  }

  ## Selects all datafiles to eventually use for data processing
  mzdatafiles.samples <- list.files(mzdatapath$SamplesDir, recursive = TRUE, full.names = TRUE)
  mzdatafiles.blanks <- list.files(mzdatapath$BlanksDir, recursive = TRUE, full.names = TRUE)
  mzdatafiles.pooledqcs <- list.files(mzdatapath$PooledQCsDir, recursive = TRUE, full.names = TRUE)

  ## Sanity Check on Ion Modes to use for data processing
  if(length(ion.mode) == 0) {
    stop("Error: Not processing any Ion Modes")
  } else {
    if(length(ion.mode) == 1) {
      temp_ion <- match.arg(ion.id,ion.mode, several.ok = FALSE)
      if(IonMode != temp_ion) stop("Error: Ion mode must be either Positive or Negative; check your spelling and capitalization")
    } else {
      if(length(ion.mode) > 1) {
        temp_ion <- match.arg(IonMode,ion.mode, several.ok = FALSE)
        ion.id <- ion.id[which(ion.mode %in% temp_ion)]

      }
    }
  }


  if(BLANK == TRUE){
    DataFiles <- subset(mzdatafiles.blanks, subset = grepl(ion.id, mzdatafiles.blanks, ignore.case = TRUE))
    return(DataFiles)
  } else {
    if(BLANK == FALSE){
      DataFiles <- c(subset(mzdatafiles.samples, subset = grepl(ion.id, mzdatafiles.samples, ignore.case = TRUE)),
                       subset(mzdatafiles.pooledqcs, subset = grepl(ion.id, mzdatafiles.pooledqcs, ignore.case = TRUE))
                       )
    return(DataFiles)
    } else {
          stop("Ion mode must be Positive or Negative.\nBe sure to specify whether to analyze blanks by setting BLANK to a logical. \nSee LUMA vignette for more details.\n\n")
      }
    }
}

.set_PreProcessFileNames = function(IonMode,BLANK) {

  if(IonMode == "Positive" && BLANK == TRUE){

    XCMS.file <- "XCMS_objects_Blanks_Pos"
    CAMERA.file <- "CAMERA_objects_Blanks_Pos"

  } else {

    if(IonMode == "Negative" && BLANK == TRUE){

      XCMS.file <- "XCMS_objects_Blanks_Neg"
      CAMERA.file <- "CAMERA_objects_Blanks_Neg"

    } else {

      if (IonMode == "Positive") {

        XCMS.file <- "XCMS_objects_Pos"
        CAMERA.file <- "CAMERA_objects_Pos"

      } else {

        XCMS.file <- "XCMS_objects_Neg"
        CAMERA.file <- "CAMERA_objects_Neg"

      }

    }

  }

  return(list(XCMS.file,CAMERA.file))

}


.xcmsSanityCheck = function(XCMS.obj) {
  if(length(XCMS.obj@filled) == 0) {
    warning("LUMA works best on xcms data that has been filled.\n\n")
    xset <<- xset <- XCMS.obj
    return(XCMS.obj)
    } else {
      xset4 <<- xset4 <- XCMS.obj
      return(XCMS.obj)
    }
  }


.CAMERASanityCheck = function(CAMERA.obj,CAMERA.file,new_filepaths,BLANK) {

  ##Set default values
  if(missing(new_filepaths)) new_filepaths <- NULL
  if(missing(BLANK)) {

    if ("BLANK" %in% ls(envir = .GlobalEnv)) {
      BLANK <- get("BLANK", envir = .GlobalEnv)
    } else {
      BLANK <- NULL
    }

  }

  #NOTE: Do not pass CAMERA.obj = NULL if file.exists(CAMERA.file) == FALSE; it will only return NULL
  #Check if CAMERA.obj is an xsAnnotate object
  if(class(CAMERA.obj)[1] != "xsAnnotate") {

    if(is.null(CAMERA.obj)) {

      if(file.exists(CAMERA.file)) {

        #Read in saved CAMERA objects file
        cat("\n\nReading in CAMERA objects.\n\n\n")

        load(file = CAMERA.file, verbose = TRUE)
        myvar <- mget(ls())
        myclasses <- lapply(myvar, class)
        myind <- grep("xsAnnotate",myclasses)
        CAMERA.list <- myvar[myind]

        CAMERA.list <- lapply(CAMERA.list, function(x) {
          j = length(x@annoGrp)
          if(j!=0) {
              return(x)
          }
        })

        myclasses <- lapply(CAMERA.list, class)
        myind <- grep("xsAnnotate",myclasses)
        CAMERA.obj <- CAMERA.list[[myind[1]]]

        if(is.null(new_filepaths)) {

          #Sets default value for new_filepaths to existing CAMERA object filepaths
          new_filepaths <- CAMERA.obj@xcmsSet@filepaths

        } else {

            if(is.logical(BLANK)) {

              if(BLANK) {

                new_filepaths <- new_filepaths[grepl("Blanks", new_filepaths)]

              } else {

                if(!BLANK) {

                  new_filepaths <- new_filepaths[!grepl("Blanks", new_filepaths)]

                }
              }

            }

        }


        if(length(grep("Pos",CAMERA.file)) == 1) {

          new_filepaths <- new_filepaths[grepl(ion.id[1],new_filepaths)]

          CAMERA.obj@xcmsSet@filepaths <- new_filepaths

          anposGa <<- anposGa <- CAMERA.obj

        } else {

          if(length(grep("Neg",CAMERA.file)) == 1) {

            new_filepaths <- new_filepaths[grepl(ion.id[2],new_filepaths)]

            CAMERA.obj@xcmsSet@filepaths <- new_filepaths

            annegGa <<- annegGa <- CAMERA.obj

          } else {
            stop("Error: Saved CAMERA objects file must have either Pos or Neg in the filename")
          }
        }
      }

   return(CAMERA.obj)

    } else {
      warning(paste(CAMERA.obj, " is not an xsAnnotate object"))
      return(CAMERA.obj)
    }

  } else {

    if(length(CAMERA.obj@annoGrp) == 0) {

      warning("LUMA works best on CAMERA data that has been annotated.\n\n")

      if(length(grep("Pos",CAMERA.file)) == 1) {

        mz1setpos <<- mz1setpos <- CAMERA.obj

      } else {

        if(length(grep("Neg",CAMERA.file)) == 1) {

          mz1setneg <<- mz1setneg <- CAMERA.obj

        } else {
          stop("Error: Saved CAMERA objects file must have either Pos or Neg in the filename")
          }

      }

      return(CAMERA.obj)

    } else {
      if(length(grep("Pos",CAMERA.file)) == 1)
        anposGa <<- anposGa <- CAMERA.obj
      if(length(grep("Neg",CAMERA.file)) == 1)
        annegGa <<- annegGa <- CAMERA.obj

      return(CAMERA.obj)
    }
  }
}


.get_rules = function(adduct.file) {

  ## Reads in the adduct rules list for CAMERA
    rules <- read.csv(file = adduct.file)

    return(rules)
}


.get_Peaklist = function(object,convert.rt) {
  if(missing(convert.rt))
    convert.rt = TRUE
  peakGa <- getPeaklist(object)
  EIC_ID<-row.names(peakGa)
  peak_data <- cbind(EIC_ID, peakGa)
  ## Converts retention times to min from sec in Peaklist -----
  if(convert.rt) {
    rt.list<-peak_data["rt"]
    rt.min<-apply((as.matrix(rt.list)),1, function(x) x/60)
    peak_data["rt"] <- rt.min
  }
  return(peak_data)
}


.PreProcess_Files = function(XCMS.file,CAMERA.file,mytable,file.base,CAMERA.obj,IonMode) {

  #set Default values
  if(missing(CAMERA.obj))
    CAMERA.obj <- NULL

  if(file.exists(XCMS.file)) {
    cat("Reading in XCMS objects.\n\n")
    load(file = XCMS.file, verbose = TRUE)
    if(file.exists(CAMERA.file)){
      cat("Reading in CAMERA objects.\n\n")
      CAMERA.obj <- .CAMERASanityCheck(CAMERA.obj,CAMERA.file, new_filepaths = DataFiles)

      ## Converts retention times to min from sec in Peaklist -----
      if(length(grep("Pos",CAMERA.file)) == 1)
        CAMERA.obj <- anposGa
      if(length(grep("Neg",CAMERA.file)) == 1)
        CAMERA.obj <- annegGa

      peak_data <- .get_Peaklist(CAMERA.obj)
      write_tbl(mydf = peak_data,
                peak.db = peak_db,
                myname = mytable)
    } else {
      cat("Running CAMERA Only!")
      # Runs CAMERA on datafiles --------------------
      ## Sets the ion mode for CAMERA
      if(IonMode == "Positive"){
        CAMERA_IonMode <- "positive"
      } else {
        if(IonMode == "Negative"){
          CAMERA_IonMode <- "negative"
        }
      }

      ## Code to run CAMERA on XCMS object that has been rt corrected, grouped, and peaks filled
      time.CAMERA <- system.time({
        myresults <- wrap_camera(xcms.obj = xset4,
                                 CAMERA.par = CAMERA.par,
                                 IonMode = CAMERA_IonMode)
        CAMERA.obj <- .CAMERASanityCheck(myresults[[1]],CAMERA.file)
        CAMERA.obj <- .CAMERASanityCheck(myresults[[2]],CAMERA.file)
      })
      cat(paste("PreProcessing with CAMERA took ",round(print(time.CAMERA[3]))," seconds of elapsed time.\n\n",sep = ""))
      # Section END

      # Saves XCMS and CAMERA objects for re-analysis and peaklist for data processing ----
      save(xset,xset4,file=XCMS.file)
      if(length(grep("Pos",CAMERA.file)) == 1)
        save(mz1setpos,anposGa,file=CAMERA.file)
      if(length(grep("Neg",CAMERA.file)) == 1)
        save(mz1setneg,annegGa,file=CAMERA.file)

      ## Converts retention times to min from sec in Peaklist -----
      peak_data <- .get_Peaklist(CAMERA.obj)
      write_tbl(mydf = peak_data,
                peak.db = peak_db,
                myname = "From CAMERA")
    }

  } else {
    if(!file.exists(XCMS.file) & !file.exists(CAMERA.file)) {
      cat("Running XCMS and CAMERA: Be Patient!")

      # Runs XCMS on datafiles --------------------------------------
      time.XCMS <- system.time({
        myresults <- wrap_xcms(mzdatafiles = DataFiles,
                               XCMS.par = XCMS.par,
                               file.base = file.base)
        # XCMS.obj <- .xcmsSanityCheck(myresults[[1]])
        # XCMS.obj <- .xcmsSanityCheck(myresults[[2]])
        xset <<- xset <- myresults[[1]]
        xset4 <<- xset4 <- myresults[[2]]
      })
      cat(paste("PreProcessing with XCMS took ",round(print(time.XCMS[3]))," seconds of elapsed time.\n\n",sep = ""))
      ## Section End
      # Runs CAMERA on datafiles --------------------
      ## Sets the ion mode for CAMERA
      if(IonMode == "Positive"){
        CAMERA_IonMode <- "positive"
      } else {
        if(IonMode == "Negative"){
          CAMERA_IonMode <- "negative"
        }
      }

      ## Code to run CAMERA on XCMS object that has been rt corrected, grouped, and peaks filled
      time.CAMERA <- system.time({
        myresults <- wrap_camera(xcms.obj = xset4,
                                 CAMERA.par = CAMERA.par,
                                 IonMode = CAMERA_IonMode)
        CAMERA.obj <- .CAMERASanityCheck(myresults[[1]],CAMERA.file)
        CAMERA.obj <- .CAMERASanityCheck(myresults[[2]],CAMERA.file)
      })
      cat(paste("PreProcessing with CAMERA took ",round(print(time.CAMERA[3]))," seconds of elapsed time.\n\n",sep = ""))
      # Section END

      # Saves XCMS and CAMERA objects for re-analysis and peaklist for data processing ----
      save(xset,xset4,file=XCMS.file)
      if(length(grep("Pos",CAMERA.file)) == 1)
        save(mz1setpos,anposGa,file=CAMERA.file)
      if(length(grep("Neg",CAMERA.file)) == 1)
        save(mz1setneg,annegGa,file=CAMERA.file)

      ## Converts retention times to min from sec in Peaklist -----
      if(length(grep("Pos",CAMERA.file)) == 1)
        CAMERA.obj <- anposGa
      if(length(grep("Neg",CAMERA.file)) == 1)
        CAMERA.obj <- annegGa

      peak_data <- .get_Peaklist(CAMERA.obj)

      write_tbl(mydf = peak_data,
                peak.db = peak_db,
                myname = mytable)
    } else {
      stop("You must run XCMS before CAMERA! \nPlease remove CAMERA objects from your script directory.\n\n")
    }
    # Section END
  }
  return(xset4)
}

.obj_check = function(x) {
  if ("x" %in% ls(envir = .GlobalEnv)) {
    x <- get("x", envir = .GlobalEnv)
    return(x)
  } else {
      x
    }
}

## END


## Plotting utility functions ----
.LUMA_order = function(object){
  return(object)
}

.convert_EIC = function(EIC) {
  if(is.null(EIC))
    return(EIC) else {
      EIC_split <- strsplit(EIC, split = ";")
      EIC_num <- lapply(EIC_split, function(x) as.numeric(x))
      EICs <- unlist(EIC_num)
      return(EICs)
    }
}

.validate_metgroup <- function(Peak.list.pspec) {
  validate.df <- Peak.list.pspec[order(Peak.list.pspec$metabolite_group), c("MS.ID", "mz", "rt", "Name",
                                                                            "Formula","Annotated.adduct",
                                                                            "isotopes", "adduct",
                                                                            "mono_mass", "metabolite_group",
                                                                            "Correlation.stat")]
  mytbl <- validate.df %>%
    group_by(metabolite_group)

  mytbl <- mytbl %>%
    summarise(max = max(Correlation.stat[Correlation.stat!=max(Correlation.stat)]),
              min = min(Correlation.stat))
  f1 <- which(mytbl$min >= 0.7)
  f2 <- which(mytbl$max <= 0.2)
  clear.groups <- mytbl[(union(f1,f2)),"metabolite_group"] %>%
    data.frame()
  TP.groups <- mytbl[f1,"metabolite_group"] %>%
    data.frame()
  TN.groups <- mytbl[f2,"metabolite_group"] %>%
    data.frame()
  muddy.groups <- mytbl[-(union(f1,f2)),"metabolite_group"] %>%
    data.frame()
  ##Error Check
  if(nrow(clear.groups) != nrow(TP.groups) + nrow(TN.groups))
    stop("The number of true positives and true negatives does not equal the number of clear cut metabolite groups!", call. = FALSE)
  n.col <- ncol(validate.df)
  col.names <- colnames(validate.df)
  validate.df[,(n.col+1:(n.col+3))] <- NA
  colnames(validate.df) <- c(col.names,"Category Score1","Category Score2","Category Score3")
  validate.df$`Category Score2` <- validate.df$Correlation.stat
  validate.df[which(validate.df$metabolite_group %in% TP.groups$metabolite_group),
              c("Category Score1","Category Score3")] <- 1
  validate.df[which(validate.df$metabolite_group %in% TN.groups$metabolite_group),
              c("Category Score1","Category Score3")] <- 0
  x <- which(validate.df$metabolite_group %in% clear.groups$metabolite_group)
  y <- which(validate.df$metabolite_group %in% muddy.groups$metabolite_group)
  myfactor <- factor(NA, levels = c("clear","muddy"))
  myfactor[x] <- "clear"
  myfactor[y] <- "muddy"
  validate.list <- split(validate.df,myfactor)
  return(validate.list)
}
##END


## Database utility functions ----
.trim_table_by_mz <- function(x, min_mz, max_mz) {

  if (is.data.frame(x)) {

    x <- x[x[["mz"]] > min_mz,]
    x <- x[x[["mz"]] < max_mz,]
    return(x)
  } else "Warning: input must be a data frame"
}

.trim_table_by_eic <- function(x, eic) {

  if (is.data.frame(x)) {

    x <- x[which(x[["EIC_ID"]] %in% eic),]
    return(x)
  } else "Warning: input must be a data frame"
}

.trim_table_by_metgroup <- function(x, met) {

  if (is.data.frame(x)) {

    x <- x[which(x[["metabolite_group"]] %in% met),]
    return(x)
  } else "Warning: input must be a data frame"
}


##END


## Calculation utility functions ----

##Checks if a numeric value is a whole number
.isWhole <- function(a) {
  (is.numeric(a) && floor(a) == a) || (is.complex(a) && floor(Re(a)) == Re(a) && floor(Im(a)) == Im(a))
}




## END

## Other module utility functions ----
.gen_res = function(IonMode,search.par,Peak.list,Sample.df,BLANK,QC.id) {
  if (IonMode == "Positive") {
    cor.stat <- as.numeric(search.par[1, "Corr.stat.pos"])
  } else {
    if (IonMode == "Negative") {
      cor.stat <- as.numeric(search.par[1, "Corr.stat.neg"])
    }
  }
  Peaklist_corstat <- Peak.list[which(Peak.list$Correlation.stat >= cor.stat), ]
  if (BLANK == FALSE) {
    sexes <- unique(paste(Sample.df$Sex, "_", sep = ""))
    #Flags all of the sample columns and the metabolite group data
    res <- lapply(colnames(Peaklist_corstat),
                  function(ch) unique(grep(paste(QC.id, paste(strsplit(sexes,"(?<=.[_]$)", perl = TRUE), collapse = "|"),
                                                 "metabolite_group", sep = "|"), ch)))
  } else {
    if (IonMode == "Positive" && BLANK == TRUE) {
      #Flags all of the sample columns and the metabolite group data
      res <- lapply(colnames(Peaklist_corstat),
                    function(ch) unique(grep("_Pos|metabolite_group", ch, ignore.case = TRUE)))
    } else {
      if (IonMode == "Negative" && BLANK == TRUE) {
        #Flags all of the sample columns and the metabolite group data
        res <- lapply(colnames(Peaklist_corstat),
                      function(ch) unique(grep("_Neg|metabolite_group", ch, ignore.case = TRUE)))
      }
    }
  }
  return(list(Peaklist_corstat,res))
}

.gen_IHL = function(Peak.list, Annotated.library, rules, IonMode, lib_db, molweight) {
  ## Creates search list
  search.list <- Peak.list %>% select(EIC_ID, mz, rt) %>% dplyr::collect()

  ## Creates full adduct list for all compounds in the Annotated library
  IHL <- Annotated.library[rep(seq_len(nrow(Annotated.library)), each = nrow(rules)), ]

 ####################################
 #### Multiply by number of moles ###
 ####################################

  x <- rules[,"nmol"]

  #Get only numeric columns
  IHL.temp <- IHL[,sapply(IHL, is.numeric)]

  #Remove columns that have any NA values
  IHL.temp <- IHL.temp[,sapply(IHL.temp, function(x) all(!is.na(x)))]

  #Select Molecular Weight column
  if(molweight %in% names(IHL.temp)) {
    IHL.temp <- IHL.temp[,which(names(IHL.temp) %in% molweight)]
  }

  IHL.temp <- IHL.temp * x
  # IHL.temp <- sweep(IHL.temp, 1, x, "*") #Before R4.0.0


  ####################################
  #### Add/Subtractmass difference ##
  ####################################


  x <- rules[,"massdiff"]
  if (IonMode == "Positive") {
    IHL.temp <- IHL.temp + x
    # IHL.temp <- sweep(IHL.temp, 1, x, "+") #Before R4.0.0

    myion.mode <- "Pos"
    bin <- paste(myion.mode, search.list[["EIC_ID"]], sep = "_")

  } else {
    if (IonMode == "Negative") {

      IHL.temp <- IHL.temp + x
      # IHL.temp <- sweep(IHL.temp, 1, x, "+") #Before R4.0.0

      IHL.temp <- IHL.temp * -1
      # IHL.temp <- sweep(IHL.temp, 1, -1, "*") #Before R4.0.0

      myion.mode <- "Neg"
      bin <- paste(myion.mode, search.list[["EIC_ID"]], sep = "_")

    } else {

      stop("You must include the ionization mode!")

    }
  }

  ####################################
  #### Multiply by charge     ########
  ####################################


  x <- rules$charge

  IHL.temp <- IHL.temp / x
  # IHL.adduct.data <- sweep(IHL.temp, 1, x, "/") #Before R4.0.0

  IHL[, "mz"] <- IHL.temp
  IHL[, "adduct"] <- rules[,"name"]
  IHL <- IHL[which(IHL$Ion.Mode %in% myion.mode),]

  copy_to(lib_db, IHL, name = paste("Annotated Library", myion.mode, sep = "_"), temporary = FALSE, overwrite = TRUE)
  return(list(search.list,bin,myion.mode))
}

.mypaste = function(pheno.list, i) {
  summarise(pheno.list, X = paste0(pheno.list[, i], collapse = ";"))
}
##END
