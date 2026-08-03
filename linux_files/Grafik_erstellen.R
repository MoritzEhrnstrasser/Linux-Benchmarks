
library(ggplot2)
library(data.table)

 cpp <- read.csv("~/Dokumente/Post-selective Inference/Rcpp Armadillo Moritz/Ergebnisse Benchmark/timing_results_cpp_upperbound_04.csv")
 julia <- read.csv("~/Dokumente/Post-selective Inference/Rcpp Armadillo Moritz/Ergebnisse Benchmark/timing_results_julia_upperbound_04.csv")
 r <- read.csv("~/Dokumente/Post-selective Inference/Rcpp Armadillo Moritz/Ergebnisse Benchmark/timing_results_r_upperbound_single_core_04.csv")
 rcpp <- read.csv("~/Dokumente/Post-selective Inference/Rcpp Armadillo Moritz/Ergebnisse Benchmark/timing_results_rcpp_arma_04.csv")
 cpp_cm <- read.csv("~/timing_results_cpp_upperbound_major_column.csv")
 cpp_dsyrk <- read.csv("~/timing_results_cpp_dsyrk.csv")
 
 
 cpp_dsyrk$method <- "dsyrk"
 julia$method <- "Julia"
 r$method     <- "R"
 cpp$method   <- "C++"
 rcpp$method  <- "RcppArmadillo"
 cpp_cm$method   <- "C++_cm"
 df <- rbindlist(list(julia, r, cpp, rcpp,cpp_cm,cpp_dsyrk))

 ggplot(df, aes(x = p, y = median_time_us, color = method)) +
   geom_line(size = 1) +
   geom_point() +
   labs(
     title = "Benchmark: X'X (Single-Core, OpenBLAS)",
     x = "Anzahl Prädiktoren (p)",
     y = "Median Laufzeit (µs)",
     color = "Methode"
   ) +
   theme_minimal()
 