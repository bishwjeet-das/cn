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




============================================================time--------------------------------------------------------------------------------------
/* TCP Continuous Time Server */

#include<sys/socket.h>
#include<sys/types.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<string.h>
#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<time.h>

struct sockaddr_in serv_addr, cli_addr;

int listenfd, connfd, r, w, cli_addr_len;

unsigned short serv_port = 25020;
char serv_ip[] = "127.0.0.1";

char buff[128];

int main()
{
time_t current_time;

bzero(&serv_addr, sizeof(serv_addr));

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(serv_port);
inet_aton(serv_ip, (&serv_addr.sin_addr));

printf("\nTCP TIME SERVER.\n");

if((listenfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
{
    printf("\nSERVER ERROR: Cannot create socket.\n");
    exit(1);
}

if((bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr))) < 0)
{
    printf("\nSERVER ERROR: Cannot bind.\n");
    close(listenfd);
    exit(1);
}

if((listen(listenfd, 5)) < 0)
{
    printf("\nSERVER ERROR: Cannot listen.\n");
    close(listenfd);
    exit(1);
}

cli_addr_len = sizeof(cli_addr);

for( ; ; )
{
    printf("\nSERVER: Waiting for client...\n");

    if((connfd = accept(listenfd, (struct sockaddr*)&cli_addr, &cli_addr_len)) < 0)
    {
        printf("\nSERVER ERROR: Cannot accept client.\n");
        continue;
    }

    printf("\nConnected to %s\n", inet_ntoa(cli_addr.sin_addr));

    while(1)
    {
        /* receive request */
        r = read(connfd, buff, 128);
        if(r < 0)
        {
            printf("\nSERVER ERROR: Read failed.\n");
            break;
        }
        if(r == 0)
        {
            printf("\nClient disconnected.\n");
            break;
        }

        buff[r] = '\0';
        printf("CLIENT: %s\n", buff);

        if(strncmp(buff, "exit", 4) == 0)
        {
            printf("Client exited.\n");
            break;
        }

        /* get time */
        time(&current_time);
        strcpy(buff, ctime(&current_time));

        /* send time */
        if((w = write(connfd, buff, strlen(buff))) < 0)
        {
            printf("\nSERVER ERROR: Write failed.\n");
            break;
        }
        else
        {
            printf("SERVER: Sent time to client.\n");
        }
    }

    close(connfd);
}
}


/* TCP Continuous Time Client */

#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<string.h>
#include<stdlib.h>
#include<stdio.h>
#include<unistd.h>

struct sockaddr_in serv_addr;

int skfd, r, w;

unsigned short serv_port = 25020;
char serv_ip[] = "127.0.0.1";

char buff[128];

