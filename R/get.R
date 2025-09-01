
#' Get OSCA
#' @description Downloads the Occupation Standard Classification for Australia
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export

get_OSCA <- function(...) {
  get_ANZSCO("OSCAv2024")
  }

#' Get ANZSCO
#' @description Downloads the Australian and New Zealand Standard Classification of Occupation
#' @param version character, one of
#'  - `ANZSCOv2021` version 2021
#'  - `ANZSCOv2022` version 2022
#'  - `OSCAv2024` version Occupation Standard Classification for Australia for 2024
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when
#' @importFrom stringr str_detect
#' @importFrom tidyr fill
#' @importFrom readxl read_xlsx read_xls

get_ANZSCO <- function(version=NULL) {
  src <- list(
    "ANZSCOv2021"=list(
      range="A11:G1601",
      sheet="Table 5",
      prefix="ANZSCO",
      url="https://www.abs.gov.au/statistics/classifications/anzsco-australian-and-new-zealand-standard-classification-occupations/2021/anzsco%202021%20structure%20v1.2%20062023.xlsx"),
    "ANZSCOv2022"=list(
      range="A11:G1607",
      sheet="Table 5",
      prefix="ANZSCO",
      url="https://www.abs.gov.au/statistics/classifications/anzsco-australian-and-new-zealand-standard-classification-occupations/2022/anzsco%202022%20structure%20062023.xlsx"),
    "OSCAv2024"=list(
      range="A6:G1754",
      sheet="Table 5",
      prefix="OSCA",
      url="https://www.abs.gov.au/statistics/classifications/osca-occupation-standard-classification-australia/2024-version-1-0/data-downloads/OSCA%20structure.xlsx")
  )
  if (is.null(version)) {
    version = names(src)[1]
    print(paste("returning", version))
  }
  if (!version %in% names(src)) {
    stop(paste("version not one of", paste(names(src), collapse = ", ")))
  }
  tempfile <- file.path(tempdir(), "temp.xlsx")
  download.file(src[[version]]$url, tempfile, mode = "wb")
  data <- read_xlsx(tempfile,
                    sheet=src[[version]]$sheet,
                    range=src[[version]]$range,
                    col_types="text",
                    col_names=c("Code1", "Code2", "Code3", "Code4", "Code5", "Occupation", "SkillLevel"))  |>
    mutate(Level = case_when(str_detect(Code1, "^\\d{1}$") ~ 1,
                             str_detect(Code2, "^\\d{2}$") ~ 2,
                             str_detect(Code3, "^\\d{3}$") ~ 3,
                             str_detect(Code4, "^\\d{4}$") ~ 4,
                             str_detect(Code5, "^\\d{5,}$") ~ 5,
                             TRUE ~ NA)) |>
    fill(Code1, Code2, Code3, Code4, .direction = "down")
  newnames <- paste(src[[version]]$prefix, 1:5, sep="_l")
  data <- data |>
    filter(Level==5) |>
    mutate(
      !!newnames[1] := labelled(Code1,
                           with(subset(data, Level==1), setNames(Code1, Code2))),
      !!newnames[2] := labelled(Code2,
                           with(subset(data, Level==2), setNames(Code2, Code3))),
      !!newnames[3] := labelled(Code3,
                           with(subset(data, Level==3), setNames(Code3, Code4))),
      !!newnames[4]  := labelled(Code4,
                           with(subset(data, Level==4), setNames(Code4, Code5))),
      !!newnames[5]  := labelled(Code5,
                           setNames(Code5, Occupation)),
      .keep = "none")
  return(data) }

#' Get ANZSIC
#' @description Downloads the Australian and New Zealand Standard Industry Classification
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when
#' @importFrom stringr str_detect
#' @importFrom tidyr fill
#' @importFrom rvest read_html html_table

