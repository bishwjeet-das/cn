#include <stdio.h>

int board[20][20], n;
int solutionCount = 0;


void printSolution()
{
    int i, j;

    printf("\nSolution %d:\n\n", solutionCount);

    for(i = 0; i < n; i++)
    {
        for(j = 0; j < n; j++)
        {
            if(board[i][j] == 1)
                printf(" Q ");
            else
                printf(" . ");
        }
        printf("\n");
    }
}


int isSafe(int row, int col)
{
    int i, j;

    
    for(i = 0; i < col; i++)
    {
        if(board[row][i] == 1)
            return 0;
    }

   
    for(i = row, j = col; i >= 0 && j >= 0; i--, j--)
    {
        if(board[i][j] == 1)
            return 0;
    }

    
    for(i = row, j = col; i < n && j >= 0; i++, j--)
    {
        if(board[i][j] == 1)
            return 0;
    }

    return 1;
}


void solveNQUtil(int col)
{
    int i;

    
    if(col >= n)
    {
        solutionCount++;
        printSolution();
        return;
    }

    for(i = 0; i < n; i++)
    {
        if(isSafe(i, col))
        {
            board[i][col] = 1;

            solveNQUtil(col + 1);

            
            board[i][col] = 0;
        }
    }
}


int main()
{
    int i, j;

    printf("Enter no. of queens: ");
    scanf("%d", &n);

    
    for(i = 0; i < n; i++)
    {
        for(j = 0; j < n; j++)
        {
            board[i][j] = 0;
        }
    }

    solveNQUtil(0);

    if(solutionCount == 0)
    {
        printf("Solution does not exist\n");
    }

    return 0;
}
===========================================================================

#include <stdio.h>

int board[20][20];

int col[20];
int leftDiag[40];
int rightDiag[40];

int n;
int solutionCount = 0;


void printSolution()
{
    int i, j;

    printf("\nSolution %d:\n\n", solutionCount);

    for(i = 0; i < n; i++)
    {
        for(j = 0; j < n; j++)
        {
            if(board[i][j] == 1)
                printf(" Q ");
            else
                printf(" . ");
        }

        printf("\n");
    }
}


void solveNQ(int row)
{
    int j;

    
    if(row == n)
    {
        solutionCount++;

        printSolution();

        return;
    }

    
    for(j = 0; j < n; j++)
    {
        
        if(col[j] == 0 &&
           leftDiag[row - j + n - 1] == 0 &&
           rightDiag[row + j] == 0)
        {
            
            board[row][j] = 1;

            
            col[j] = 1;

            leftDiag[row - j + n - 1] = 1;

            rightDiag[row + j] = 1;

            
            solveNQ(row + 1);

            
            board[row][j] = 0;

            col[j] = 0;

            leftDiag[row - j + n - 1] = 0;

            rightDiag[row + j] = 0;
        }
    }
}


int main()
{
    int i, j;

    printf("Enter no. of queens: ");

    scanf("%d", &n);


    for(i = 0; i < n; i++)
    {
        for(j = 0; j < n; j++)
        {
            board[i][j] = 0;
        }
    }

    
    for(i = 0; i < 20; i++)
    {
        col[i] = 0;
    }

    for(i = 0; i < 40; i++)
    {
        leftDiag[i] = 0;

        rightDiag[i] = 0;
    }

    
    solveNQ(0);

    
    if(solutionCount == 0)
    {
        printf("Solution does not exist\n");
    }

    return 0;
}
=================================================================================

#include <stdio.h>

#define MAX 20

int graph[MAX][MAX];
int color[MAX];
int V, m;


int isSafe(int v, int c)
{
    int i;

    for(i = 0; i < V; i++)
    {
        if(graph[v][i] == 1 && color[i] == c)
        {
            return 0;
        }
    }

    return 1;
}


int graphColoringUtil(int v)
{
    int c;

    
    if(v == V)
        return 1;

    
    for(c = 1; c <= m; c++)
    {
        if(isSafe(v, c))
        {
            color[v] = c;

            if(graphColoringUtil(v + 1))
                return 1;

            
            color[v] = 0;
        }
    }

    return 0;
}


void printSolution()
{
    int i;

    printf("\nAssigned Colors:\n");

    for(i = 0; i < V; i++)
    {
        printf("Vertex %d ---> Color %d\n", i, color[i]);
    }
}


