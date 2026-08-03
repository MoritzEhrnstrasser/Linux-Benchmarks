using LinearAlgebra, Statistics, Random, CSV, DataFrames

BLAS.set_num_threads(1)  

# Parameter
N = 100_000
predictors = 200:200:3000
isample = 5

results = Vector{NamedTuple}()

for p in predictors
    times = Float64[]

    for _ in 1:isample
        X = randn(N, p)

        # Warmup
        tmp = X' * X

        t1 = time()
        M = X' * X
        t2 = time()

        push!(times, t2 - t1)
    end

    println("Done: p=$p | median=$(median(times)*1e6) µs")

    push!(results, (
        N = N,
        p = p,
        median_time_us = median(times) * 1e6,
        sd_time_us = std(times) * 1e6
    ))
end

df = DataFrame(results)
CSV.write("timing_results_julia_upperbound.csv", df)

println("✅ Julia Upper-Bound Benchmark abgeschlossen")
