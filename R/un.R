
utils::globalVariables(c("code", "title"))

#' Get COICOP
#' @description Downloads the United Nation's Classification of Individual Consumption According to Purpose
#' @param version character, one of
#'  - `COICOPv2018` version 2018
#'  - `COICOPv1999` version 1999
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom stats setNames
#' @importFrom utils download.file
#' @importFrom dplyr mutate filter
#' @importFrom stringr str_count str_sub
#' @importFrom readxl read_xlsx

get_COICOP <- function(version=c("COICOPv2018", "COICOPv1999")) {
  version <- match.arg(version)
  url <- "https://unstats.un.org/unsd/classifications/Econ/Download/COICOP2018_COICOP1999_correspondence_table_final.xlsx"
  tempfile <- file.path(tempdir(), "temp.xls")
  download.file(url, tempfile, mode = "wb")
  str <- list(
    "COICOPv2018"=list(sheet="COICOP 2018",
                       range="B2:C872"),
    "COICOPv1999"=list(sheet="COICOP 1999",
                       range="A3:B231"))
  data <- readxl::read_xlsx(
    path=tempfile,
    sheet=str[[version]]$sheet,
    col_types = "text",
    col_names=c("code", "title"),
    range = str[[version]]$range) |>
    mutate(Level= str_count(code, "\\.") + 1)
  if (version=="COICOPv2018") {
    data <- data |>
      filter(Level == 4) |>
      mutate(
        COICOP_l1=labelled(str_sub(code, 1, 2),
                          with(subset(data, Level==1), setNames(code, title))),
        COICOP_l2=labelled(str_sub(code, 1, 4),
                          with(subset(data, Level==2), setNames(code, title))),
        COICOP_l3=labelled(str_sub(code, 1, 6),
                          with(subset(data, Level==3), setNames(code, title))),
        COICOP_l4=labelled(code,
                          setNames(code, title)),
        .keep = "none")
  } else {
    data <- data |>
      filter(Level == 3) |>
      mutate(
        COICOP_l1=labelled(str_sub(code, 1, 2),
                           with(subset(data, Level==1), setNames(code, title))),
        COICOP_l2=labelled(str_sub(code, 1, 4),
                           with(subset(data, Level==2), setNames(code, title))),
        COICOP_l3=labelled(code,
                           setNames(code, title)),
        .keep = "none")
  }
  return(data) }
