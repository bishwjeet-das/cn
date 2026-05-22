#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<time.h>

#define WORKERS 10
#define ITEMS 1000
#define M_PI 3.14159265358979323846

// Function to generate a uniform random value
double uniform_random(double min, double max)
{
    return min + ((double)rand() / RAND_MAX) * (max - min);
}

// Function to generate a normal random value
double normal_random(double mean, double stddev)
{
    double u1 = ((double)rand() + 1.0) / ((double)RAND_MAX + 1.0);
    double u2 = ((double)rand() + 1.0) / ((double)RAND_MAX + 1.0);

    double z = sqrt(-2.0 * log(u1)) * cos(2.0 * M_PI * u2);

    return mean + stddev * z;
}

// Function to simulate the system
void simulate(int machines)
{
    double machine_free[10];
    double worker_time[WORKERS];

    double total_wait = 0.0;
    int total_items = WORKERS * ITEMS;

    // Initially all machines are free
    for(int i=0;i<machines;i++)
        machine_free[i] = 0.0;

    // Initially all workers are free
    for(int i=0;i<WORKERS;i++)
        worker_time[i] = 0.0;

    // Simulation loop
    for(int i=0;i<ITEMS;i++)
    {
        for(int w=0;w<WORKERS;w++)
        {
            // Generate assembly time
            double assembly = uniform_random(100, 300);

            // Time when worker finishes assembly
            double finish_assembly = worker_time[w] + assembly;

            // Generate polishing time
            double polishing;

            do
            {
                polishing = normal_random(20, 7);
            }
            while(polishing < 5);

            // Find earliest available polishing machine
            int selected = 0;

            for(int j=1;j<machines;j++)
            {
                if(machine_free[j] < machine_free[selected])
                    selected = j;
            }

            // Start polishing time
            double start_polish;

            if(finish_assembly > machine_free[selected])
                start_polish = finish_assembly;
            else
                start_polish = machine_free[selected];

            // Waiting time
            double wait = start_polish - finish_assembly;

            total_wait += wait;

            // Machine becomes busy until polishing ends
            machine_free[selected] = start_polish + polishing;

            // Worker becomes free only after polishing
            worker_time[w] = machine_free[selected];
        }
    }

    // Print result
    printf("\nNumber of Polishing Machines = %d\n", machines);
    printf("Average Waiting Time per Item = %.2lf seconds\n",
           total_wait / total_items);
}

int main()
{
    srand(time(NULL));

    simulate(1);
    simulate(2);
    simulate(3);

    return 0;
}


=================================================================

#include <bits/stdc++.h>
using namespace std;

#define WORKERS  10
#define N        10000

// Given: Uniform random
double uniform_random(double min, double max) {
    return min + ((double)rand() / RAND_MAX) * (max - min);
}

// Given: Normal random (Box-Muller)
double normal_random(double mean, double stddev) {
    double u1 = ((double)rand() + 1.0) / ((double)RAND_MAX + 1.0);
    double u2 = ((double)rand() + 1.0) / ((double)RAND_MAX + 1.0);
    double z  = sqrt(-2.0 * log(u1)) * cos(2.0 * M_PI * u2);
    return mean + stddev * z;
}

double polishTime() {
    double t;
    do { t = normal_random(20.0, 7.0); } while (t < 5);
    return t;
}

int argmin(vector<double>& arr) {
    return min_element(arr.begin(), arr.end()) - arr.begin();
}

double simulate(int machines) {
    vector<double> worker(WORKERS, 0.0);
    vector<double> machine(machines, 0.0);

    double totalWait = 0;

    for (int item = 0; item < N; item++) {
        int w       = argmin(worker);
        double done = worker[w] + uniform_random(100.0, 300.0);

        int m           = argmin(machine);
        double mStart   = max(done, machine[m]);

        totalWait  += mStart - done;
        machine[m]  = mStart + polishTime();
        worker[w]   = machine[m];
    }

    return totalWait / N;
}

int main() {
    srand(time(NULL));

    cout << fixed << setprecision(4);
    cout << "Machines: 1 | Avg wait: " << simulate(1) << " seconds\n";
    cout << "Machines: 2 | Avg wait: " << simulate(2) << " seconds\n";
    cout << "Machines: 3 | Avg wait: " << simulate(3) << " seconds\n";
}
