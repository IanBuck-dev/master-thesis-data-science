install.packages("devtools")
install.packages("data.table")
install.packages("robustbase")
install.packages("lubridate")
install.packages("sp")
install.packages("raster")
install.packages("rgdal")

devtools::install_github("dafenner/CrowdQCplus")

library(data.table)
library(lubridate)
library(CrowdQCplus)

# Load the csv file with all temperature readings from all stations in the format:
# p_id, time, ta, lon, lat
path <- "/Users/ian/Repos/uni/sensor-data-ml/data/"
filename <- "netatmo_df_qc.csv"

# Data & input check
df <- read.csv(file=paste0(path, filename))
df$time <- as.POSIXct(df$time)
df$z = NA
setDT(df)
print(class(df))

df <- cqcp_padding(df, resolution = "5 min", rounding_method = "nearest")
data <- unique(df)

ok <- cqcp_check_input(data)
print(ok)

# Perform complete QC
if(ok) {
  # Perform with default parameters
  q_data <- cqcp_m1(data)
  q_data <- cqcp_m2(q_data, heightCorrection = FALSE)
  q_data <- cqcp_m3(q_data)
  q_data <- cqcp_m4(q_data)
  q_data <- cqcp_m5(q_data, check_elevation = FALSE, heightCorrection = FALSE)
  n_data_qc <- cqcp_output_statistics(q_data) # output statistics
}


