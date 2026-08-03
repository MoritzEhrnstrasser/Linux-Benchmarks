library(ggplot2)
library(data.table)


#### R ####
R_1_core <- read.csv("~/timing_results_final/timing_results_regression_steps_1_core.csv")
R_4_core <- read.csv("~/timing_results_final/timing_results_regression_steps_4_core.csv")
R_8_core <- read.csv("~/timing_results_final/timing_results_regression_steps_8_core.csv")



R_1_core$cores <- 1
R_4_core$cores <- 4
R_8_core$cores <- 8

df <- rbindlist(list(R_1_core, R_4_core, R_8_core))

df_long <- melt(
  df,
  id.vars = c("N", "p", "cores"),
  measure.vars = c("xtx_median_us", "inv_median_us", "xty_median_us"),
  variable.name = "step",
  value.name = "time_us"
)

df_long$step <- factor(df_long$step,
                       levels = c("xtx_median_us", "inv_median_us", "xty_median_us"),
                       labels = c("XtX", "Inverse", "XtY")
)

df_long$time_us <- as.numeric(as.character(df_long$time_us))

df_long$lang <- "R crossprod()"

#### Julia ####

julia_1_core <- read.csv("~/timing_results_final/timing_results_julia_1_core.csv", header=FALSE)
julia_4_core <- read.csv("~/timing_results_final/timing_results_julia_4_core.csv", header=FALSE)
julia_8_core <- read.csv("~/timing_results_final/timing_results_julia_8_core.csv", header=FALSE)

colnames(julia_1_core) <- c("N", "p", "xtx_median_us", "inv_median_us", "xty_median_us")
colnames(julia_4_core) <- c("N", "p", "xtx_median_us", "inv_median_us", "xty_median_us")
colnames(julia_8_core) <- c("N", "p", "xtx_median_us", "inv_median_us", "xty_median_us")

julia_1_core$cores <- 1
julia_4_core$cores <- 4
julia_8_core$cores <- 8

julia_1_core$lang <- "Julia"
julia_4_core$lang <- "Julia"
julia_8_core$lang <- "Julia"

Julia_all <- rbindlist(list(julia_1_core, julia_4_core, julia_8_core))

Julia_long <- melt(
  Julia_all,
  id.vars = c("N", "p", "cores", "lang"),
  measure.vars = c("xtx_median_us", "inv_median_us", "xty_median_us"),
  variable.name = "step",
  value.name = "time_us"
)

Julia_long$step <- factor(Julia_long$step,
                          levels = c("xtx_median_us", "inv_median_us", "xty_median_us"),
                          labels = c("XtX", "Inverse", "XtY")
)






#### cpp arma ####

cpp_1_core <- read.csv("~/timing_results_final/timing_results_cpp_1_core.csv")
cpp_4_core <- read.csv("~/timing_results_final/timing_results_cpp_4_core.csv")
cpp_8_core <- read.csv("~/timing_results_final/timing_results_cpp_8_core.csv")

cpp_1_core$cores <- 1
cpp_4_core$cores <- 4
cpp_8_core$cores <- 8

cpp_1_core$lang <- "C++"
cpp_4_core$lang <- "C++"
cpp_8_core$lang <- "C++"


cpp_all <- rbindlist(list(cpp_1_core, cpp_4_core, cpp_8_core))

cpp_long <- melt(
  cpp_all,
  id.vars = c("N", "p", "cores", "lang"),
  measure.vars = c("xtx_median_us", "inv_median_us", "xty_median_us"),
  variable.name = "step",
  value.name = "time_us"
)


cpp_long$step <- factor(cpp_long$step,
                        levels = c("xtx_median_us", "inv_median_us", "xty_median_us"),
                        labels = c("XtX", "Inverse", "XtY")
)

df_long    <- df_long[,    .(N, p, cores, step, time_us, lang)]
Julia_long <- Julia_long[, .(N, p, cores, step, time_us, lang)]
cpp_long   <- cpp_long[,   .(N, p, cores, step, time_us, lang)]


#### Rcpp ####

rcpp_1_core <- read.csv("~/timing_results_final/timing_results_rcpp_1_core.csv")
rcpp_4_core <- read.csv("~/timing_results_final/timing_results_rcpp_4_core.csv")
rcpp_8_core <- read.csv("~/timing_results_final/timing_results_rcpp_8_core.csv")



rcpp_1_core$cores <- 1
rcpp_4_core$cores <- 4
rcpp_8_core$cores <- 8

