# ==============================================================================
# Data Preparation Script for insperplot Package
# ==============================================================================
#
# This script downloads and prepares datasets for the insperplot package:
#   - rec_buslines: Bus line information from Greater Recife
#   - rec_passengers: Daily passenger counts from Greater Recife
#   - spo_metro: São Paulo Metro Line 4 station data
#   - macro_series: Brazilian macroeconomic indicators
#
# Data Sources:
#   1. Insper Dataverse - Observatório Nacional de Mobilidade Sustentável
#      https://dataverse.datascience.insper.edu.br
#   2. Brazilian Central Bank (Banco Central do Brasil)
#      https://www3.bcb.gov.br/sgspub/
#
# Author: Vinicius Reginatto
# Last Updated: 2025-10-14
# ==============================================================================

library(dplyr)
library(tidyr)
library(readr)
library(dataverse)

# Configure Dataverse server
Sys.setenv("DATAVERSE_SERVER" = "dataverse.datascience.insper.edu.br")

# ==============================================================================
# Helper Functions
# ==============================================================================

#' Download and Extract Data from Insper Dataverse
#'
#' Downloads a ZIP file from Insper's Dataverse repository, extracts the CSV,
#' and returns the data as a tibble.
#'
#' @param name Character. Name of the ZIP file in the Dataverse repository
#' @param dataset Character. DOI of the dataset (format: "10.60873/FK2/XXXXX")
#' @return A tibble containing the extracted CSV data
#' @noRd
get_data <- function(name, dataset) {
  file_name <- gsub("\\..+", "", name)

  # Internal function to extract CSV from ZIP archive
  unzip_csv <- function(x) {
    datadir <- tempdir()

    # Extract ZIP contents to temp directory
    utils::unzip(x, exdir = datadir)

    # Find CSV file in extracted folder
    path <- list.files(
      file.path(datadir, file_name),
      pattern = "\\.csv$",
      full.names = TRUE
    )

    # Warn if multiple CSVs found
    if (length(path) > 1) {
      cli::cli_warn(
        "Multiple CSV files found in {.file {x}}. Defaulting to first."
      )
    }

    cli::cli_alert_info("Importing {.file {basename(path)}}")

    # Read and return CSV data
    data <- readr::read_csv(path[[1]], show_col_types = FALSE)
    return(data)
  }

  # Download data from Dataverse
  result <- dataverse::get_dataframe_by_name(name, dataset, .f = unzip_csv)
  cli::cli_alert_success(
    "Downloaded {.file {name}} from DOI: {.url {dataset}}."
  )

  return(result)
}

# ==============================================================================
# Download Recife Bus Data
# ==============================================================================

# Bus lines: Information about all bus lines in Greater Recife
# Source: Insper - Observatório Nacional de Mobilidade Sustentável
rec_buslines <- get_data(
  "4-linhas-onibus.zip",
  "10.60873/FK2/TLFP8L"
)

# Passengers: Daily passenger counts by bus line
# Source: Insper - Observatório Nacional de Mobilidade Sustentável
rec_passengers <- get_data(
  "3-passageiros-transportados.zip",
  "10.60873/FK2/JEYM0J"
)

# ==============================================================================
# Load São Paulo Metro Data
# ==============================================================================

# Metro Line 4 (Yellow Line) daily passenger entries by station
# Source: São Paulo Metro Company (stored locally in data-raw/)
spo_metro <- read_csv("data-raw/metro_sp_line_4_stations.csv")

# ==============================================================================
# Download Brazilian Macroeconomic Data
# ==============================================================================

# Download time series from Brazilian Central Bank
# Series codes:
#   433: IPCA - Consumer Price Index (inflation)
#   21637: PMS - Monthly Services Survey
#   21859: IPI - Industrial Production Index
#   1389: Crude oil production
#   24364: IBC-Br (seasonally adjusted) - Economic Activity Index
macro_series <- rbcb::get_series(
  c(
    "ipca" = 433,
    "pms" = 21637,
    "ipi" = 21859,
    "oil" = 1389,
    "ibcbr_dessaz" = 24364
  )
)

# Merge all series into single data frame by date
macro_series <- purrr::reduce(macro_series, full_join, by = "date")

# ==============================================================================
# Save Datasets
# ==============================================================================

# Save all datasets to data/ directory as .rda files
# These will be available when users load the insperplot package
usethis::use_data(
  rec_buslines,
  rec_passengers,
  spo_metro,
  macro_series,
  overwrite = TRUE
)