get_ANZSIC <- function(...) {
  url <- "https://www.abs.gov.au/statistics/classifications/australian-and-new-zealand-standard-industrial-classification-anzsic/2006-revision-2-0/numbering-system-and-titles/division-subdivision-group-and-class-codes-and-titles"
  src <- read_html(url) |> html_table(header=FALSE, na.strings = "")
  data <- src[[1]] |>
    mutate(Level = case_when(str_detect(X1, "^\\w{1}$") ~ 1,
                             str_detect(X2, "^\\d{2}$") ~ 2,
                             str_detect(X3, "^\\d{3}$") ~ 3,
                             str_detect(X4, "^\\d{4}$") ~ 4,
                             TRUE ~ NA)) |>
    fill(X1, X2, X3, X4, .direction = "down")
  data <- data |>
    filter(Level==4) |>
    mutate(
      ANZSIC_l1=labelled(X1,
                         with(subset(data, Level==1), setNames(X1, X5))),
      ANZSIC_l2=labelled(X2,
                         with(subset(data, Level==2), setNames(X2, X5))),
      ANZSIC_l3=labelled(X3,
                         with(subset(data, Level==3), setNames(X3, X5))),
      ANZSIC_l4=labelled(X4,
                         with(subset(data, Level==4), setNames(X4, X5))),
      .keep = "none")
  return(data) }

#' Get ASCRG
#' @description Downloads the Australian Standard Classification of Religious Groups
#' @param version character, one of
#'  - `ASCRGv2024` version 2024
#'  - `ASCRGv2016` version 2016
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when
#' @importFrom stringr str_detect
#' @importFrom tidyr fill
#' @importFrom readxl read_xlsx read_xls

get_ASCRG <- function(version=NULL) {
  src <- list(
    "ASCRGv2024"=list(
      sheet="Table 1.3",
      range="A8:D197",
      codestr=function(Code1, Code2, Code3) {
        case_when(str_detect(Code1, "^\\d{2}$") ~ 1,
                  str_detect(Code2, "^\\d{4}$") ~ 2,
                  str_detect(Code3, "^\\d{6}$") ~ 3,
                  TRUE ~ NA) }),
    "ASCRGv2016"=list(
      sheet="Table 3.2",
      range="A6:D195",
      codestr=function(Code1, Code2, Code3) {
        case_when(str_detect(Code1, "^\\d{1}$")   ~ 1,
                  str_detect(Code2, "^\\d{2,3}$") ~ 2,
                  str_detect(Code3, "^\\d{4}$")   ~ 3,
                  TRUE ~ NA)})
  )
  if (is.null(version)) {
    version = names(src)[1]
    print(paste("returning", version))
  }
  if (!version %in% names(src)) {
    stop(paste("version not one of", paste(names(src), collapse = ", ")))
  }
  url <- "https://www.abs.gov.au/statistics/classifications/australian-standard-classification-religious-groups/mar-2024/ASCRG_12660DO0001_202303.xlsx"
  tempfile <- file.path(tempdir(), "temp.xlsx")
  download.file(url, tempfile, mode = "wb")
  data <- read_xlsx(tempfile,
                    sheet=src[[version]]$sheet,
                    range=src[[version]]$range,
                    col_names= c("Code1", "Code2", "Code3", "Religon"),
                    col_types = "text")  |>
    mutate(Level = src[[version]]$codestr(Code1, Code2, Code3)) |>
    fill(Code1, Code2, Code3, .direction = "down")
  data <- data |>
    filter(Level==3) |>
    mutate(
      ASCRG_l1 = labelled(Code1,
                          with(subset(data, Level==1), setNames(Code1, Code2))),
      ASCRG_l2 = labelled(Code2,
                          with(subset(data, Level==2), setNames(Code2, Code3))),
      ASCRG_l3 = labelled(Code3,
                          setNames(Code3, Religon)),
      .keep = "none")
  return(data) }

#' Get ASCED
#' @description Download the Australian Standard Classification of Education
#' @param version character, one of
#'  - `ASCEDvLevel` version Level of Education
#'  - `ASCEDvField` version Field of Education
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when
#' @importFrom stringr str_detect
#' @importFrom tidyr fill
#' @importFrom readxl read_xlsx read_xls

