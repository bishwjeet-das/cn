/* 
Factory Simulation Program
Functional Driven Approach in C

Problem:
- 10 workers assemble items
- Assembly time: Uniform(100, 300)
- Polishing time: Normal(mean=20, stddev=7), discard values < 5
- Workers wait if polishing machine is busy
- Find average waiting time for:
    1 polishing machine
    2 polishing machines
    3 polishing machines
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define WORKERS 10
#define ITEMS_PER_WORKER 1000

// Function prototypes
double uniform_random(double min, double max);
double normal_random(double mean, double stddev);
double simulate(int machines);


// Function to generate uniform random number
double uniform_random(double min, double max)
{
    return min + ((double)rand() / RAND_MAX) * (max - min);
}


// Function to generate normal random number
double normal_random(double mean, double stddev)
{
    double u1, u2, z;

    u1 = ((double)rand() + 1.0) / ((double)RAND_MAX + 1.0);
    u2 = ((double)rand() + 1.0) / ((double)RAND_MAX + 1.0);

    z = sqrt(-2.0 * log(u1)) * cos(2.0 * M_PI * u2);

    return mean + stddev * z;
}


// Simulation function
double simulate(int machines)
{
    double machine_free[10] = {0};

    double total_wait = 0;
    int total_items = WORKERS * ITEMS_PER_WORKER;

    int i, j;

    // Worker available time
    double worker_time[WORKERS] = {0};

    for(i = 0; i < WORKERS; i++)
    {
        for(j = 0; j < ITEMS_PER_WORKER; j++)
        {
            double assembly_time;
            double polish_time;

            double finish_assembly;

            int selected_machine = 0;

            double min_machine_time;

            double wait_time;

            // Generate assembly time
            assembly_time = uniform_random(100, 300);

            // Generate polishing time
            do
            {
                polish_time = normal_random(20, 7);

            } while(polish_time < 5);

            // Worker finishes assembly
            finish_assembly = worker_time[i] + assembly_time;

            // Find earliest free polishing machine
            min_machine_time = machine_free[0];

            selected_machine = 0;

            int k;

            for(k = 1; k < machines; k++)
            {
                if(machine_free[k] < min_machine_time)
                {
                    min_machine_time = machine_free[k];
                    selected_machine = k;
                }
            }

            // Waiting time calculation
            if(finish_assembly < machine_free[selected_machine])
                wait_time = machine_free[selected_machine] - finish_assembly;
            else
                wait_time = 0;

            total_wait += wait_time;

            // Update machine free time
            if(finish_assembly > machine_free[selected_machine])
                machine_free[selected_machine] = finish_assembly + polish_time;
            else
                machine_free[selected_machine] += polish_time;

            // Worker can start next item only after polishing finishes
            worker_time[i] = machine_free[selected_machine];
        }
    }

    return total_wait / total_items;
}


// Main function
int main()
{
    srand(time(NULL));

    double avg_wait;

    printf("\nFACTORY SIMULATION\n");

    // One polishing machine
    avg_wait = simulate(1);

    printf("\nAverage waiting time with 1 polishing machine : %.2f seconds", avg_wait);

    // Two polishing machines
    avg_wait = simulate(2);

    printf("\nAverage waiting time with 2 polishing machines : %.2f seconds", avg_wait);

    // Three polishing machines
    avg_wait = simulate(3);

    printf("\nAverage waiting time with 3 polishing machines : %.2f seconds\n", avg_wait);

    return 0;
}
