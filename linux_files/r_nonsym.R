library(data.table)

# -----------------------------------
# OpenBLAS Threads
# -----------------------------------

Sys.setenv(
  OPENBLAS_NUM_THREADS = "1"
)

# -----------------------------------
# Parameter
# -----------------------------------

N <- 100000

predictors <- seq(200, 3000, by = 200)

isample <- 5

results <- list()

# -----------------------------------
# Warmup
# -----------------------------------

{
  p <- predictors[1]
  
  X <- matrix(rnorm(N * p), nrow = N)
  Z <- matrix(rnorm(N * p), nrow = N)
  
  tmp1 <- crossprod(X, Z)
  
  A <- matrix(rnorm(p * p), nrow = p)
  diag(A) <- diag(A) + p
  
  tmp2 <- solve(A)
}

# -----------------------------------
# Benchmark
# -----------------------------------

for (p in predictors) {
  
  times_xtz <- numeric(isample)
  times_inv <- numeric(isample)
  times_xty <- numeric(isample)
  
  for (i in 1:isample) {
    
    # -----------------------------------
    # Daten erzeugen
    # -----------------------------------
    
    X <- matrix(rnorm(N * p), nrow = N)
    
    Z <- matrix(rnorm(N * p), nrow = N)
    
    y <- rnorm(N)
    
    # -----------------------------------
    # XtZ
    # -----------------------------------
    
    t1 <- Sys.time()
    
    XtZ <- crossprod(X, Z)
    
    t2 <- Sys.time()
    
    times_xtz[i] <- as.numeric(
      difftime(t2, t1, units = "secs")
    )
    
    # -----------------------------------
    # Nicht symmetrische Inverse
    # -----------------------------------
    
    A <- matrix(rnorm(p * p), nrow = p)
    
    diag(A) <- diag(A) + p
    
    t3 <- Sys.time()
    
    Ainv <- solve(A)
    
    t4 <- Sys.time()
    
    times_inv[i] <- as.numeric(
      difftime(t4, t3, units = "secs")
    )
    
    # -----------------------------------
    # XtY
    # -----------------------------------
    
    t5 <- Sys.time()
    
    XtY <- crossprod(X, y)
    
    t6 <- Sys.time()
    
    times_xty[i] <- as.numeric(
      difftime(t6, t5, units = "secs")
    )
  }
  
  results[[length(results) + 1]] <- data.frame(
    N = N,
    p = p,
    
    xtz_median_us = median(times_xtz) * 1e6,
    inv_median_us = median(times_inv) * 1e6,
    xty_median_us = median(times_xty) * 1e6
  )
  
  cat(sprintf("Done: p=%d\n", p))
}

# -----------------------------------
# Export
# -----------------------------------

df <- rbindlist(results)

fwrite(
  df,
  "timing_results_r_nonsym.csv"
)

cat("✅ Benchmark abgeschlossen\n")