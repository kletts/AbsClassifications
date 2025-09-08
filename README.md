# AbsClassifications

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/AbsClassifications.png)](https://CRAN.R-project.org/package=AbsClassifications)
<!-- badges: end -->

Install package from github as:

``` r
devtools::install_github("kletts/AbsClassifications")
```

# Available classifications

The following package includes functions to import ABS hierarchical data
[classification
structures](https://www.abs.gov.au/statistics/classifications) in a
standard format.

The available structures, versions, and download functions are:

| Abbrev | Name                                                                                   | ReleaseDate | Version     | Function   | FileName            |
|:-------|:---------------------------------------------------------------------------------------|:------------|:------------|:-----------|:--------------------|
| OSCA   | Occupation Standard Classification for Australia                                       | Dec 2024    |             | get_OSCA   | OSCA.parquet        |
| ANZSCO | Australian and New Zealand Standard Classification of Occupation                       | Nov 2022    | ANZSCOv2022 | get_ANZSCO | ANZSCOv2022.parquet |
| ANZSCO | Australian and New Zealand Standard Classification of Occupation                       | Nov 2021    | ANZSCOv2021 | get_ANZSCO | ANZSCOv2021.parquet |
| ANZSIC | Australian and New Zealand Standard Industrial Classification                          | Jun 2013    |             | get_ANZSIC | ANZSIC.parquet      |
| ASCL   | Australian Standard Classification of Languages                                        | Mar 2025    |             | get_ASCL   | ASCL.parquet        |
| ASCRG  | Australian Standard Classification of Religious Groups                                 | Mar 2024    | ASCRGv2024  | get_ASCRG  | ASCRGv2024.parquet  |
| ASCRG  | Australian Standard Classification of Religious Groups                                 | Jul 2016    | ASCRGv2016  | get_ASCRG  | ASCRGv2016.parquet  |
| ANZSOC | Australian and New Zealand Standard Offence Classification                             | Nov 2023    |             | get_ANZSOC | ANZSOC.parquet      |
| SESCA  | Standard Economic Sector Classifications of Australia                                  | Dec 2021    | SISCAv2021  | get_SESCA  | SISCAv2021.parquet  |
| SESCA  | Standard Economic Sector Classifications of Australia                                  | Mar 2008    | SISCAv2008  | get_SESCA  | SISCAv2008.parquet  |
| FCB    | Functional Classification of Buildings                                                 | Jan 2021    |             | get_FCB    | FCB.parquet         |
| ANZSRC | Australian and New Zealand Standard Research Classification: Field of Research         | Jun 2020    | ANZSRCvFoR  | get_ANZSRC | ANZSRCvFoR.parquet  |
| ANZSRC | Australian and New Zealand Standard Research Classification: Socio-Economic Objectives | Jun 2020    | ANZSRCvSEO  | get_ANZSRC | ANZSRCvSEO.parquet  |
| ASCCEG | Australian Standard Classification of Cultural and Ethnic Groups                       | Dec 2019    |             | get_ASCCEG | ASCCEG.parquet      |
| SACC   | Standard Australian Classification of Countries                                        | Jun 2016    |             | get_SACC   | SACC.parquet        |
| ASCDOC | Australian Standard Classification of Drugs of Concern                                 | Jul 2011    |             | get_ASCDOC | ASCDOC.parquet      |
| CPICC  | Consumer Price Index Commodity Classification: 16th series                             | Jul 2011    | CPICCv16    | get_CPICC  | CPICCv16.parquet    |
| CPICC  | Consumer Price Index Commodity Classification: 15th series                             | Jul 2011    | CPICCv15    | get_CPICC  | CPICCv15.parquet    |
| ASCED  | Australian Standard Classification of Education: Field of Education                    | Aug 2001    | ASCEDvField | get_ASCED  | ASCEDvField.parquet |
| ASCED  | Australian Standard Classification of Education: Level of Education                    | Aug 2001    | ASCEDvLevel | get_ASCED  | ASCEDvLevel.parquet |
| AHECC  | Australian Harmonized Export Commodity Classification                                  | Dec 2021    | AHECCv2017  | get_AHECC  | AHECCv2017.parquet  |
| AHECC  | Australian Harmonized Export Commodity Classification                                  | Jan 2022    | AHECCv2022  | get_AHECC  | AHECCv2022.parquet  |
| COICOP | United Nation’s Classification of Individual Consumption According to Purpose          | Mar 2018    | COICOPv2018 | get_COICOP | COICOPv2018.parquet |
| COICOP | United Nation’s Classification of Individual Consumption According to Purpose          | Mar 1999    | COICOPv1999 | get_COICOP | COICOPv1999.parquet |

## Direct download

You can directly download any of the the classifications from this
repository using the following URL:

`https://raw.githubusercontent.com/kletts/AbsClassifications/data/XXXX.parquet`

where `XXXX` refers to the file name for the classification as provided
in the table above. For example, using the `arrow::read_parquet`
function in R:

``` r
url <- "https://raw.githubusercontent.com/kletts/AbsClassifications/extdata/FCB.parquet"
arrow::read_parquet(url)
```

Parquet files are preferred because:

- the storage size is much smaller than other formats such as CSV,
  especially on the larger classifications more repition of the codes
  and description on the top level;
- the file preserves the labelled vector format of the hierarchy, it
  imports both the codes and descriptions as a `tibble::tibble` format
  table;
- the parquet format is easily read in almost all major programming
  languages including javascript (see `npm:apache-arrow`), python (eg
  see `pandas.read_parquet`) or SQL (eg see `DuckDB.read_parquet`).

Note that the R `nanoparquet::read_parquet` function does not currently
support labelled vectors.

## Using functions

Where multiple versions or substructures are available, specify the
version required, when calling the function, for example:

``` r
get_ANZSRC("ANZSRCvFoR")
```

# Example

Using the Functional Classification of Buildings, once downloaded the
result is a labelled vector with a column for each level of the
hierarchy, here only the first 2 are shown:

``` r
strc <- get_FCB()
strc |> 
  dplyr::distinct(FCB_l1, FCB_l2) 
```

    # A tibble: 19 × 2
       FCB_l1                              FCB_l2                                   
       <chr+lbl>                           <chr+lbl>                                
     1 1 [Residential Buildings]           11 [Houses]                              
     2 1 [Residential Buildings]           12 [Semi-detached, row or terrace houses…
     3 1 [Residential Buildings]           13 [Apartments]                          
     4 1 [Residential Buildings]           19 [Residential buildings not elsewhere …
     5 2 [Commercial Buildings]            21 [Retail and wholesale trade buildings]
     6 2 [Commercial Buildings]            22 [Transport buildings]                 
     7 2 [Commercial Buildings]            23 [Offices]                             
     8 2 [Commercial Buildings]            29 [Commercial buildings not elsewhere c…
     9 3 [Industrial Buildings]            31 [Factories and other secondary produc…
    10 3 [Industrial Buildings]            32 [Warehouses]                          
    11 3 [Industrial Buildings]            33 [Agricultural and aquacultural buildi…
    12 3 [Industrial Buildings]            39 [Other industrial buildings not elsew…
    13 4 [Other Non-residential Buildings] 41 [Education buildings]                 
    14 4 [Other Non-residential Buildings] 42 [Religion buildings]                  
    15 4 [Other Non-residential Buildings] 43 [Aged care facilities]                
    16 4 [Other Non-residential Buildings] 44 [Health buildings]                    
    17 4 [Other Non-residential Buildings] 45 [Entertainment and recreation buildin…
    18 4 [Other Non-residential Buildings] 46 [Short-term accommodation buildings]  
    19 4 [Other Non-residential Buildings] 49 [Other non-residential buildings not …

# Additional methods

The package includes two additional methods for working with ABS
Classifications:

## Convert to `data.tree`

The classification structures are naturally hierarchical, the structures
once downloaded can be converted to a data tree object using the
`as_datatree` function, here using the code descriptions:

``` r
strc  |> 
  dplyr::distinct(FCB_l1, FCB_l2) |> 
  as_datatree(type="desc")
```

                                                              levelName
    1  Root                                                            
    2   ¦--Residential Buildings                                       
    3   ¦   ¦--Houses                                                  
    4   ¦   ¦--Semi-detached, row or terrace houses, townhouses        
    5   ¦   ¦--Apartments                                              
    6   ¦   °--Residential buildings not elsewhere classified          
    7   ¦--Commercial Buildings                                        
    8   ¦   ¦--Retail and wholesale trade buildings                    
    9   ¦   ¦--Transport buildings                                     
    10  ¦   ¦--Offices                                                 
    11  ¦   °--Commercial buildings not elsewhere classified           
    12  ¦--Industrial Buildings                                        
    13  ¦   ¦--Factories and other secondary production buildings      
    14  ¦   ¦--Warehouses                                              
    15  ¦   ¦--Agricultural and aquacultural buildings                 
    16  ¦   °--Other industrial buildings not elsewhere classified     
    17  °--Other Non-residential Buildings                             
    18      ¦--Education buildings                                     
    19      ¦--Religion buildings                                      
    20      ¦--Aged care facilities                                    
    21      ¦--Health buildings                                        
    22      ¦--Entertainment and recreation buildings                  
    23      ¦--Short-term accommodation buildings                      
    24      °--Other non-residential buildings not elsewhere classified

## Flatten hierarchy

A hierarchy can be convert to a parent/child table of nodes using the
function `flatten_datatree`, use the function in combination with
`as_datatree`:

``` r
strc  |> 
  as_datatree() |> 
  flatten_datatree() 
```

       from  to level
    1  Root   1     2
    2  Root   2     2
    3  Root   3     2
    4  Root   4     2
    5     1  11     3
    6     1  12     3
    7     1  13     3
    8     1  19     3
    9     2  21     3
    10    2  22     3
    11    2  23     3
    12    2  29     3
    13    3  31     3
    14    3  32     3
    15    3  33     3
    16    3  39     3
    17    4  41     3
    18    4  42     3
    19    4  43     3
    20    4  44     3
    21    4  45     3
    22    4  46     3
    23    4  49     3
    24   11 111     4
    25   11 112     4
    26   11 113     4
    27   11 114     4
    28   12 121     4
    29   12 122     4
    30   13 131     4
    31   13 132     4
    32   13 133     4
    33   13 134     4
    34   13 139     4
    35   19 191     4
    36   21 211     4
    37   22 221     4
    38   22 222     4
    39   22 223     4
    40   22 224     4
    41   23 231     4
    42   29 291     4
    43   31 311     4
    44   32 321     4
    45   33 331     4
    46   39 391     4
    47   41 411     4
    48   42 421     4
    49   43 431     4
    50   44 441     4
    51   44 442     4
    52   45 451     4
    53   46 461     4
    54   46 462     4
    55   46 463     4
    56   49 491     4

## Unlabel

The returned data frame includes labelled vector of hierarchy codes and
descriptions. If you would prefer only the codes or the descriptions
separately, apply the `unlabel` function to returned data frame.

``` r
strc  |> 
  dplyr::distinct(FCB_l1, FCB_l2) |> 
  unlabel()
```

    # A tibble: 19 × 4
       FCB_l1_desc                     FCB_l2_desc                     FCB_l1 FCB_l2
       <chr>                           <chr>                           <chr>  <chr> 
     1 Residential Buildings           Houses                          1      11    
     2 Residential Buildings           Semi-detached, row or terrace … 1      12    
     3 Residential Buildings           Apartments                      1      13    
     4 Residential Buildings           Residential buildings not else… 1      19    
     5 Commercial Buildings            Retail and wholesale trade bui… 2      21    
     6 Commercial Buildings            Transport buildings             2      22    
     7 Commercial Buildings            Offices                         2      23    
     8 Commercial Buildings            Commercial buildings not elsew… 2      29    
     9 Industrial Buildings            Factories and other secondary … 3      31    
    10 Industrial Buildings            Warehouses                      3      32    
    11 Industrial Buildings            Agricultural and aquacultural … 3      33    
    12 Industrial Buildings            Other industrial buildings not… 3      39    
    13 Other Non-residential Buildings Education buildings             4      41    
    14 Other Non-residential Buildings Religion buildings              4      42    
    15 Other Non-residential Buildings Aged care facilities            4      43    
    16 Other Non-residential Buildings Health buildings                4      44    
    17 Other Non-residential Buildings Entertainment and recreation b… 4      45    
    18 Other Non-residential Buildings Short-term accommodation build… 4      46    
    19 Other Non-residential Buildings Other non-residential building… 4      49    
