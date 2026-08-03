using LinearAlgebra
using Statistics
using DelimitedFiles

function run_benchmark()

    # 🔧 Threads absichern
    LinearAlgebra.BLAS.set_num_threads(Threads.nthreads())

    # Parameter
    N = 100000
    predictors = 200:200:3000
    isample = 5

    results = []

    # 🔥 GLOBALER WARMUP (JIT + BLAS)
    X = randn(N, first(predictors))
    y = randn(N)
    X' * X
    inv(X' * X)
    X' * y

    for p in predictors
        
        times_xtx = Float64[]
        times_inv = Float64[]
        times_xty = Float64[]
        
        for i in 1:isample
            
            X = randn(N, p)
            y = randn(N)
            
            # XtX
            t1 = time()
            XtX = X' * X
            t2 = time()
            push!(times_xtx, t2 - t1)
            
            # Inverse
            t3 = time()
            XtX_inv = inv(XtX)
            t4 = time()
            push!(times_inv, t4 - t3)
            
            # XtY
            t5 = time()
            XtY = X' * y
            t6 = time()
            push!(times_xty, t6 - t5)
        end
        
        println("Done: p=$p")
        
        push!(results, (
            N = N,
            p = p,
            xtx_median_us = median(times_xtx) * 1e6,
            inv_median_us = median(times_inv) * 1e6,
            xty_median_us = median(times_xty) * 1e6
        ))
    end

    return results
end

# ▶️ Benchmark ausführen
results = run_benchmark()

# 💾 Speichern (R-kompatibel)
writedlm("timing_results_julia.csv", results, ',')

println("✅ Julia Benchmark abgeschlossen")