get_ASCED <- function(version=c("ASCEDvLevel", "ASCEDvField")) {
  version <- match.arg(version)
  src <- list(
    "ASCEDvLevel"=list(
      sheet="Table 1",
      range="A8:D95",
      codestr=function(Code1, Code2, Code3) {
                case_when(str_detect(Code1, "^\\d{1}$") ~ 1,
                         str_detect(Code2, "^\\d{2}$") ~ 2,
                         str_detect(Code3, "^\\d{3}$") ~ 3,
                         TRUE ~ NA)}),
    "ASCEDvField"=list(
      sheet="Table 2",
      range="A8:D446",
      codestr=function(Code1, Code2, Code3) {
                case_when(str_detect(Code1, "^\\d{2}$") ~ 1,
                          str_detect(Code2, "^\\d{4}$") ~ 2,
                          str_detect(Code3, "^\\d{6}$") ~ 3,
                          TRUE ~ NA) })
  )
  url <- "https://www.abs.gov.au/statistics/classifications/australian-standard-classification-education-asced/2001/1272.0%20australian%20standard%20classification%20of%20education%20%28asced%29%20structures.xlsx"
  tempfile <- file.path(tempdir(), "temp.xlsx")
  download.file(url, tempfile, mode = "wb")
  data <- read_xlsx(tempfile,
                    sheet=src[[version]]$sheet,
                    range=src[[version]]$range,
                    col_names= c("Code1", "Code2", "Code3", "Subject"),
                    col_types = "text") |>
    mutate(Level =src[[version]]$codestr(Code1, Code2, Code3)) |>
    fill(Code1, Code2, Code3, .direction = "down")
  data <- data |>
    filter(Level==3) |>
    mutate(
      ASCED_l1 = labelled(Code1,
                          with(subset(data, Level==1), setNames(Code1, Code2))),
      ASCED_l2 = labelled(Code2,
                          with(subset(data, Level==2), setNames(Code2, Code3))),
      ASCED_l3 = labelled(Code3,
                          setNames(Code3, Subject)),
      .keep = "none")
  return(data) }

#' Get ASCL
#' @description Download the Australian Standard Classification of Languages
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when distinct
#' @importFrom stringr str_detect
#' @importFrom tidyr fill
#' @importFrom readxl read_xlsx read_xls

get_ASCL <- function(...) {
  url <- "https://www.abs.gov.au/statistics/classifications/australian-standard-classification-languages-ascl/2025/ASCL%20structure.xlsx"
  tempfile <- file.path(tempdir(), "temp.xlsx")
  download.file(url, tempfile, mode = "wb")
  data <- read_xlsx(tempfile,
                    sheet="Table 1.4",
                    range="A6:H449",
                    col_types="text",
                    col_names=c("Code1", "Code1nm",
                                "Code2", "Code2nm",
                                "Code3", "Code3nm",
                                "Code4", "Language"))
  data <- data |>
    distinct(Code4, .keep_all = TRUE) |>
    fill(Code1, Code2, Code3, .direction = "down") |>
    mutate(
      ASCL_l1 = labelled(Code1,
                         with(subset(data, !is.na(Code1)), setNames(Code1, Code1nm))),
      ASCL_l2 = labelled(Code2,
                         with(subset(data, !is.na(Code2)), setNames(Code2, Code2nm))),
      ASCL_l3 = labelled(Code3,
                         with(subset(data, !is.na(Code3)), setNames(Code3, Code3nm))),
      ASCL_l4 = labelled(Code4,
                         setNames(Code4, Language)),
      .keep = "none")
  return(data) }

#' Get SACC
#' @description Download the Standard Australian Classification of Countries
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when distinct
#' @importFrom stringr str_detect
#' @importFrom tidyr fill
#' @importFrom readxl read_xlsx read_xls

get_SACC <- function(...) {
  url <- "https://www.abs.gov.au/statistics/classifications/standard-australian-classification-countries-sacc/2016/sacc_12690do0001_202402.xlsx"
  tempfile <- file.path(tempdir(), "temp.xlsx")
  download.file(url, tempfile, mode = "wb")
  data <- read_xlsx(tempfile,
                    sheet="Table 1.3",
                    col_names= c("Code1", "Code2", "Code3", "Country"),
                    col_types = "text",
                    skip = 8) |>
    mutate(Level = case_when(str_detect(Code1, "^\\d{1}$") ~ 1,
                             str_detect(Code2, "^\\d{2}$") ~ 2,
                             str_detect(Code3, "^\\d{4}$") ~ 3,
                             TRUE ~ NA)) |>
    fill(Code1, Code2, Code3, .direction = "down")
  data <- data |>
    filter(Level==3) |>
    mutate(
      SACC_l1 = labelled(Code1,
                         with(subset(data, Level==1), setNames(Code1, Code2))),
      SACC_l2 = labelled(Code2,
                         with(subset(data, Level==2), setNames(Code2, Code3))),
      SACC_l3 = labelled(Code3,
                         setNames(Code3, Country)),
      .keep = "none")
  return(data) }

