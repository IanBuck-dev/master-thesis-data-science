library(data.table)
library(lubridate)
library(CrowdQCplus)

# Load the csv file with all temperature readings from all stations in the format:
# p_id, time, ta, lon, lat
path <- "/Users/ian/Repos/uni/sensor-data-ml/data/netatmo/june_hamburg/"
filename <- 'hamburg_06_23.csv'

perform_qc <- function(df, print_result) {
  df$time <- as.POSIXct(df$time)
  df$z = NA
  setDT(df)
  
  df <- cqcp_padding(df, resolution = "30 min", rounding_method = "nearest")
  
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
      new_filename <- 'hamburg_06_23_after_qc.csv'
      print(paste0("writing to ", new_filename))
      write.csv(q_data, file = paste0(path, new_filename), row.names = FALSE)
    }
  }
}

df <- read.csv(file=paste0(path, filename), sep=";")
perform_qc(df, TRUE)
