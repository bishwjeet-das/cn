#include <limits.h>
#include<stdio.h>
int m[20][20], s[20][20];
void printOptimal(int i, int j)
{
    if (i == j)
    {
        printf("A%d", i);
    }
    else
    {
        printf("(");
        printOptimal(i, s[i][j]);
        printOptimal(s[i][j] + 1, j);
        printf(")");
    }
}
void matrixChainOrder(int p[], int n)
{
    int i, j, k, L, q;


    for (i = 1; i <= n; i++)
        m[i][i] = 0;
    for (L = 2; L <= n; L++)
    {
        for (i = 1; i <= n - L + 1; i++)
        {
            j = i + L - 1;
            m[i][j] = INT_MAX;

            for (k = i; k < j; k++)
            {
                q = m[i][k] + m[k + 1][j]
                    + p[i - 1] * p[k] * p[j];

                if (q < m[i][j])
                {
                    m[i][j] = q;
                    s[i][j] = k;
                }
            }
        }
    }
    printf("\n                    DP COST MATRIX (m)\n\n");
    printf("%8s", "");

    for (j = 1; j <= n; j++)
    {
        char col[10];
        sprintf(col, "A%d", j);
        printf("%8s", col);
    }

    printf("\n");
    for (i = 1; i <= n; i++)
    {
        char row[10];
        sprintf(row, "A%d", i);

        printf("%8s", row);

        for (j = 1; j <= n; j++)
        {
            if (j < i)
                printf("%8s", "-");
            else
                printf("%8d", m[i][j]);
        }

        printf("\n");
    }
    printf("\n                         K MATRIX (s)\n\n6");
    printf("%8s", "");

    for (j = 1; j <= n; j++)
    {
        char col[10];
        sprintf(col, "A%d", j);
        printf("%8s", col);
    }

    printf("\n");
    for (i = 1; i <= n; i++)
    {
        char row[10];
        sprintf(row, "A%d", i);

        printf("%8s", row);

        for (j = 1; j <= n; j++)
        {
            if (j <= i)
                printf("%8s", "-");
            else
                printf("%8d", s[i][j]);
        }

        printf("\n");
    }
    printf("\n                 OPTIMAL PARENTHESIZATION\n\n");
    printf("Order : ");
    printOptimal(1, n);

    printf("\n\nMinimum Scalar Multiplications = %d\n", m[1][n]);
}

int main()
{
    int n;

  
    printf("            MATRIX CHAIN MULTIPLICATION PROGRAM\n");
    printf("\nEnter number of matrices : ");
    scanf("%d", &n);
    int p[n + 1];
    printf("\nEnter dimensions of matrices:\n");
    for (int i = 1; i <= n; i++)
    {
        int row, col;

        printf("Enter dimensions of A%d : ", i);
        scanf("%d %d", &row, &col);

        if (i == 1)
            p[0] = row;
        p[i] = col;
    }
    matrixChainOrder(p, n);
    return 0;
}