#' Get CPICC
#' @description Download the Consumer Price Index Commodity Classification
#' @param version character, one of
#'  - `CPICCv16` version 16
#'  - `CPICCv15` version 15
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when distinct
#' @importFrom stringr str_detect
#' @importFrom tidyr fill drop_na
#' @importFrom readxl read_xlsx read_xls

get_CPICC <- function(version=NULL) {
  url <- "https://www.abs.gov.au/statistics/classifications/consumer-price-index-commodity-classification-16th-series/2011/6401055004.xls"
  src <- list(
    "CPICCv16"=list(
      sheet="15th and 16th series CPICC",
      range="F11:I155"),
    "CPICCv15"=list(
      sheet="15th and 16th series CPICC",
      range="A11:D155")
  )
  if (is.null(version)) {
    version = names(src)[1]
  }
  if (!version %in% names(src)) {
    stop(paste("version not one of", paste(names(src), collapse = ", ")))
  }
  tempfile <- file.path(tempdir(), "temp.xls")
  download.file(url, tempfile, mode = "wb")
  data <- read_xls(tempfile,
                   sheet=src[[version]]$sheet,
                   range=src[[version]]$range,
                   col_names= c("Code", "Code1nm", "Code2nm", "Code3nm"),
                   col_types = "text") |>
    drop_na(Code) |>
    mutate(Level = case_when(is.na(Code2nm) & is.na(Code3nm) ~ 1,
                             is.na(Code1nm) & is.na(Code3nm) ~ 2,
                             is.na(Code1nm) & is.na(Code2nm) ~ 3,
                             TRUE ~ NA)) |>
    mutate(Code1 = if_else(Level==1, Code, NA),
           Code2 = if_else(Level==2, Code, NA),
           Code3 = if_else(Level==3, Code, NA)) |>
    fill(Code1, Code2, .direction="down")
  data <- data |>
    filter(Level==3) |>
    mutate(
      CPICC_l1 = labelled(Code1,
                          with(subset(data, Level==1), setNames(Code1, Code1nm))),
      CPICC_l2 = labelled(Code2,
                          with(subset(data, Level==2), setNames(Code2, Code2nm))),
      CPICC_l3 = labelled(Code3,
                          with(subset(data, Level==3), setNames(Code3, Code3nm))),
      .keep = "none")
  return(data) }

#' Get SESCA
#' @description Download the Standard Economic Sector Classifications of Australia
#' @param version character, one of
#'  - `SISCAv2021` version 2021
#'  - `SISCAv2008` version 2008
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when distinct
#' @importFrom stringr str_detect
#' @importFrom tidyr fill drop_na
#' @importFrom readxl read_xlsx read_xls

get_SESCA <- function(version=NULL) {
  src <- list(
    "SISCAv2021"=list(
      sheet="Table 2",
      range= "A8:B39"),
    "SISCAv2008"=list(
      sheet="Table 1",
      range="A8:B39")
  )
  if (is.null(version)) {
    version = names(src)[1]
  }
  if (!version %in% names(src)) {
    stop(paste("version not one of", paste(names(src), collapse = ", ")))
  }
  url <- "https://www.abs.gov.au/statistics/classifications/standard-economic-sector-classifications-australia-sesca/2021/SESCA%202021%20-%20SISCA%20and%20SNA%20Correspondences.xls"
  tempfile <- file.path(tempdir(), "temp.xls")
  download.file(url, tempfile, mode = "wb")
  data <- read_xls(tempfile,
                   sheet=src[[version]]$sheet,
                   range=src[[version]]$range,
                   col_names= c("Code", "Codenm"),
                   col_types = "text") |>
    drop_na(Code) |>
    mutate(Level = case_when(str_detect(Code, "^\\d{1}$") ~ 1,
                             str_detect(Code, "^\\d{4}$") ~ 2,
                             TRUE ~ NA))
  data <- data |>
    filter(Level==2) |>
    mutate(
      SISCA_l1 = labelled(str_extract(Code, "^\\d{1}"),
                          with(subset(data, Level==1), setNames(Code, Codenm))),
      SISCA_l2 = labelled(Code,
                          with(subset(data, Level==2), setNames(Code, Codenm))),
      .keep = "none")
  return(data) }

