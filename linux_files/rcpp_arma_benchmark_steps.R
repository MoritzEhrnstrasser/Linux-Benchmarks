library(Rcpp)
library(RcppArmadillo)
library(data.table)

# 🔧 BLAS Threads setzen (wird vom Terminal überschrieben)
Sys.setenv(OPENBLAS_NUM_THREADS = "1")

# C++ Funktion
Rcpp::cppFunction(depends = "RcppArmadillo", code = '

#include <RcppArmadillo.h>
#include <chrono>
using namespace Rcpp;
using namespace arma;
using namespace std::chrono;

// [[Rcpp::export]]
DataFrame arma_benchmark_steps_rcpp(int N, IntegerVector predictors, int isample) {

  int np = predictors.size();

  NumericVector xtx_median(np);
  NumericVector inv_median(np);
  NumericVector xty_median(np);

  // 🔥 Warmup
  {
    mat X = randn<mat>(N, predictors[0]);
    vec y = randn<vec>(N);
    mat XtX = X.t() * X;
    mat XtX_inv = inv(XtX);
    vec XtY = X.t() * y;
  }

  for (int j = 0; j < np; j++) {

    int p = predictors[j];

    std::vector<double> times_xtx;
    std::vector<double> times_inv;
    std::vector<double> times_xty;

    for (int i = 0; i < isample; i++) {

      mat X = randn<mat>(N, p);
      vec y = randn<vec>(N);

      // XtX
      auto t1 = high_resolution_clock::now();
      mat XtX = X.t() * X;
      auto t2 = high_resolution_clock::now();
      times_xtx.push_back(duration<double>(t2 - t1).count());

      // Inverse
      auto t3 = high_resolution_clock::now();
      mat XtX_inv = inv(XtX);
      auto t4 = high_resolution_clock::now();
      times_inv.push_back(duration<double>(t4 - t3).count());

      // XtY
      auto t5 = high_resolution_clock::now();
      vec XtY = X.t() * y;
      auto t6 = high_resolution_clock::now();
      times_xty.push_back(duration<double>(t6 - t5).count());
    }

    std::sort(times_xtx.begin(), times_xtx.end());
    std::sort(times_inv.begin(), times_inv.end());
    std::sort(times_xty.begin(), times_xty.end());

    xtx_median[j] = times_xtx[isample/2] * 1e6;
    inv_median[j] = times_inv[isample/2] * 1e6;
    xty_median[j] = times_xty[isample/2] * 1e6;

    Rcout << "Done: p=" << p << std::endl;
  }

  return DataFrame::create(
    Named("N") = rep(N, np),
    Named("p") = predictors,
    Named("xtx_median_us") = xtx_median,
    Named("inv_median_us") = inv_median,
    Named("xty_median_us") = xty_median
  );
}
')

# 🔧 Parameter
N <- 100000
predictors <- seq(200, 3000, by = 200)
isample <- 5

# ▶️ Benchmark
res <- arma_benchmark_steps_rcpp(N, predictors, isample)

# 💾 speichern
fwrite(res, "timing_results_rcpp.csv")

cat("✅ RcppArmadillo Benchmark abgeschlossen\n")
