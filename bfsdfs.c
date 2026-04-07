#include <stdio.h>

#define MAX 100

int adj[MAX][MAX];
int vis[MAX];
int queue[MAX], front = -1, rear = -1;
int stack[MAX], top = -1;
int n;

// ---------------- QUEUE FUNCTIONS (BFS) ----------------
void add(int item)
{
    if (rear == MAX - 1)
    {
        printf("Queue Overflow\n");
        return;
    }
    if (front == -1)
        front = 0;

    queue[++rear] = item;
}

int delete()
{
    if (front == -1 || front > rear)
        return 0;

    return queue[front++];
}

// ---------------- STACK FUNCTIONS (DFS) ----------------
void push(int item)
{
    if (top == MAX - 1)
    {
        printf("Stack Overflow\n");
        return;
    }
    stack[++top] = item;
}

int pop()
{
    if (top == -1)
        return 0;

    return stack[top--];
}

// ---------------- BFS FUNCTION ----------------
void bfs(int s)
{
    int p, i;

    add(s);
    vis[s] = 1;

    p = delete();

    while (p != 0)
    {
        printf("%d ", p);

        for (i = 1; i <= n; i++)
        {
            if (adj[p][i] == 1 && vis[i] == 0)
            {
                add(i);
                vis[i] = 1;
            }
        }

        p = delete();
    }
}

// ---------------- DFS FUNCTION ----------------
void dfs(int s)
{
    int p, i;

    push(s);
    vis[s] = 1;

    p = pop();

    while (p != 0)
    {
        printf("%d ", p);

        for (i = n; i >= 1; i--)
        {
            if (adj[p][i] == 1 && vis[i] == 0)
            {
                push(i);
                vis[i] = 1;
            }
        }

        p = pop();
    }
}

// ---------------- MAIN FUNCTION ----------------
int main()
{
    int i, j, start;

    printf("Enter number of nodes: ");
    scanf("%d", &n);

    printf("Enter adjacency matrix (Directed Graph):\n");
    for (i = 1; i <= n; i++)
    {
        for (j = 1; j <= n; j++)
        {
            scanf("%d", &adj[i][j]);
        }
    }

    printf("Enter starting node: ");
    scanf("%d", &start);

    // BFS
    for (i = 1; i <= n; i++)
        vis[i] = 0;

    printf("\nBFS Traversal: ");
    bfs(start);

    // DFS
    for (i = 1; i <= n; i++)
        vis[i] = 0;

    printf("\nDFS Traversal: ");
    dfs(start);

    return 0;
}