int main()
{
bzero(&serv_addr, sizeof(serv_addr));

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(serv_port);
inet_aton(serv_ip, (&serv_addr.sin_addr));

printf("\nTCP TIME CLIENT.\n");

if((skfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
{
    printf("\nCLIENT ERROR: Cannot create socket.\n");
    exit(1);
}

if((connect(skfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr))) < 0)
{
    printf("\nCLIENT ERROR: Cannot connect.\n");
    close(skfd);
    exit(1);
}

printf("\nConnected to server.\n");

while(1)
{
    /* ask user */
    printf("\nEnter 'time' to get current time or 'exit' to quit: ");
    fgets(buff, 128, stdin);

    /* send request */
    w = write(skfd, buff, strlen(buff));
    if(w < 0)
    {
        printf("\nCLIENT ERROR: Write failed.\n");
        break;
    }

    if(strncmp(buff, "exit", 4) == 0)
    {
        printf("Client exiting.\n");
        break;
    }

    /* receive time */
    r = read(skfd, buff, 128);
    if(r < 0)
    {
        printf("\nCLIENT ERROR: Read failed.\n");
        break;
    }

    if(r == 0)
    {
        printf("\nServer disconnected.\n");
        break;
    }

    buff[r] = '\0';
    printf("SERVER TIME: %s\n", buff);
}

close(skfd);
return 0;
}

=====================================================================TIME 2====================================================================================
/* TCP TIME SERVER */

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

int main()
{
    int listenfd, connfd, r, w;
    struct sockaddr_in serv_addr, cli_addr;
    socklen_t cli_len;
    char buff[128];
    time_t current_time;

    unsigned short serv_port = 25020;
    char serv_ip[] = "127.0.0.1";

    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);
    inet_aton(serv_ip, &serv_addr.sin_addr);

    printf("\nTCP TIME SERVER\n");

    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    if(listenfd < 0)
    {
        perror("Socket creation failed");
        exit(1);
    }

    if(bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0)
    {
        perror("Bind failed");
        close(listenfd);
        exit(1);
    }

    if(listen(listenfd, 5) < 0)
    {
        perror("Listen failed");
        close(listenfd);
        exit(1);
    }

    while(1)
    {
        printf("\nWaiting for client...\n");

        cli_len = sizeof(cli_addr);
        connfd = accept(listenfd, (struct sockaddr*)&cli_addr, &cli_len);
        if(connfd < 0)
        {
            perror("Accept failed");
            continue;
        }

        printf("Connected to client: %s\n", inet_ntoa(cli_addr.sin_addr));

        while(1)
        {
            r = read(connfd, buff, sizeof(buff)-1);

            if(r <= 0)
            {
                printf("Client disconnected.\n");
                break;
            }

            buff[r] = '\0';
            printf("CLIENT REQUEST: %s\n", buff);

            if(strcmp(buff, "exit") == 0)
            {
                printf("Client exited.\n");
                break;
            }

            if(strcmp(buff, "time") == 0)
            {
                time(&current_time);
                strcpy(buff, ctime(&current_time));

                // display on server
                printf("SERVER TIME: %s", buff);
            }
            else
            {
                strcpy(buff, "Invalid command. Type 'time' or 'exit'\n");
            }

            w = write(connfd, buff, strlen(buff));
            if(w <= 0)
            {
                printf("Write failed.\n");
                break;
            }
        }

        close(connfd);
    }

    close(listenfd);
    return 0;
}



/* TCP TIME CLIENT */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main()
{
    int skfd, r, w;
    struct sockaddr_in serv_addr;
    char buff[128];

    unsigned short serv_port = 25020;
    char serv_ip[] = "127.0.0.1";

    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);
    inet_aton(serv_ip, &serv_addr.sin_addr);

    printf("\nTCP TIME CLIENT\n");

    skfd = socket(AF_INET, SOCK_STREAM, 0);
    if(skfd < 0)
    {
        perror("Socket creation failed");
        exit(1);
    }

    if(connect(skfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0)
    {
        perror("Connection failed (Server may be OFF)");
        close(skfd);
        exit(1);
    }

    printf("Connected to server.\n");

    while(1)
    {
        printf("\nEnter 'time' or 'exit': ");
        fgets(buff, sizeof(buff), stdin);

        // remove newline
        buff[strcspn(buff, "\n")] = 0;

        w = write(skfd, buff, strlen(buff));
        if(w <= 0)
        {
            printf("SERVER CLOSED or CONNECTION LOST.\n");
            break;
        }

        if(strcmp(buff, "exit") == 0)
        {
            printf("Client exiting.\n");
            break;
        }

        r = read(skfd, buff, sizeof(buff)-1);
        if(r <= 0)
        {
            printf("SERVER CLOSED or CONNECTION LOST.\n");
            break;
        }

        buff[r] = '\0';
        printf("SERVER TIME: %s", buff);
    }

    close(skfd);
    return 0;
}



====================================================================day 6=====================================================================================
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


================================================================Todey corrected=======================================================================================
  /* FINAL TCP CALCULATOR SERVER */

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>

#define MAX 128

struct sockaddr_in serv_addr, cli_addr;
int listenfd, connfd, r, w, cli_len;
unsigned short serv_port = 25025;
char serv_ip[] = "127.0.0.1";

