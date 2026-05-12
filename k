#include <stdio.h>
#include <limits.h>

#define MAX 100


void printOptimalParenthesis(int s[MAX][MAX], int i, int j) {
    if (i == j) {
        printf("A%d", i);
    } else {
        printf("(");

        // Print left side
        printOptimalParenthesis(s, i, s[i][j]);

        // Print right side
        printOptimalParenthesis(s, s[i][j] + 1, j);

        printf(")");
    }
}


int MatrixChainOrder(int p[], int n) {

    int m[MAX][MAX];
    int s[MAX][MAX];

    int i, j, k, L, q;

    // Initialize diagonal elements as 0
    for (i = 1; i < n; i++) {
        m[i][i] = 0;
    }

    
    for (L = 2; L < n; L++) {

        for (i = 1; i < n - L + 1; i++) {

            j = i + L - 1;

            m[i][j] = INT_MAX;

            for (k = i; k <= j - 1; k++) {

                // Cost calculation
                q = m[i][k] + m[k + 1][j]
                    + p[i - 1] * p[k] * p[j];

                
                if (q < m[i][j]) {
                    m[i][j] = q;
                    s[i][j] = k;
                }
            }
        }
    }

    printf("\nOptimal Parenthesization is: ");
    printOptimalParenthesis(s, 1, n - 1);

    printf("\nMinimum number of scalar multiplications = %d\n",
           m[1][n - 1]);

    return m[1][n - 1];
}

int main() {

    int n, i;

    printf("Enter number of matrices: ");
    scanf("%d", &n);

    int p[n + 1];

    printf("Enter dimensions array:\n");

    for (i = 0; i <= n; i++) {
        scanf("%d", &p[i]);
    }

    MatrixChainOrder(p, n + 1);

    return 0;
}
