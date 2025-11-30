# Extract PS specialty claims

Returns claims filtered by specialty code from the PS HCPCS dataset.

## Usage

``` r
get_PS_specialty(
  specialtycodelist,
  yearlist,
  DIAG = FALSE,
  HCPCS = FALSE,
  PLCSRV = FALSE
)
```

## Arguments

- specialtycodelist:

  A vector of specialty codes to keep.

- yearlist:

  A vector of years to include.

- DIAG:

  Logical, include DIAG column.

- HCPCS:

  Logical, include HCPCS column.

- PLCSRV:

  Logical, include PLCSRV column.

## Value

A tibble with filtered and selected PS HCPCS data.
