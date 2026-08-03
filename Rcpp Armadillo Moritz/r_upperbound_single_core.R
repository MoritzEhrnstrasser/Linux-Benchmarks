library(data.table)

# OpenBLAS Threads setzen
Sys.setenv(OPENBLAS_NUM_THREADS = "1")

# Parameter
N <- 100000
predictors <- seq(200, 3000, by = 200)
isample <- 5

results <- list()

for (p in predictors) {
  times <- numeric(isample)
  
  for (i in 1:isample) {
    X <- matrix(rnorm(N * p), nrow = N, ncol = p)
    
    # Warmup
    tmp <- crossprod(X)
    
    t1 <- Sys.time()
    M <- crossprod(X)
    t2 <- Sys.time()
    
    times[i] <- as.numeric(difftime(t2, t1, units = "secs"))
  }
  
  median_time <- median(times) * 1e6
  sd_time <- sd(times) * 1e6
  
  cat(sprintf("Done: p=%d | median=%.2f µs\n", p, median_time))
  
  results[[length(results) + 1]] <- data.frame(
    N = N,
    p = p,
    median_time_us = median_time,
    sd_time_us = sd_time
  )
}

df <- rbindlist(results)
fwrite(df, "timing_results_r_upperbound_single_core.csv")

cat("✅ R Upper-Bound Benchmark abgeschlossen\n")