/* -------- Decimal to Binary -------- */
void decToBinary(long long n, char *res) {
    if (n < 0) {
        strcpy(res, "Negative not supported");
        return;
    }
    if (n == 0) {
        strcpy(res, "0");
        return;
    }

    char temp[64];
    int i = 0;

    while (n > 0 && i < 63) {
        temp[i++] = (n % 2) + '0';
        n /= 2;
    }

    int j = 0;
    while (i > 0) res[j++] = temp[--i];
    res[j] = '\0';
}

/* -------- Binary to Decimal -------- */
long long binToDecimal(char *bin) {
    long long result = 0;

    for (int i = 0; bin[i]; i++) {
        if (bin[i] != '0' && bin[i] != '1')
            return -1;
        result = result * 2 + (bin[i] - '0');
    }
    return result;
}

/* -------- Expression Evaluation (Stack) -------- */
int precedence(char op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
}

long long applyOp(long long a, long long b, char op, int *err) {
    switch (op) {
        case '+': return a + b;
        case '-': return a - b;
        case '*': return a * b;
        case '/':
            if (b == 0) { *err = 1; return 0; }
            return a / b;
    }
    *err = 1;
    return 0;
}

int evaluate(char *expr, char *res) {
    long long values[100];
    char ops[100];
    int vtop = -1, otop = -1;
    int i = 0, err = 0;

    while (expr[i]) {
        if (isspace(expr[i])) { i++; continue; }

        if (isdigit(expr[i])) {
            long long val = 0;
            while (isdigit(expr[i])) {
                val = val * 10 + (expr[i] - '0');
                i++;
            }
            values[++vtop] = val;
            continue;
        }

        if (expr[i] == '(') {
            ops[++otop] = expr[i];
        }
        else if (expr[i] == ')') {
            while (otop >= 0 && ops[otop] != '(') {
                if (vtop < 1) { strcpy(res, "Invalid expression"); return 0; }
                long long b = values[vtop--];
                long long a = values[vtop--];
                long long r = applyOp(a, b, ops[otop--], &err);
                if (err) { strcpy(res, "Math error"); return 0; }
                values[++vtop] = r;
            }
            if (otop < 0) { strcpy(res, "Invalid expression"); return 0; }
            otop--;
        }
        else if (strchr("+-*/", expr[i])) {
            while (otop >= 0 && precedence(ops[otop]) >= precedence(expr[i])) {
                if (vtop < 1) { strcpy(res, "Invalid expression"); return 0; }
                long long b = values[vtop--];
                long long a = values[vtop--];
                long long r = applyOp(a, b, ops[otop--], &err);
                if (err) { strcpy(res, "Math error"); return 0; }
                values[++vtop] = r;
            }
            ops[++otop] = expr[i];
        }
        else {
            strcpy(res, "Invalid character");
            return 0;
        }
        i++;
    }

    while (otop >= 0) {
        if (vtop < 1) { strcpy(res, "Invalid expression"); return 0; }
        long long b = values[vtop--];
        long long a = values[vtop--];
        long long r = applyOp(a, b, ops[otop--], &err);
        if (err) { strcpy(res, "Math error"); return 0; }
        values[++vtop] = r;
    }

    if (vtop != 0) {
        strcpy(res, "Invalid expression");
        return 0;
    }

    snprintf(res, MAX, "%lld", values[vtop]);
    return 1;
}