int main()
{
    int i, j;

    printf("Enter number of vertices: ");
    scanf("%d", &V);

    printf("Enter adjacency matrix:\n");

    for(i = 0; i < V; i++)
    {
        for(j = 0; j < V; j++)
        {
            scanf("%d", &graph[i][j]);
        }
    }

    printf("Enter number of colors: ");
    scanf("%d", &m);

    for(i = 0; i < V; i++)
    {
        color[i] = 0;
    }

    if(graphColoringUtil(0) == 0)
    {
        printf("Solution does not exist\n");
    }
    else
    {
        printSolution();
    }

    return 0;
}

==========================================================================================

/* TCP Calculator Server */

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>

struct sockaddr_in serv_addr, cli_addr;
int listenfd, connfd, r, w, cli_addr_len;
unsigned short serv_port = 25025;
char serv_ip[] = "127.0.0.1";
char buff[128];

void decToBinary(int n, char *res){
    char temp[64]; int i = 0;
    if(n == 0){ strcpy(res, "0"); return; }
    while(n > 0){ temp[i++] = (n % 2) + '0'; n /= 2; }
    int j = 0; while(i > 0) res[j++] = temp[--i];
    res[j] = '\0';
}

int binToDecimal(char *bin){
    int result = 0;
    for(int i = 0; bin[i] != '\0'; i++){
        if(bin[i] != '0' && bin[i] != '1') return -1;
        result = result * 2 + (bin[i] - '0');
    }
    return result;
}

int main(){
    char response[128];
    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);
    inet_aton(serv_ip, &serv_addr.sin_addr);

    printf("\nTCP CALCULATOR SERVER\n");

    if((listenfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
        printf("\nSERVER ERROR: Cannot create socket.\n"); exit(1);
    }
    if(bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0){
        printf("\nSERVER ERROR: Cannot bind.\n"); close(listenfd); exit(1);
    }
    if(listen(listenfd, 5) < 0){
        printf("\nSERVER ERROR: Cannot listen.\n"); close(listenfd); exit(1);
    }

    cli_addr_len = sizeof(cli_addr);

    while(1){
        printf("\nSERVER: Waiting for client...\n");
        if((connfd = accept(listenfd, (struct sockaddr*)&cli_addr, &cli_addr_len)) < 0){
            printf("\nSERVER ERROR: Cannot accept client.\n"); continue;
        }

        printf("\nConnected to %s\n", inet_ntoa(cli_addr.sin_addr));

        while(1){
            fd_set readfds;
            FD_ZERO(&readfds);
            FD_SET(connfd, &readfds);
            FD_SET(0, &readfds);
            select(connfd + 1, &readfds, NULL, NULL, NULL);

            if(FD_ISSET(0, &readfds)){
                fgets(buff, sizeof(buff), stdin);
                if(strncmp(buff, "exit", 4) == 0){
                    printf("SERVER: Disconnecting client...\n");
                    break;
                }
            }

            if(FD_ISSET(connfd, &readfds)){
                r = read(connfd, buff, sizeof(buff));
                if(r < 0){ printf("\nSERVER ERROR: Read failed.\n"); break; }
                if(r == 0){ printf("\nClient disconnected.\n"); break; }

                buff[r] = '\0';
                printf("CLIENT: %s", buff);

                if(strncmp(buff, "exit", 4) == 0){
                    printf("Client exited.\n"); break;
                }

                if(buff[0] == '1'){
                    int num;
                    if(sscanf(buff, "1 %d", &num) != 1) strcpy(response, "Invalid format");
                    else {printf("\n");decToBinary(num, response);}
                }
                else if(buff[0] == '2'){
                    char bin[100]; int val;
                    if(sscanf(buff, "2 %s", bin) != 1) strcpy(response, "Invalid format");
                    else{
                        val = binToDecimal(bin);
                        if(val == -1) strcpy(response, "Invalid binary number");
                        else {printf("\n");sprintf(response, "%d", val);}
                    }
                }
                else if(buff[0] == '3'){
                    char expr[100], command[200]; FILE *fp;
                    if(sscanf(buff, "3 %[^\n]", expr) != 1) strcpy(response, "Invalid format");
                    else{
                        sprintf(command, "echo \"%s\" | bc", expr);
                        fp = popen(command, "r");
                        if(fp == NULL) strcpy(response, "Error executing bc");
                        else{
                            if(fgets(response, sizeof(response), fp) == NULL) strcpy(response, "Invalid expression");
                            else response[strcspn(response, "\n")] = '\0';
                            pclose(fp);
                        }
                    }
                }
                else strcpy(response, "Invalid choice");

                printf("SERVER RESULT: %s\n", response);

                w = write(connfd, response, strlen(response));
                if(w < 0){ printf("\nSERVER ERROR: Write failed.\n"); break; }
            }
        }
        close(connfd);
    }
    close(listenfd);
    return 0;
}














