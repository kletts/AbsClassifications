# AbsClassifications

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

| Abbrev | Name                                                                                   | ReleaseDate | Version     | Function   |
|:-------|:---------------------------------------------------------------------------------------|:------------|:------------|:-----------|
| OSCA   | Occupation Standard Classification for Australia                                       | Dec 2024    |             | get_OSCA   |
| ANZSCO | Australian and New Zealand Standard Classification of Occupation                       | Nov 2022    | ANZSCOv2022 | get_ANZSCO |
| ANZSCO | Australian and New Zealand Standard Classification of Occupation                       | Nov 2021    | ANZSCOv2021 | get_ANZSCO |
| ANZSIC | Australian and New Zealand Standard Industrial Classification                          | Jun 2013    |             | get_ANZSIC |
| ASCL   | Australian Standard Classification of Languages                                        | Mar 2025    |             | get_ASCL   |
| ASCRG  | Australian Standard Classification of Religious Groups                                 | Mar 2024    | ASCRGv2024  | get_ASCRG  |
| ASCRG  | Australian Standard Classification of Religious Groups                                 | Jul 2016    | ASCRGv2016  | get_ASCRG  |
| ANZSOC | Australian and New Zealand Standard Offence Classification                             | Nov 2023    |             | get_ANZSOC |
| SESCA  | Standard Economic Sector Classifications of Australia                                  | Dec 2021    | SISCAv2021  | get_SESCA  |
| SESCA  | Standard Economic Sector Classifications of Australia                                  | Mar 2008    | SISCAv2008  | get_SESCA  |
| FCB    | Functional Classification of Buildings                                                 | Jan 2021    |             | get_FCB    |
| ANZSRC | Australian and New Zealand Standard Research Classification: Field of Research         | Jun 2020    | ANZSRCvFoR  | get_ANZSRC |
| ANZSRC | Australian and New Zealand Standard Research Classification: Socio-Economic Objectives | Jun 2020    | ANZSRCvSEO  | get_ANZSRC |
| ASCCEG | Australian Standard Classification of Cultural and Ethnic Groups                       | Dec 2019    |             | get_ASCCEG |
| SACC   | Standard Australian Classification of Countries                                        | Jun 2016    |             | get_SACC   |
| ASCDOC | Australian Standard Classification of Drugs of Concern                                 | Jul 2011    |             | get_ASCDOC |
| CPICC  | Consumer Price Index Commodity Classification: 16th series                             | Jul 2011    | CPICCv16    | get_CPICC  |
| CPICC  | Consumer Price Index Commodity Classification: 15th series                             | Jul 2011    | CPICCv15    | get_CPICC  |
| ASCED  | Australian Standard Classification of Education: Field of Education                    | Aug 2001    | ASCEDvField | get_ASCED  |
| ASCED  | Australian Standard Classification of Education: Level of Education                    | Aug 2001    | ASCEDvLevel | get_ASCED  |

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
function `flatten_tree`, use the function in combination with
`as_datatree`:

``` r
strc  |> 
  dplyr::distinct(FCB_l1, FCB_l2) |> 
  as_datatree(type="desc") |> 
  flatten_tree() 
```

                                  from
    1                             Root
    2                             Root
    3                             Root
    4                             Root
    5            Residential Buildings
    6            Residential Buildings
    7            Residential Buildings
    8            Residential Buildings
    9             Commercial Buildings
    10            Commercial Buildings
    11            Commercial Buildings
    12            Commercial Buildings
    13            Industrial Buildings
    14            Industrial Buildings
    15            Industrial Buildings
    16            Industrial Buildings
    17 Other Non-residential Buildings
    18 Other Non-residential Buildings
    19 Other Non-residential Buildings
    20 Other Non-residential Buildings
    21 Other Non-residential Buildings
    22 Other Non-residential Buildings
    23 Other Non-residential Buildings
                                                             to level
    1                                     Residential Buildings     2
    2                                      Commercial Buildings     2
    3                                      Industrial Buildings     2
    4                           Other Non-residential Buildings     2
    5                                                    Houses     3
    6          Semi-detached, row or terrace houses, townhouses     3
    7                                                Apartments     3
    8            Residential buildings not elsewhere classified     3
    9                      Retail and wholesale trade buildings     3
    10                                      Transport buildings     3
    11                                                  Offices     3
    12            Commercial buildings not elsewhere classified     3
    13       Factories and other secondary production buildings     3
    14                                               Warehouses     3
    15                  Agricultural and aquacultural buildings     3
    16      Other industrial buildings not elsewhere classified     3
    17                                      Education buildings     3
    18                                       Religion buildings     3
    19                                     Aged care facilities     3
    20                                         Health buildings     3
    21                   Entertainment and recreation buildings     3
    22                       Short-term accommodation buildings     3
    23 Other non-residential buildings not elsewhere classified     3

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