/* -------- MAIN -------- */
int main() {
    char buff[MAX], response[MAX];

    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);

    if (!inet_aton(serv_ip, &serv_addr.sin_addr)) {
        printf("Invalid IP\n");
        exit(1);
    }

    printf("\nTCP CALCULATOR SERVER (FINAL)\n");

    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    if (listenfd < 0) { perror("socket"); exit(1); }

    if (bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0) {
        perror("bind"); exit(1);
    }

    if (listen(listenfd, 5) < 0) {
        perror("listen"); exit(1);
    }

    cli_len = sizeof(cli_addr);

    while (1) {
        printf("\nWaiting for client...\n");

        connfd = accept(listenfd, (struct sockaddr*)&cli_addr, &cli_len);
        if (connfd < 0) { perror("accept"); continue; }

        printf("Connected: %s\n", inet_ntoa(cli_addr.sin_addr));

        while (1) {
            r = read(connfd, buff, MAX - 1);
            if (r <= 0) break;

            buff[r] = '\0';
            printf("CLIENT: %s\n", buff);

            if (strncmp(buff, "exit", 4) == 0) break;

            if (buff[0] == '1') {
                long long num;
                if (sscanf(buff, "1 %lld", &num) != 1)
                    strcpy(response, "Invalid input");
                else
                    decToBinary(num, response);
            }
            else if (buff[0] == '2') {
                char bin[100];
                if (sscanf(buff, "2 %99s", bin) != 1)
                    strcpy(response, "Invalid input");
                else {
                    long long val = binToDecimal(bin);
                    if (val == -1)
                        strcpy(response, "Invalid binary");
                    else
                        snprintf(response, MAX, "%lld", val);
                }
            }
            else if (buff[0] == '3') {
                char expr[100];
                if (sscanf(buff, "3 %[^\n]", expr) != 1)
                    strcpy(response, "Invalid input");
                else
                    evaluate(expr, response);
            }
            else {
                strcpy(response, "Invalid choice");
            }

            printf("RESULT: %s\n", response);

            w = write(connfd, response, strlen(response));
            if (w < 0) break;
        }

        close(connfd);
    }

    close(listenfd);
    return 0;
}




/* FINAL TCP CALCULATOR CLIENT */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define MAX 128

struct sockaddr_in serv_addr;
int skfd, r, w;
unsigned short serv_port = 25025;
char serv_ip[] = "127.0.0.1";

int main() {
    char buff[MAX];
    int choice;

    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);

    if (!inet_aton(serv_ip, &serv_addr.sin_addr)) {
        printf("Invalid IP\n");
        exit(1);
    }

    printf("\nTCP CALCULATOR CLIENT (FINAL)\n");

    skfd = socket(AF_INET, SOCK_STREAM, 0);
    if (skfd < 0) { perror("socket"); exit(1); }

    if (connect(skfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0) {
        perror("connect");
        close(skfd);
        exit(1);
    }

    printf("Connected to server\n");

    while (1) {
        printf("\n===== MENU =====\n");
        printf("1. Decimal to Binary\n");
        printf("2. Binary to Decimal\n");
        printf("3. Solve Expression\n");
        printf("4. Exit\n");

        printf("Enter choice: ");
        if (scanf("%d", &choice) != 1) {
            printf("Invalid input\n");
            while (getchar() != '\n');
            continue;
        }

        getchar();

        if (choice == 4) {
            strcpy(buff, "exit");
            write(skfd, buff, strlen(buff));
            printf("Exiting...\n");
            break;
        }

        if (choice == 1) {
            long long num;
            printf("Enter decimal: ");
            scanf("%lld", &num);
            getchar();
            snprintf(buff, MAX, "1 %lld", num);
        }
        else if (choice == 2) {
            char bin[100];
            printf("Enter binary: ");
            scanf("%99s", bin);
            getchar();
            snprintf(buff, MAX, "2 %s", bin);
        }
        else if (choice == 3) {
            printf("Enter expression: ");
            fgets(buff, MAX, stdin);
            buff[strcspn(buff, "\n")] = 0;

            char temp[MAX];
            snprintf(temp, MAX, "3 %s", buff);
            strcpy(buff, temp);
        }
        else {
            printf("Invalid choice\n");
            continue;
        }

        w = write(skfd, buff, strlen(buff));
        if (w < 0) break;

        r = read(skfd, buff, MAX - 1);
        if (r <= 0) {
            printf("Server disconnected\n");
            break;
        }

        buff[r] = '\0';
        printf("RESULT: %s\n", buff);
    }

    close(skfd);
    return 0;
}
