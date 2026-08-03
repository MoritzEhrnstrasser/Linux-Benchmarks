library(Rcpp)
library(RcppArmadillo)
library(data.table)

# OpenBLAS auf 1 Thread setzen (vorher im Terminal besser!)
Sys.setenv(OPENBLAS_NUM_THREADS = "1")

cppFunction(depends = "RcppArmadillo", code = '

#include <RcppArmadillo.h>
using namespace Rcpp;

// [[Rcpp::export]]
List crossprod_benchmark(int N, int p, int isample) {
    std::vector<double> times;

    for (int i = 0; i < isample; i++) {
        arma::mat X = arma::randn<arma::mat>(N, p);

        // Warmup
        arma::mat tmp = X.t() * X;

        auto t1 = std::chrono::high_resolution_clock::now();

        arma::mat M = X.t() * X;

        auto t2 = std::chrono::high_resolution_clock::now();

        double elapsed = std::chrono::duration<double>(t2 - t1).count();
        times.push_back(elapsed);
    }

    std::sort(times.begin(), times.end());

    double median;
    int n = times.size();
    if (n % 2 == 0)
        median = (times[n/2 - 1] + times[n/2]) / 2.0;
    else
        median = times[n/2];

    double mean = std::accumulate(times.begin(), times.end(), 0.0) / n;

    double sum = 0.0;
    for (double t : times)
        sum += (t - mean) * (t - mean);

    double sd = std::sqrt(sum / (n - 1));

    return List::create(
        Named("median") = median,
        Named("sd") = sd
    );
}
')

# Parameter
N <- 100000
predictors <- seq(200, 3000, by = 200)
isample <- 5

results <- list()

for (p in predictors) {
  res <- crossprod_benchmark(N, p, isample)
  
  median_us <- res$median * 1e6
  sd_us <- res$sd * 1e6
  
  cat(sprintf("Done: p=%d | median=%.2f µs\n", p, median_us))
  
  results[[length(results) + 1]] <- data.table(
    N = N,
    p = p,
    median_time_us = median_us,
    sd_time_us = sd_us
  )
}

df <- rbindlist(results)

fwrite(df, "timing_results_rcpp_arma.csv")

cat("✅ RcppArmadillo Benchmark abgeschlossen\n")