/* TCP Calculator Client */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

struct sockaddr_in serv_addr;
int skfd, r, w;
unsigned short serv_port = 25025;
char serv_ip[] = "127.0.0.1";
char buff[128];

int main(){
    int choice;
    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);
    inet_aton(serv_ip, &serv_addr.sin_addr);

    printf("\nTCP CALCULATOR CLIENT\n");

    if((skfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
        printf("\nCLIENT ERROR: Cannot create socket.\n"); exit(1);
    }
    if(connect(skfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0){
        printf("\nCLIENT ERROR: Cannot connect.\n"); close(skfd); exit(1);
    }

    printf("\nConnected to server.\n");

    while(1){
        printf("\n===== MENU =====\n1. Decimal to Binary\n2. Binary to Decimal\n3. Solve Expression\n4. Exit\n");
        printf("Enter choice: ");
        scanf("%d", &choice);
        getchar();

        if(choice == 4){
            strcpy(buff, "exit");
            write(skfd, buff, strlen(buff));
            printf("Client exiting.\n");
            break;
        }

        if(choice == 1){
            int num;
            printf("Enter decimal number: ");
            scanf("%d", &num);
            getchar();
            sprintf(buff, "1 %d", num);
        }
        else if(choice == 2){
            printf("Enter binary number: ");
            scanf("%s", buff);
            getchar();
            char temp[128];
            snprintf(temp, sizeof(temp), "2 %s", buff);
            strcpy(buff, temp);
        }
        else if(choice == 3){
            printf("Enter expression: ");
            fgets(buff, sizeof(buff), stdin);
            char temp[128];
            snprintf(temp, sizeof(temp), "3 %s", buff);
            strcpy(buff, temp);
        }
        else{
            printf("Invalid choice. Try again.\n");
            continue;
        }

        w = write(skfd, buff, strlen(buff));
        if(w < 0){ printf("\nCLIENT ERROR: Write failed.\n"); break; }

        r = read(skfd, buff, sizeof(buff));
        if(r < 0){ printf("\nCLIENT ERROR: Read failed.\n"); break; }
        if(r == 0){ printf("\nServer disconnected.\n"); break; }

        buff[r] = '\0';
        printf("RESULT: %s\n", buff);
    }

    close(skfd);
    return 0;
}
















/* TCP Command Execution Server */

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>

struct sockaddr_in serv_addr, cli_addr;
int listenfd, connfd, r, w, cli_len;
unsigned short serv_port = 25035;
char serv_ip[] = "127.0.0.1";
char buff[256];

int main(){
    char response[2048];

    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);
    inet_aton(serv_ip, &serv_addr.sin_addr);

    printf("\nTCP COMMAND SERVER\n");

    if((listenfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
        printf("\nSERVER ERROR: Cannot create socket.\n"); exit(1);
    }
    if(bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0){
        printf("\nSERVER ERROR: Cannot bind.\n"); close(listenfd); exit(1);
    }
    if(listen(listenfd, 5) < 0){
        printf("\nSERVER ERROR: Cannot listen.\n"); close(listenfd); exit(1);
    }

    cli_len = sizeof(cli_addr);

    while(1){
        printf("\nSERVER: Waiting for client...\n");

        if((connfd = accept(listenfd, (struct sockaddr*)&cli_addr, &cli_len)) < 0){
            printf("\nSERVER ERROR: Cannot accept client.\n"); continue;
        }

        printf("\nConnected to %s\n", inet_ntoa(cli_addr.sin_addr));

        while(1){
            fd_set readfds;
            FD_ZERO(&readfds);
            FD_SET(connfd, &readfds);
            FD_SET(0, &readfds);

            select(connfd + 1, &readfds, NULL, NULL, NULL);

            if(FD_ISSET(0, &readfds)){
                fgets(buff, sizeof(buff), stdin);
                if(strncmp(buff, "exit", 4) == 0){
                    printf("SERVER: Disconnecting client...\n");
                    break;
                }
            }

            if(FD_ISSET(connfd, &readfds)){
                r = read(connfd, buff, sizeof(buff));
                if(r < 0){ printf("\nSERVER ERROR: Read failed.\n"); break; }
                if(r == 0){ printf("\nClient disconnected.\n"); break; }

                buff[r] = '\0';
                printf("CLIENT CMD: %s", buff);

                if(strncmp(buff, "exit", 4) == 0){
                    printf("Client exited.\n"); break;
                }

                /* HANDLE cd */
                if(strncmp(buff, "cd", 2) == 0){
                    char path[128];
                    if(sscanf(buff, "cd %s", path) != 1){
                        strcpy(response, "Invalid format");
                    } else{
                        if(chdir(path) == 0)
                            strcpy(response, "Directory changed");
                        else
                            strcpy(response, "Failed to change directory");
                    }

                    printf("SERVER RESULT: %s\n", response);
                    write(connfd, response, strlen(response));
                    continue;
                }

                /* EXECUTE COMMAND */
                FILE *fp = popen(buff, "r");
                if(fp == NULL){
                    strcpy(response, "Error executing command");
                    write(connfd, response, strlen(response));
                    continue;
                }

                char temp[256];
                response[0] = '\0';

                while(fgets(temp, sizeof(temp), fp) != NULL){
                    if(strlen(response) + strlen(temp) < sizeof(response)-1)
                        strcat(response, temp);
                    else
                        break;
                }

                /* SMALL OUTPUT */
                if(feof(fp)){
                    printf("SERVER RESULT:\n%s\n", response);
                    write(connfd, response, strlen(response));
                }
                /* LARGE OUTPUT */
                else{
                    FILE *file = fopen("output.txt", "w");
                    if(file == NULL){
                        strcpy(response, "File error");
                        write(connfd, response, strlen(response));
                    } else{
                        fputs(response, file);

                        while(fgets(temp, sizeof(temp), fp) != NULL)
                            fputs(temp, file);

                        fclose(file);

                        FILE *f = fopen("output.txt", "r");
                        fseek(f, 0, SEEK_END);
                        long size = ftell(f);
                        rewind(f);

                        sprintf(response, "FILE %ld", size);
                        write(connfd, response, strlen(response));

                        int n;
                        while((n = fread(temp, 1, sizeof(temp), f)) > 0)
                            write(connfd, temp, n);

                        fclose(f);

                        printf("SERVER RESULT: Sent as file (%ld bytes)\n", size);
                    }
                }

                pclose(fp);
            }
        }

        close(connfd);
    }

    close(listenfd);
    return 0;
}


















/* TCP Command Execution Client */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

struct sockaddr_in serv_addr;
int skfd, r, w;
unsigned short serv_port = 25035;
char serv_ip[] = "127.0.0.1";
char buff[256];

int main(){
    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);
    inet_aton(serv_ip, &serv_addr.sin_addr);

    printf("\nTCP COMMAND CLIENT\n");

    if((skfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
        printf("\nCLIENT ERROR: Cannot create socket.\n"); exit(1);
    }

    if(connect(skfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0){
        perror("CLIENT ERROR: Cannot connect");
        close(skfd); exit(1);
    }

    printf("\nConnected to server.\n");

    while(1){
        printf("\nEnter command (or exit): ");
        fgets(buff, sizeof(buff), stdin);

        w = write(skfd, buff, strlen(buff));
        if(w < 0){ printf("\nCLIENT ERROR: Write failed.\n"); break; }

        if(strncmp(buff, "exit", 4) == 0){
            printf("Client exiting.\n");
            break;
        }

        r = read(skfd, buff, sizeof(buff));
        if(r < 0){ printf("\nCLIENT ERROR: Read failed.\n"); break; }
        if(r == 0){ printf("\nServer disconnected.\n"); break; }

        buff[r] = '\0';

        /* FILE CASE */
        if(strncmp(buff, "FILE", 4) == 0){
            long filesize;
            sscanf(buff, "FILE %ld", &filesize);

            FILE *fp = fopen("received.txt", "w");
            if(fp == NULL){ printf("File error\n"); break; }

            printf("Receiving %ld bytes...\n", filesize);

            long received = 0;

            while(received < filesize){
                r = read(skfd, buff, sizeof(buff));
                if(r <= 0) break;

                fwrite(buff, 1, r, fp);
                received += r;
            }

            fclose(fp);
            printf("Saved to received.txt\n");
        }
        else{
            printf("OUTPUT:\n%s\n", buff);
        }
    }

    close(skfd);
    return 0;
}
