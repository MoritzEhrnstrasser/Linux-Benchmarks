############################################################
# RcppArmadillo Upper-Bound Benchmark (in-memory)
############################################################

library(Rcpp)
library(RcppArmadillo)

############################################################
# 1) C++ Benchmark-Funktion
############################################################

cppFunction(
  depends = "RcppArmadillo",
  code = '
  #include <RcppArmadillo.h>
  using namespace arma;

  // [[Rcpp::export]]
  double crossprod_benchmark_cpp(int N, int p) {

    // Zufallsdaten in C++ erzeugen
    mat X = randn<mat>(N, p);

    // Warmup
    mat tmp = X.t() * X;

    // Wallclock-Zeit
    auto t1 = std::chrono::high_resolution_clock::now();
    mat M = X.t() * X;
    auto t2 = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double> diff = t2 - t1;
    return diff.count(); // Sekunden
  }
  ',
  plugins = "cpp17",
  rebuild = TRUE
)

############################################################
# 2) Benchmark-Loop in R
############################################################

predictors <- seq(200, 4000, by = 200)
N <- 100000
isample <- 5

results <- data.frame(
  N = integer(),
  p = integer(),
  median_time_us = numeric(),
  sd_time_us = numeric()
)

for (p in predictors) {
  
  times <- replicate(isample, crossprod_benchmark_cpp(N, p))
  
  results <- rbind(
    results,
    data.frame(
      N = N,
      p = p,
      median_time_us = median(times) * 1e6,
      sd_time_us = sd(times) * 1e6
    )
  )
  
  cat(sprintf("Done: p=%d | median=%.1f µs\n", p, median(times) * 1e6))
}

write.csv(results, "timing_results_rcppArmadillo_upperbound.csv", row.names = FALSE)

cat("✅ RcppArmadillo Upper-Bound Benchmark abgeschlossen\n")





library(dplyr)
library(ggplot2)
library(scales)

j_plot <- j %>%
  mutate(
    lang = "Julia",
    median_s = median_time_us / 1e6
  )

arma_plot <- arma %>%
  mutate(
    lang = "RcppArmadillo",
    median_s = median_time_us / 1e6
  )

all_plot <- bind_rows(j_plot, arma_plot)

all_plot$lang <- factor(all_plot$lang, levels = c("RcppArmadillo", "Julia"))

ggplot(all_plot, aes(x = p, y = median_s, color = lang)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  labs(
    x = "Number of predictors (p)",
    y = "Median runtime (seconds)",
    color = "Implementation",
    title = "Upper-bound Crossproduct Benchmark (OpenBLAS, multi-threaded)"
  ) +
  scale_y_continuous(labels = label_number(accuracy = 0.01)) +
  theme_minimal(base_size = 18) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold")
  )

