#include <armadillo>
#include <iostream>
#include <vector>
#include <chrono>
#include <fstream>
#include <algorithm>

using namespace arma;
using namespace std;
using namespace std::chrono;

// Median-Funktion
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

    ofstream file("timing_results_cpp.csv");

    // 🔥 HEADER (wichtig für R!)
    file << "N,p,xtx_median_us,inv_median_us,xty_median_us\n";

    // 🔥 Warmup (sehr wichtig!)
    {
        mat X = randn<mat>(N, predictors[0]);
        vec y = randn<vec>(N);

        mat XtX = X.t() * X;
        mat XtX_inv = inv(XtX);
        vec XtY = X.t() * y;
    }

    for (int p : predictors) {

        vector<double> times_xtx;
        vector<double> times_inv;
        vector<double> times_xty;

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

        double xtx_med = median(times_xtx) * 1e6;
        double inv_med = median(times_inv) * 1e6;
        double xty_med = median(times_xty) * 1e6;

        cout << "Done: p=" << p << endl;

        file << N << "," << p << ","
             << xtx_med << ","
             << inv_med << ","
             << xty_med << "\n";
    }

    file.close();

    cout << "✅ C++ Armadillo Benchmark abgeschlossen\n";

    return 0;
}
