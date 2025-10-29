#' Brazilian Macroeconomic Time Series
#'
#' Monthly macroeconomic indicators from the Brazilian Central Bank (Banco Central
#' do Brasil), covering economic activity, inflation, industrial production,
#' services, and oil production.
#'
#' @format A data frame with 560 rows and 6 variables:
#' \describe{
#'   \item{date}{Date, first day of the month (YYYY-MM-DD)}
#'   \item{ibcbr_dessaz}{IBC-Br dessazonalizado (Seasonally adjusted Central Bank
#'     Economic Activity Index). Monthly economic activity indicator that serves
#'     as a proxy for GDP, base 2002 = 100}
#'   \item{ipca}{IPCA - Índice de Preços ao Consumidor Amplo (Broad Consumer
#'     Price Index). Monthly inflation rate in percent, official inflation measure
#'     used for monetary policy targeting}
#'   \item{ipi}{IPI - Índice de Produção Industrial (Industrial Production Index).
#'     Measures monthly industrial production, base 2012 = 100}
#'   \item{oil}{Produção de petróleo bruto (Crude oil production). Monthly crude
#'     oil production in thousands of barrels per day}
#'   \item{pms}{PMS - Pesquisa Mensal de Serviços (Monthly Services Survey).
#'     Monthly services sector activity index, base 2014 = 100}
#' }
#'
#' @details
#' This dataset contains key macroeconomic indicators widely used for economic
#' analysis and forecasting in Brazil. The data is sourced directly from the
#' Brazilian Central Bank's Time Series Management System (SGS).
#'
#' **Series codes used:**
#' \itemize{
#'   \item IPCA: 433
#'   \item PMS: 21637
#'   \item IPI: 21859
#'   \item Oil production: 1389
#'   \item IBC-Br (seasonally adjusted): 24364
#' }
#'
#' @source Brazilian Central Bank (Banco Central do Brasil)
#'   \url{https://www3.bcb.gov.br/sgspub/}
#'
#' @examplesIf has_insper_fonts()
#' library(ggplot2)
#'
#' # Plot inflation over time using insper_timeseries
#' recent_data <- subset(macro_series, date >= as.Date("2020-01-01"))
#' insper_timeseries(recent_data, x = date, y = ipca) +
#'   labs(
#'     title = "Brazilian Inflation (IPCA)",
#'     subtitle = "Monthly rate in percent (2020-present)",
#'     y = "IPCA (%)"
#'   )
"macro_series"


#' Recife Bus Lines Data
#'
#' Data on bus lines in the Greater Recife metropolitan region from Insper's
#' Observatório Nacional de Mobilidade Sustentável (National Observatory of
#' Sustainable Mobility).
#'
#' @format A data frame with 694 rows and 4 variables:
#' \describe{
#'   \item{abbrev_company}{Character, abbreviated name of the bus company
#'     (e.g., "BOA" for Borborema Imperial Transportes)}
#'   \item{code_line}{Character, unique code identifier for the bus line}
#'   \item{name_company}{Character, full name of the bus company operating
#'     the line}
#'   \item{name_line}{Character, name and route description of the bus line,
#'     typically showing origin and destination points}
#' }
#'
#' @details
#' This dataset contains comprehensive information about all bus lines operating
#' in the Greater Recife metropolitan area. It is part of Insper's research on
#' sustainable urban mobility in Brazilian metropolitan areas.
#'
#' The Observatório Nacional de Mobilidade Sustentável conducts comprehensive
#' studies on public transportation systems, focusing on efficiency,
#' accessibility, and sustainability metrics to support evidence-based policy
#' making.
#'
#' @source Insper - Observatório Nacional de Mobilidade Sustentável
#'   \url{https://dataverse.datascience.insper.edu.br}
#'   DOI: 10.60873/FK2/TLFP8L
#'
#' @seealso \code{\link{rec_passengers}} for related passenger transport data
"rec_buslines"


