#include <armadillo>
#include <cblas.h>
#include <iostream>
#include <vector>
#include <chrono>
#include <fstream>
#include <algorithm>

using namespace arma;
using namespace std;
using namespace std::chrono;

// Medianfunktion
double median(vector<double>& v) {
    sort(v.begin(), v.end());

    size_t n = v.size();

    if (n % 2 == 0)
        return (v[n/2 - 1] + v[n/2]) / 2.0;
    else
        return v[n/2];
}

int main() {

    int N = 100000;

    vector<int> predictors;

    for (int p = 200; p <= 3000; p += 200)
        predictors.push_back(p);

    int isample = 5;

    ofstream file("timing_results_cpp_dsyrk_nonsym.csv");

    file << "N,p,xtx_median_us,inv_median_us\n";

    // 🔥 Warmup
    {
        int p = predictors[0];

        mat X = randn<mat>(N, p);

        mat XtX(p, p, fill::zeros);

        cblas_dsyrk(
            CblasColMajor,
            CblasUpper,
            CblasTrans,
            p,
            N,
            1.0,
            X.memptr(),
            N,
            0.0,
            XtX.memptr(),
            p
        );

        mat A = randn<mat>(p, p);

        mat Ainv = inv(A);
    }

    // Hauptbenchmark
    for (int p : predictors) {

        vector<double> times_xtx;
        vector<double> times_inv;

        for (int i = 0; i < isample; i++) {

            // -----------------------------
            // XtX via DSYRK
            // -----------------------------

            mat X = randn<mat>(N, p);

            mat XtX(p, p, fill::zeros);

            auto t1 = high_resolution_clock::now();

            cblas_dsyrk(
                CblasColMajor,
                CblasUpper,
                CblasTrans,
                p,
                N,
                1.0,
                X.memptr(),
                N,
                0.0,
                XtX.memptr(),
                p
            );

            auto t2 = high_resolution_clock::now();

            times_xtx.push_back(
                duration<double>(t2 - t1).count()
            );

            // -----------------------------
            // NICHT symmetrische Inverse
            // -----------------------------

            mat A = randn<mat>(p, p);

            auto t3 = high_resolution_clock::now();

            mat Ainv = inv(A);

            auto t4 = high_resolution_clock::now();

            times_inv.push_back(
                duration<double>(t4 - t3).count()
            );
        }

        double xtx_med = median(times_xtx) * 1e6;
        double inv_med = median(times_inv) * 1e6;

        cout << "Done: p=" << p << endl;

        file
            << N << ","
            << p << ","
            << xtx_med << ","
            << inv_med << "\n";
    }

    file.close();

    cout << "✅ Benchmark abgeschlossen\n";

    return 0;
}
