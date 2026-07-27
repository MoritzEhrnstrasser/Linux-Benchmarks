#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <cmath>
#include <algorithm>
#include <numeric>
#include <fstream>

extern "C" {
    #include <cblas.h>
}

// Median
double median(std::vector<double>& v) {
    std::sort(v.begin(), v.end());
    size_t n = v.size();
    if (n % 2 == 0)
        return (v[n/2 - 1] + v[n/2]) / 2.0;
    else
        return v[n/2];
}

// Standardabweichung
double stddev(const std::vector<double>& v) {
    double mean = std::accumulate(v.begin(), v.end(), 0.0) / v.size();
    double sum = 0.0;
    for (double x : v)
        sum += (x - mean) * (x - mean);
    return std::sqrt(sum / (v.size() - 1));
}

int main() {
    const int N = 100000;
    const int isample = 5;

    std::vector<int> predictors;
    for (int p = 200; p <= 3000; p += 200)
        predictors.push_back(p);

    std::mt19937 gen(42);
    std::normal_distribution<> dist(0.0, 1.0);

    std::ofstream file("timing_results_cpp_dsyrk.csv");
    file << "N,p,median_time_us,sd_time_us\n";

    for (int p : predictors) {
        std::vector<double> times;

        for (int s = 0; s < isample; ++s) {

            std::vector<double> X(N * p);
            std::vector<double> M(p * p);

            // ✅ Column-Major korrekt füllen
            for (int j = 0; j < p; ++j) {
                for (int i = 0; i < N; ++i) {
                    X[i + j * N] = dist(gen);
                }
            }

            // Warmup
            cblas_dsyrk(
                CblasColMajor,
                CblasUpper,
                CblasTrans,
                p, N,
                1.0,
                X.data(), N,
                0.0,
                M.data(), p
            );

            auto t1 = std::chrono::high_resolution_clock::now();

            // 🔥 Optimale Operation: X'X
            cblas_dsyrk(
                CblasColMajor,
                CblasUpper,
                CblasTrans,
                p, N,
                1.0,
                X.data(), N,
                0.0,
                M.data(), p
            );

            auto t2 = std::chrono::high_resolution_clock::now();

            double elapsed = std::chrono::duration<double>(t2 - t1).count();
            times.push_back(elapsed);
        }

        double med = median(times) * 1e6;
        double sd = stddev(times) * 1e6;

        std::cout << "Done: p=" << p
                  << " | median=" << med << " us\n";

        file << N << "," << p << "," << med << "," << sd << "\n";
    }

    file.close();

    std::cout << "✅ C++ dsyrk Benchmark abgeschlossen\n";
}