#' Get ASCCEG
#' @description Download the Australian Standard Classification of Cultural and Ethnic Groups
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when distinct
#' @importFrom stringr str_detect
#' @importFrom tidyr fill
#' @importFrom readxl read_xlsx read_xls

get_ASCCEG <- function(...) {
  url <- "https://www.abs.gov.au/statistics/classifications/australian-standard-classification-cultural-and-ethnic-groups-ascceg/2019/12490do0001_201912.xls"
  tempfile <- file.path(tempdir(), "temp.xls")
  download.file(url, tempfile, mode = "wb")
  data <- read_xls(tempfile,
                   sheet = "Table 1.3",
                   range = "A8:D330",
                   col_names= c("Code1", "Code2", "Code3", "Culture"),
                   col_types = "text") |>
    mutate(Level = case_when(str_detect(Code1, "^\\d{1}$") ~ 1,
                             str_detect(Code2, "^\\d{2}$") ~ 2,
                             str_detect(Code3, "^\\d{4}$") ~ 3,
                             TRUE ~ NA)) |>
    fill(Code1, Code2, Code3, .direction = "down")
  data <- data |>
    filter(Level==3) |>
    mutate(
      ASCCEG_l1 = labelled(Code1,
                           with(subset(data, Level==1), setNames(Code1, Code2))),
      ASCCEG_l2 = labelled(Code2,
                           with(subset(data, Level==2), setNames(Code2, Code3))),
      ASCCEG_l3 = labelled(Code3,
                           setNames(Code3, Culture)),
      .keep = "none")
  return(data) }

#' Get ASCDOC
#' @description Download the Australian Standard Classification of Drugs of Concern
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when distinct
#' @importFrom stringr str_detect
#' @importFrom tidyr fill
#' @importFrom readxl read_xlsx read_xls

get_ASCDOC <- function(...) {
  url <- "https://www.abs.gov.au/statistics/classifications/australian-standard-classification-drugs-concern/2011/1248do0001_201611.xls"
  tempfile <- file.path(tempdir(), "temp.xls")
  download.file(url, tempfile, mode = "wb")
  data <- read_xls(tempfile,
                   sheet = "Table 1.3",
                   range = "A9:D247",
                   col_names= c("Code1", "Code2", "Code3", "Drug"),
                   col_types = "text") |>
    mutate(Level = case_when(str_detect(Code1, "^\\d{1}$") ~ 1,
                             str_detect(Code2, "^\\d{2}$") ~ 2,
                             str_detect(Code3, "^\\d{4}$") ~ 3,
                             TRUE ~ NA)) |>
    fill(Code1, Code2, Code3, .direction = "down")
  data <- data |>
    filter(Level==3) |>
    mutate(
      ASCDOC_l1 = labelled(Code1,
                           with(subset(data, Level==1), setNames(Code1, Code2))),
      ASCDOC_l2 = labelled(Code2,
                           with(subset(data, Level==2), setNames(Code2, Code3))),
      ASCDOC_l3 = labelled(Code3,
                           setNames(Code3, Drug)),
      .keep = "none")
  return(data) }

#' Get ANZSRC
#' @description Download the Australian and New Zealand Standard Research Classification
#' @param version character, one of
#'  - `ANZSRCvFoR` version Field of Research
#'  - `ANZSRCvSEO` version SEO
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when distinct
#' @importFrom stringr str_detect
#' @importFrom tidyr fill drop_na
#' @importFrom readxl read_xlsx read_xls