rcpp_1_core$lang <- "RcppArmadillo"
rcpp_4_core$lang <- "RcppArmadillo"
rcpp_8_core$lang <- "RcppArmadillo"

rcpp_all <- rbindlist(list(rcpp_1_core, rcpp_4_core, rcpp_8_core))

rcpp_long <- melt(
  rcpp_all,
  id.vars = c("N", "p", "cores", "lang"),
  measure.vars = c("xtx_median_us", "inv_median_us", "xty_median_us"),
  variable.name = "step",
  value.name = "time_us"
)

rcpp_long$step <- factor(rcpp_long$step,
                         levels = c("xtx_median_us", "inv_median_us", "xty_median_us"),
                         labels = c("XtX", "Inverse", "XtY")
)

rcpp_long$time_us <- as.numeric(rcpp_long$time_us)


#### dsyrk Inverse A⁻1 crossprd mit dsyrk ####

dsyrk_1_core <- read.csv("~/timing_results_final/timing_results_cpp_dsyrk_nonsym_1_core.csv")
dsyrk_4_core <- read.csv("~/timing_results_final/timing_results_cpp_dsyrk_nonsym_4_core.csv")
dsyrk_8_core <- read.csv("~/timing_results_final/timing_results_cpp_dsyrk_nonsym_8_core.csv")




dsyrk_1_core$cores <- 1
dsyrk_4_core$cores <- 4
dsyrk_8_core$cores <- 8



dsyrk_1_core$lang <- "C++ DSYRK"
dsyrk_4_core$lang <- "C++ DSYRK"
dsyrk_8_core$lang <- "C++ DSYRK"


dsyrk_all <- rbindlist(list(
  dsyrk_1_core,
  dsyrk_4_core,
  dsyrk_8_core
))



dsyrk_long <- melt(
  dsyrk_all,
  id.vars = c("N", "p", "cores", "lang"),
  measure.vars = c("xtx_median_us", "inv_median_us"),
  variable.name = "step",
  value.name = "time_us"
)


dsyrk_long$step <- factor(
  dsyrk_long$step,
  levels = c("xtx_median_us", "inv_median_us"),
  labels = c("XtX", "Inverse")
)





dsyrk_long$time_us <- as.numeric(dsyrk_long$time_us)



dsyrk_long <- dsyrk_long[, .(
  N,
  p,
  cores,
  step,
  time_us,
  lang
)]



#### Ŕ manuell  crossprod = X'Xt####

R_manuell_1_core <- read.csv("~/timing_results_final/timing_results_regression_manual_steps_1_core.csv")
R_manuell_4_core <- read.csv("~/timing_results_final/timing_results_regression_manual_steps_4_core.csv")
R_manuell_8_core <- read.csv("~/timing_results_final/timing_results_regression_manual_steps_8_core.csv")



R_manuell_1_core$cores <- 1
R_manuell_4_core$cores <- 4
R_manuell_8_core$cores <- 8



R_manuell_1_core$lang <- "R manual"
R_manuell_4_core$lang <- "R manual"
R_manuell_8_core$lang <- "R manual"


R_manuell_all <- rbindlist(list(
  R_manuell_1_core,
  R_manuell_4_core,
  R_manuell_8_core
))


R_manuell_long <- melt(
  R_manuell_all,
  id.vars = c("N", "p", "cores", "lang"),
  measure.vars = c(
    "xtx_median_us",
    "inv_median_us",
    "xty_median_us"
  ),
  variable.name = "step",
  value.name = "time_us"
)



R_manuell_long$step <- factor(
  R_manuell_long$step,
  levels = c(
    "xtx_median_us",
    "inv_median_us",
    "xty_median_us"
  ),
  labels = c(
    "XtX",
    "Inverse",
    "XtY"
  )
)


R_manuell_long$time_us <- as.numeric(
  R_manuell_long$time_us
)


R_manuell_long <- R_manuell_long[, .(
  N,
  p,
  cores,
  step,
  time_us,
  lang
)]



#### R standard Blas ####

R_standardblas <- read.csv("~/timing_results_final/timing_results_regression_blas_steps_1_core.csv")
R_standardblas <- as.data.table(R_standardblas)

R_standardblas$cores <- 1


R_standardblas$lang <- "R Standard BLAS"


R_standardblas_long <- melt(
  R_standardblas,
  id.vars = c("N", "p", "cores", "lang"),
  measure.vars = c(
    "xtx_median_us",
    "inv_median_us",
    "xty_median_us"
  ),
  variable.name = "step",
  value.name = "time_us"
)



