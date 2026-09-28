# Benchmarking Matrix Operations in R, Julia, C++, and RcppArmadillo

This repository contains the code and benchmark results for a computational comparison of basic matrix operations used in regression models. The benchmark focuses on the computational cost of the following sequence of operations:

$$
X^\top X
$$

$$
(X^\top X)^{-1}
$$

$$
X^\top y
$$

The benchmarks compare different implementations in R, Julia, C++, and RcppArmadillo, as well as different matrix multiplication strategies and BLAS configurations.

## Table of Contents

- [Benchmark Design](#benchmark-design)
- [Implementations](#implementations)
- [BLAS and Threading](#blas-and-threading)
- [Results](#results)
- [Interpretation](#interpretation)
- [Reproducibility](#reproducibility)

## Benchmark Design

The benchmark uses:

- $N = 100{,}000$ observations
- $p = 200, 400, \ldots, 3000$ predictors
- 5 repetitions per condition
- Median execution time reported for each operation
- Execution times reported in microseconds (µs)

For each value of $p$, a random predictor matrix $X$ and outcome vector $y$ are generated. The following operations are timed separately:

1. **$X^\top X$**: cross-product of the predictor matrix
2. **$(X^\top X)^{-1}$**: matrix inversion
3. **$X^\top y$**: cross-product between the predictor matrix and the outcome vector

Warm-up calculations are performed before timing to reduce the influence of initialization effects.

## Implementations

### R

#### `r_benchmark_manual`

Manual matrix multiplication using the general matrix multiplication operator:

```r
t(X) %*% X
```

This condition is included to contrast general matrix multiplication with R's specialized `crossprod()` implementation.

#### `r_benchmark_nonsym_steps.R`

Benchmark using a non-symmetric matrix product and a non-symmetric matrix inversion. This condition is used to examine performance when the symmetry of $X^\top X$ cannot be exploited.

#### `r_single_steps.R`

Benchmark using R's `crossprod()` implementation:

```r
crossprod(X)
solve(XtX)
crossprod(X, y)
```

The same benchmark code can be executed under different BLAS configurations. The corresponding Standard BLAS results are stored separately in the results directory.

### Julia

#### `julia_benchmark_steps.jl`

The Julia implementation uses standard matrix operations:

```julia
X' * X
inv(XtX)
X' * y
```

The benchmark was run with different numbers of computational threads.

### C++

#### `arma_benchmark_steps.cpp`

This implementation uses the [Armadillo](https://arma.sourceforge.net/) linear algebra library:

```cpp
X.t() * X
inv(XtX)
X.t() * y
```

The benchmark was conducted with different numbers of computational threads.

#### `arma_benchmark_steps_dsyrk_nonsym.cpp`

This implementation explicitly uses the BLAS `DSYRK` routine for the computation of $X^\top X$. It is included to examine the effect of using a symmetric rank-k update specifically optimized for this type of matrix product.

The inversion step in this benchmark uses a non-symmetric matrix.

### RcppArmadillo

#### `rcpp_arma_benchmark_steps.R`

This implementation performs the matrix operations through C++ code using RcppArmadillo. The benchmark allows the performance of Armadillo-based C++ code called from R to be examined separately from the standard R implementation.

## BLAS and Threading

The benchmarks depend not only on the programming language but also on the underlying linear algebra libraries and threading configuration.

The R benchmarks were conducted under different BLAS configurations. In particular, results labelled **R Standard BLAS** correspond to an R installation using the Standard BLAS configuration, whereas the other R benchmarks can use OpenBLAS with controlled thread counts.

For the multi-threaded conditions, the number of computational threads was controlled explicitly.

> [!NOTE]
> Because BLAS libraries can differ substantially in their implementation and optimization, the benchmark results should be interpreted as characteristics of the complete computational stack rather than as intrinsic properties of the programming languages themselves.

## Results

The benchmark results are provided as CSV files. Each result file contains the median execution time for the respective matrix operation and predictor dimension.

| Condition | Description | Files |
|---|---|---|
| **R** | `crossprod()` benchmark for 1, 4, and 8 threads | `timing_results_regression_steps_1_core.csv`<br>`timing_results_regression_steps_4_core.csv`<br>`timing_results_regression_steps_8_core.csv` |
| **R Standard BLAS** | R benchmark under the Standard BLAS configuration | `timing_results_regression_blas_steps_1_core.csv` |
| **R manual** | Manual `t(X) %*% X` multiplication | `timing_results_regression_manual_steps_1_core.csv`<br>`timing_results_regression_manual_steps_4_core.csv`<br>`timing_results_regression_manual_steps_8_core.csv` |
| **R non-symmetric** | Non-symmetric product and inversion | `timing_results_r_nonsym_1_core.csv`<br>`timing_results_r_nonsym_4_core.csv`<br>`timing_results_r_nonsym_8_core.csv` |
| **Julia** | Native Julia matrix operations | `timing_results_julia_1_core.csv`<br>`timing_results_julia_4_core.csv`<br>`timing_results_julia_8_core.csv` |
| **C++ / Armadillo** | Armadillo-based implementation | `timing_results_cpp_1_core.csv`<br>`timing_results_cpp_4_core.csv`<br>`timing_results_cpp_8_core.csv` |
| **C++ / DSYRK** | Explicit BLAS `DSYRK` call, non-symmetric inversion | `timing_results_cpp_dsyrk_nonsym_1_core.csv`<br>`timing_results_cpp_dsyrk_nonsym_4_core.csv`<br>`timing_results_cpp_dsyrk_nonsym_8_core.csv` |
| **RcppArmadillo** | Armadillo code called from R | `timing_results_rcpp_1_core.csv`<br>`timing_results_rcpp_4_core.csv`<br>`timing_results_rcpp_8_core.csv` |

### Result File Structure

The main benchmark result files contain the following columns:

| Column | Description |
|---|---|
| `N` | Number of observations |
| `p` | Number of predictors |
| `xtx_median_us` | Median execution time for $X^\top X$ |
| `xtx_sd_us` | Standard deviation of the execution time for $X^\top X$ |
| `inv_median_us` | Median execution time for matrix inversion |
| `inv_sd_us` | Standard deviation of the inversion time |
| `xty_median_us` | Median execution time for $X^\top y$ |
| `xty_sd_us` | Standard deviation of the execution time for $X^\top y$ |

All execution times are reported in **microseconds (µs)**.

## Interpretation

The benchmark is intended to examine how implementation choices affect computational performance for matrix operations relevant to regression models. In particular, the comparison distinguishes between:

- specialized cross-product operations such as `crossprod()`,
- general matrix multiplication,
- explicit BLAS routines such as `DSYRK`,
- Armadillo-based implementations,
- RcppArmadillo,
- Julia's native matrix operations, and
- different BLAS configurations and thread counts.

The results should **not** be interpreted as demonstrating that one programming language is universally faster than another. Matrix-operation performance depends on the complete software and hardware stack, including the programming language, numerical libraries, BLAS/LAPACK implementation, compiler, processor, and number of threads.

Exact execution times may therefore differ on other systems, even when the same benchmark code is used. The benchmark procedure and implementation can be reproduced, whereas identical absolute execution times are not expected across different hardware and software environments.

## Reproducibility

To reproduce the benchmark, use the corresponding implementation and keep the following identical:

- sample size $N$,
- predictor dimensions $p$,
- number of repetitions,
- BLAS implementation,
- number of threads,
- compiler settings (for C++), and
- relevant software/library versions.

For meaningful comparisons, the different implementations should be executed on the same hardware and under comparable threading conditions whenever possible.