get_ANZSRC <- function(version=c("ANZSRCvFoR", "ANZSRCvSEO")) {
  version <- match.arg(version)
  src <- list(
    "ANZSRCvFoR"=list(
      url="https://www.abs.gov.au/statistics/classifications/australian-and-new-zealand-standard-research-classification-anzsrc/2020/anzsrc2020_for.xlsx",
      sheet="Table 3",
      range="A11:D2213"),
    "ANZSRCvSEO"=list(
      url="https://www.abs.gov.au/statistics/classifications/australian-and-new-zealand-standard-research-classification-anzsrc/2020/anzsrc2020_seo.xlsx",
      sheet="Table 3",
      range="A11:D997"))
  tempfile <- file.path(tempdir(), "temp.xls")
  download.file(src[[version]]$url, tempfile, mode = "wb")
  data <- read_xlsx(tempfile,
                    sheet=src[[version]]$sheet,
                    range=src[[version]]$range,
                    col_names= c("Code1", "Code2", "Code3", "Subject"),
                    col_types = "text") |>
    mutate(Level =case_when(str_detect(Code1, "^\\d{2}$") ~ 1,
                            str_detect(Code2, "^\\d{4}$") ~ 2,
                            str_detect(Code3, "^\\d{6}$") ~ 3,
                            TRUE ~ NA)) |>
    fill(Code1, Code2, Code3, .direction = "down")
  data <- data |>
    filter(Level==3) |>
    mutate(
      ANZSRC_l1 = labelled(Code1,
                           with(subset(data, Level==1), setNames(Code1, Code2))),
      ANZSRC_l2 = labelled(Code2,
                           with(subset(data, Level==2), setNames(Code2, Code3))),
      ANZSRC_l3 = labelled(Code3,
                           setNames(Code3, Subject)),
      .keep = "none")
  return(data) }

#' Get FCB
#' @description Downloads the Functional Classification of Buildings
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when
#' @importFrom stringr str_detect str_extract
#' @importFrom tidyr fill separate
#' @importFrom rvest read_html html_table

get_FCB <- function(...) {
  url <- "https://www.abs.gov.au/statistics/classifications/functional-classification-buildings/jan-2021#the-classification-structure"
  src <- rvest::read_html(url) |>
    rvest::html_table(header=FALSE,
                      na.strings = "")
  data <- src[[1]] |>
    separate(X3, into=c("Code", "Codenm"), sep="\\s", extra="merge") |>
    mutate(Level = case_when(str_detect(Code, "^\\d{1}$") ~ 1,
                             str_detect(Code, "^\\d{2}$") ~ 2,
                             str_detect(Code, "^\\d{3}$") ~ 3,
                             TRUE ~ NA))
  data <- data |>
    filter(Level==3) |>
    mutate(
      FCB_l1=labelled(str_extract(Code, "^\\d{1}"),
                      with(subset(data, Level==1), setNames(Code, Codenm))),
      FCB_l2=labelled(str_extract(Code, "^\\d{2}"),
                      with(subset(data, Level==2), setNames(Code, Codenm))),
      FCB_l3=labelled(Code,
                      with(subset(data, Level==3), setNames(Code, Codenm))),
      .keep = "none")
  return(data) }

#' Get ANZSOC
#' @description Downloads the Australian and New Zealand Standard Offence Classification
#' @returns A data.frame with the classification hierarchy as labeled vectors
#' @export
#' @importFrom haven labelled
#' @importFrom dplyr mutate filter case_when coalesce
#' @importFrom stringr str_detect str_split
#' @importFrom tidyr fill separate
#' @importFrom rvest read_html html_table

get_ANZSOC <- function(...) {
  url <- "https://www.abs.gov.au/statistics/classifications/australian-and-new-zealand-standard-offence-classification-anzsoc/2023/ANZSOC%202023%20classification%20structure.xlsx"
  tempfile <- file.path(tempdir(), "temp.xlsx")
  download.file(url, tempfile, mode = "wb")
  data <- read_xlsx(tempfile,
                    sheet="Structure 2023",
                    range="A7:C259",
                    col_names= c("Code1", "Code2", "Code3"),
                    col_types = "text") |>
    mutate(Code=coalesce(Code1, Code2, Code3),
           Code=str_split(Code, pattern="\\s", 2),
           Codenm=sapply(Code, "[", 2),
           Code=sapply(Code, "[", 1),
           Level = case_when(str_detect(Code, "^\\d{2}$") ~ 1,
                             str_detect(Code, "^\\d{3}$") ~ 2,
                             str_detect(Code, "^\\d{4}$") ~ 3,
                             TRUE ~ NA))
  data <- data |>
    filter(Level==3) |>
    mutate(
      ANZSOC_l1=labelled(str_extract(Code, "^\\d{2}"),
                         with(subset(data, Level==1), setNames(Code, Codenm))),
      ANZSOC_l2=labelled(str_extract(Code, "^\\d{3}"),
                         with(subset(data, Level==2), setNames(Code, Codenm))),
      ANZSOC_l3=labelled(Code,
                         setNames(Code, Codenm)),
      .keep = "none")
  return(data) }