#' Recife Bus Passengers Data
#'
#' Daily passenger count data for buses in the Greater Recife metropolitan
#' region from Insper's Observatório Nacional de Mobilidade Sustentável
#' (National Observatory of Sustainable Mobility).
#'
#' @format A data frame with 237,852 rows and 6 variables:
#' \describe{
#'   \item{abbrev_company}{Character, abbreviated name of the bus company}
#'   \item{name_company}{Character, full name of the bus company}
#'   \item{code_line}{Character, unique code identifier for the bus line}
#'   \item{name_line}{Character, name and route description of the bus line}
#'   \item{date}{Date, daily observation date (YYYY-MM-DD), data from 2024}
#'   \item{passengers}{Numeric, total number of passengers transported on
#'     that date for the specific line}
#' }
#'
#' @details
#' This dataset contains daily passenger count information for the Greater Recife
#' bus system. It provides detailed insights into public transportation usage
#' patterns, allowing analysis of temporal trends, peak periods, and route
#' popularity.
#'
#' The dataset is part of Insper's broader research initiative on sustainable
#' urban mobility. The Observatório Nacional de Mobilidade Sustentável analyzes
#' this transportation data to support evidence-based policy making and urban
#' planning decisions.
#'
#' With over 237,000 observations, the dataset enables comprehensive analysis
#' of passenger flow patterns across different bus lines and time periods.
#'
#' @source Insper - Observatório Nacional de Mobilidade Sustentável
#'   \url{https://dataverse.datascience.insper.edu.br}
#'   DOI: 10.60873/FK2/JEYM0J
#'
#' @seealso \code{\link{rec_buslines}} for bus line reference data
"rec_passengers"


#' São Paulo Metro Line 4 Station Data
#'
#' Daily passenger entry data for stations on Line 4 (Yellow Line) of the São
#' Paulo Metro system.
#'
#' @format A data frame with 817 rows and 4 variables:
#' \describe{
#'   \item{date}{Date, daily observations (YYYY-MM-DD)}
#'   \item{year}{Year as numeric}
#'   \item{name_station}{Character, name of the metro station. Stations include:
#'     São Paulo-Morumbi, Butantã, Pinheiros, Faria Lima, Fradique Coutinho,
#'     Oscar Freire, Paulista, República, Luz, and Higienópolis-Mackenzie}
#'   \item{value}{Numeric, number of passenger entries at the station on that date}
#' }
#'
#' @details
#' Line 4 (Yellow Line) is one of the most important metro lines in São Paulo,
#' connecting the western neighborhoods to the city center. It serves high-traffic
#' areas including Paulista Avenue, one of São Paulo's main financial and
#' commercial districts.
#'
#' The data covers the period from 2018 onwards and can be used to analyze
#' passenger flow patterns, peak hours, and the impact of events or policies on
#' metro usage.
#'
#' @source São Paulo Metro Company (Companhia do Metropolitano de São Paulo)
"spo_metro"


#' Global Fossil Fuel Consumption
#'
#' Primary energy consumption from fossil fuels (coal, oil, and gas) measured
#' in terawatt-hours (TWh). Data covers global consumption from 1800 to recent years.
#'
#' @format A data frame with 231 rows and 5 variables:
#' \describe{
#'   \item{entity}{Character, name of the country or region (currently "World")}
#'   \item{code}{Character, country/region code (OWID_WRL for World)}
#'   \item{year}{Numeric, year of observation (1800-present)}
#'   \item{fuel}{Ordered factor with 3 levels: Oil, Gas, Coal.
#'     Levels are ordered for logical stacking in plots}
#'   \item{consumption}{Numeric, primary energy consumption in terawatt-hours (TWh).
#'     All values are positive, making this dataset ideal for area plots}
#' }
#'
#' @details
#' This dataset tracks the historical consumption of fossil fuels globally,
#' showing the dramatic increase in energy use since the Industrial Revolution.
#' The data is particularly useful for visualizing energy transitions and the
#' relative importance of different fossil fuels over time.
#'
#' **Key features:**
#' \itemize{
#'   \item All consumption values are positive (no negative values)
#'   \item Fuel types are ordered factors for better plot aesthetics
#'   \item Covers over 200 years of energy history
#'   \item Ideal for demonstrating area plots and stacked visualizations
#' }
#'
#' The fuel factor is ordered as Oil > Gas > Coal, which creates an intuitive
#' visual hierarchy when creating stacked area charts.
#'
#' @source Our World in Data (OWID)
#'   \url{https://ourworldindata.org/grapher/global-fossil-fuel-consumption}
#'   License: CC BY 4.0
#'
#' @seealso \code{\link{insper_area}} for creating area plots with this data
"fossil_fuel"
