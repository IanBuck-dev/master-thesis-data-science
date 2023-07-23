library(data.table)
library(lubridate)
library(CrowdQCplus)

# Load the csv file with all temperature readings from all stations in the format:
# p_id, time, ta, lon, lat
path <- "/Users/ian/Repos/uni/sensor-data-ml/data/sensor.community/"
sensor_types <- c("bme280", "bmp180", "bmp280", "dht22")
months <- c("06") # 06

perform_qc <- function(df, print_result, sensor_type, month) {
  df$time <- as.POSIXct(df$time)
  df$z = NA
  setDT(df)
  
  df <- cqcp_padding(df, resolution = "10 min", rounding_method = "nearest")
  
  ok <- cqcp_check_input(df, print=TRUE)
  print(ok)
  
  # Perform complete QC
  if(ok) {
    # Perform with default parameters
    q_data <- cqcp_m1(df)
    q_data <- cqcp_m2(q_data, heightCorrection = FALSE)
    q_data <- cqcp_m3(q_data)
    q_data <- cqcp_m4(q_data)
    q_data <- cqcp_m5(q_data, check_elevation = FALSE, heightCorrection = FALSE)
    n_data_qc <- cqcp_output_statistics(q_data) # output statistics
    
    if (print_result) {
      filename <- paste0("2023-", month, "_", sensor_type, "_qc_after.csv")
      print(paste0("writing to ", filename))
      write.csv(q_data, file = paste0(path, filename), row.names = FALSE)
    }
  }
}

for (month in months) {
  # Create an empty DataFrame to store the combined results
  combined_df <- data.table()
  
  for (sensor_type in sensor_types) {
    filename <- paste0("2023-", month, "_", sensor_type, "_qc_test.csv")
    
    # Data & input check
    print(paste0('Performing QC for ', sensor_type))
    
    df <- read.csv(file=paste0(path, filename), sep=";", col.names = c("p_id", "time", "ta", "lon", "lat"))
    perform_qc(df, FALSE, sensor_type, month)
  }
  
  # Compare with using all data available
  print('Performing QC for combined')
  filename <- paste0("2023-", month, "_all_qc_test.csv")
  df <- read.csv(file=paste0(path, filename), sep=";", col.names = c("p_id", "time", "ta", "lon", "lat"))
  perform_qc(df, TRUE, "all", month)
}
