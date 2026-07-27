library(data.table)

Sys.setenv(OPENBLAS_NUM_THREADS = "1")

N <- 100000
predictors <- seq(200, 3000, by = 200)
isample <- 5

results <- list()

for (p in predictors) {
  
  times_xtx <- numeric(isample)
  times_inv <- numeric(isample)
  times_xty <- numeric(isample)
  
  for (i in 1:isample) {
    
    X <- matrix(rnorm(N * p), nrow = N, ncol = p)
    y <- rnorm(N)
    
    # Warmup
    XtX <- crossprod(X)
    tmp1 <- solve(XtX)
    tmp2 <- crossprod(X, y)
    
    # --- XtX ---
    t1 <- Sys.time()
    XtX <- crossprod(X)
    t2 <- Sys.time()
    times_xtx[i] <- as.numeric(difftime(t2, t1, units = "secs"))
    
    # --- Inverse ---
    t3 <- Sys.time()
    XtX_inv <- solve(XtX)
    t4 <- Sys.time()
    times_inv[i] <- as.numeric(difftime(t4, t3, units = "secs"))
    
    # --- XtY ---
    t5 <- Sys.time()
    XtY <- crossprod(X, y)
    t6 <- Sys.time()
    times_xty[i] <- as.numeric(difftime(t6, t5, units = "secs"))
  }
  
  results[[length(results) + 1]] <- data.frame(
    N = N,
    p = p,
    xtx_median_us = median(times_xtx) * 1e6,
    xtx_sd_us = sd(times_xtx) * 1e6,
    inv_median_us = median(times_inv) * 1e6,
    inv_sd_us = sd(times_inv) * 1e6,
    xty_median_us = median(times_xty) * 1e6,
    xty_sd_us = sd(times_xty) * 1e6
  )
  
  cat(sprintf(
    "Done: p=%d | XtX=%.2f µs | Inv=%.2f µs | XtY=%.2f µs\n",
    p,
    median(times_xtx) * 1e6,
    median(times_inv) * 1e6,
    median(times_xty) * 1e6
  ))
}

df <- rbindlist(results)
fwrite(df, "timing_results_regression_blas_steps_1_core.csv")





cat("✅ Benchmark (Regression Steps) abgeschlossen\n")