R_standardblas_long$step <- factor(
  R_standardblas_long$step,
  levels = c(
    "xtx_median_us",
    "inv_median_us",
    "xty_median_us"
  ),
  labels = c(
    "XtX",
    "Inverse",
    "XtY"
  )
)



R_standardblas_long$time_us <- as.numeric(
  R_standardblas_long$time_us
)



R_standardblas_long <- R_standardblas_long[, .(
  N,
  p,
  cores,
  step,
  time_us,
  lang
)]


#### r nonsym crossprod(X,Y), Inverse A⁻1####



r_nonsym_1_core <- read.csv("~/timing_results_final/timing_results_r_nonsym_1_core.csv")
r_nonsym_4_core <- read.csv("~/timing_results_final/timing_results_r_nonsym_4_core.csv")
r_nonsym_8_core <- read.csv("~/timing_results_final/timing_results_r_nonsym_8_core.csv")


r_nonsym_1_core <- as.data.table(r_nonsym_1_core)
r_nonsym_4_core <- as.data.table(r_nonsym_4_core)
r_nonsym_8_core <- as.data.table(r_nonsym_8_core)


r_nonsym_1_core$cores <- 1
r_nonsym_4_core$cores <- 4
r_nonsym_8_core$cores <- 8


r_nonsym_1_core$lang <- "R nonsym"
r_nonsym_4_core$lang <- "R nonsym"
r_nonsym_8_core$lang <- "R nonsym"


r_nonsym_all <- rbindlist(list(
  r_nonsym_1_core,
  r_nonsym_4_core,
  r_nonsym_8_core
))


r_nonsym_long <- melt(
  r_nonsym_all,
  id.vars = c("N", "p", "cores", "lang"),
  measure.vars = c(
    "xtz_median_us",
    "inv_median_us",
    "xty_median_us"
  ),
  variable.name = "step",
  value.name = "time_us"
)


r_nonsym_long$step <- factor(
  r_nonsym_long$step,
  levels = c(
    "xtz_median_us",
    "inv_median_us",
    "xty_median_us"
  ),
  labels = c(
    "XtZ",
    "Inverse nonsym",
    "XtY"
  )
)


r_nonsym_long$time_us <- as.numeric(
  r_nonsym_long$time_us
)


r_nonsym_long <- r_nonsym_long[, .(
  N,
  p,
  cores,
  step,
  time_us,
  lang
)]


r_nonsym_long$step <- as.character(r_nonsym_long$step)

r_nonsym_long$step[
  r_nonsym_long$step == "XtZ"
] <- "XtX"

r_nonsym_long$step[
  r_nonsym_long$step == "Inverse nonsym"
] <- "Inverse"

r_nonsym_long$step <- factor(
  r_nonsym_long$step,
  levels = c("XtX", "Inverse", "XtY")
)





#### Grafik ####


df_all <- rbindlist(list(df_long, Julia_long, cpp_long,rcpp_long,dsyrk_long, R_manuell_long,R_standardblas_long,r_nonsym_long),use.names = T)



df_all$language <- fifelse(
  grepl("^R", df_all$lang), "R",
  fifelse(
    grepl("^Julia", df_all$lang), "Julia",
    "C++"
  )
)


df_all$variant <- "Standard"

df_all$variant[grepl("DSYRK", df_all$lang)] <- "DSYRK"

df_all$variant[grepl("manual", df_all$lang)] <- "manual"

df_all$variant[grepl("nonsym", df_all$lang)] <- "nonsym"

df_all$variant[grepl("Standard BLAS", df_all$lang)] <- "Std BLAS"

df_all$variant[grepl("Rcpp", df_all$lang)] <- "RcppArmadillo"












ggplot(df_all,
       aes(x = p,
           y = time_us,
           color = lang,
           linetype = lang,
           shape = lang)) +
  
  geom_line(linewidth = 1) +
  
  scale_y_log10()+
  
  facet_grid(step ~ cores, scales = "free_y") +
  
 
  
  labs(
    x = "Number of predictors (p)",
    y = "Time (µs)",
    color = "lang"
  ) +
  
  theme_minimal(base_size = 13)







ranking <- df_all[
  ,
  .(
    median_time = median(time_us, na.rm = TRUE),
    mean_time   = mean(time_us, na.rm = TRUE)
  ),
  by = lang
][order(median_time)]

ranking[, rank := 1:.N]

ranking