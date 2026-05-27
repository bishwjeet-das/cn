echo
/* UDP One-Time Message Server */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define PORT 25020

int main(){
int sockfd, r;
struct sockaddr_in serv_addr, cli_addr;
socklen_t len = sizeof(cli_addr);

char buff[128];

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
serv_addr.sin_addr.s_addr = INADDR_ANY;

bind(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

printf("\nUDP SERVER \n");

/* receive only once */
r = recvfrom(sockfd, buff, sizeof(buff), 0,
             (struct sockaddr*)&cli_addr, &len);

buff[r] = '\0';

printf("\nSERVER: Received '%s' from %s\n",
       buff, inet_ntoa(cli_addr.sin_addr));

printf("\nSERVER: Exiting...\n");

close(sockfd);
return 0;
}

/* UDP Client - Send Once */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define PORT 25020

int main(){
int sockfd, w;
struct sockaddr_in serv_addr;
socklen_t len = sizeof(serv_addr);

char sbuff[128] = "===good morning===";

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
inet_aton("127.0.0.1", &serv_addr.sin_addr);

printf("\nUDP CLIENT\n");

/* send once */
w = sendto(sockfd, sbuff, strlen(sbuff), 0,
           (struct sockaddr*)&serv_addr, len);

printf("\nCLIENT: Message sent: %s\n", sbuff);
printf("CLIENT: Exiting...\n");

close(sockfd);
return 0;
}

2.chat

/* UDP Continuous Chat Server */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>

#define PORT 25070

char buff[256];

int main(){
int sockfd, r;
struct sockaddr_in serv_addr, cli_addr;
socklen_t len = sizeof(cli_addr);

fd_set readfds;

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
serv_addr.sin_addr.s_addr = INADDR_ANY;

bind(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

printf("\nUDP CHAT SERVER\n");

while(1){
    FD_ZERO(&readfds);
    FD_SET(sockfd, &readfds); // client messages
    FD_SET(0, &readfds);      // server keyboard

    select(sockfd + 1, &readfds, NULL, NULL, NULL);

    /* 🔴 SERVER TYPING */
    if(FD_ISSET(0, &readfds)){
        fgets(buff, sizeof(buff), stdin);

        if(strncmp(buff, "exit", 4) == 0){
            printf("SERVER: Sending shutdown signal...\n");

            char msg[] = "SERVER_EXIT";

            sendto(sockfd, msg, strlen(msg), 0,
                   (struct sockaddr*)&cli_addr, len);
            continue;
        }

        sendto(sockfd, buff, strlen(buff), 0,
               (struct sockaddr*)&cli_addr, len);
    }

    /* 🔵 CLIENT MESSAGE */
    if(FD_ISSET(sockfd, &readfds)){
        r = recvfrom(sockfd, buff, sizeof(buff), 0,
                     (struct sockaddr*)&cli_addr, &len);

        buff[r] = '\0';

        if(strncmp(buff, "exit", 4) == 0){
            printf("\nClient exited.\n");
            continue;
        }

        printf("\nCLIENT: %s", buff);
    }
}

close(sockfd);
return 0;
}

/* UDP Continuous Chat Client */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>

#define PORT 25070

char buff[256];

int main(){
int sockfd, r;
struct sockaddr_in serv_addr;
socklen_t len = sizeof(serv_addr);

fd_set readfds;

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
inet_aton("127.0.0.1", &serv_addr.sin_addr);

printf("\nUDP CHAT CLIENT\n");

while(1){
    FD_ZERO(&readfds);
    FD_SET(sockfd, &readfds); // server messages
    FD_SET(0, &readfds);      // client typing

    select(sockfd + 1, &readfds, NULL, NULL, NULL);

    /* 🔴 CLIENT TYPING */
    if(FD_ISSET(0, &readfds)){
        fgets(buff, sizeof(buff), stdin);

        sendto(sockfd, buff, strlen(buff), 0,
               (struct sockaddr*)&serv_addr, len);

        if(strncmp(buff, "exit", 4) == 0){
            printf("Client exiting.\n");
            break;
        }
    }

    /* 🔵 SERVER MESSAGE */
    if(FD_ISSET(sockfd, &readfds)){
        r = recvfrom(sockfd, buff, sizeof(buff), 0,
                     (struct sockaddr*)&serv_addr, &len);

        buff[r] = '\0';

        if(strncmp(buff, "SERVER_EXIT", 11) == 0){
            printf("\nServer requested shutdown. Exiting...\n");
            break;
        }

        printf("\nSERVER: %s", buff);
    }
}

close(sockfd);
return 0;
}

3.time

/* UDP Time Server */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/select.h>

#define PORT 25060

char buff[128];

int main(){
int sockfd, r;
struct sockaddr_in serv_addr, cli_addr;
socklen_t len = sizeof(cli_addr);

char response[128];
fd_set readfds;

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
serv_addr.sin_addr.s_addr = INADDR_ANY;

bind(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

printf("\nUDP TIME SERVER\n");

while(1){
    FD_ZERO(&readfds);
    FD_SET(sockfd, &readfds); // client
    FD_SET(0, &readfds);      // keyboard

    select(sockfd + 1, &readfds, NULL, NULL, NULL);

    /* 🔴 SERVER INPUT */
    if(FD_ISSET(0, &readfds)){
        fgets(buff, sizeof(buff), stdin);

        if(strncmp(buff, "exit", 4) == 0){
            printf("SERVER: Sending shutdown signal...\n");

            char msg[] = "SERVER_EXIT";

            sendto(sockfd, msg, strlen(msg), 0,
                   (struct sockaddr*)&cli_addr, len);
        }
    }

    /* 🔵 CLIENT REQUEST */
    if(FD_ISSET(sockfd, &readfds)){
        r = recvfrom(sockfd, buff, sizeof(buff), 0,
                     (struct sockaddr*)&cli_addr, &len);

        buff[r] = '\0';
        printf("CLIENT: %s", buff);

        if(strncmp(buff, "exit", 4) == 0){
            printf("Client exited.\n");
            continue;
        }

        /* 🕒 GET CURRENT TIME */
        time_t now = time(NULL);
        struct tm *t = localtime(&now);

        strftime(response, sizeof(response),
                 "%Y-%m-%d %H:%M:%S", t);

        printf("SERVER TIME: %s\n", response);

        sendto(sockfd, response, strlen(response), 0,
               (struct sockaddr*)&cli_addr, len);
    }
}

close(sockfd);
return 0;
}

/* UDP Time Client */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define PORT 25060

char buff[128];

int main(){
int sockfd, r;
struct sockaddr_in serv_addr;
socklen_t len = sizeof(serv_addr);

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
inet_aton("127.0.0.1", &serv_addr.sin_addr);

printf("\nUDP TIME CLIENT\n");

while(1){
    printf("\nEnter 'time' to get time or 'exit': ");
    fgets(buff, sizeof(buff), stdin);

    sendto(sockfd, buff, strlen(buff), 0,
           (struct sockaddr*)&serv_addr, len);

    if(strncmp(buff, "exit", 4) == 0){
        printf("Client exiting.\n");
        break;
    }

    r = recvfrom(sockfd, buff, sizeof(buff), 0,
                 (struct sockaddr*)&serv_addr, &len);

    buff[r] = '\0';

    /* 🔴 SERVER EXIT */
    if(strncmp(buff, "SERVER_EXIT", 11) == 0){
        printf("Server requested shutdown. Exiting...\n");
        break;
    }

    printf("CURRENT TIME: %s\n", buff);
}

close(sockfd);
return 0;
}

4.simple calculator

/* UDP Simple Calculator Server */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>

#define PORT 25050

char buff[128];

int main(){
int sockfd, r;
struct sockaddr_in serv_addr, cli_addr;
socklen_t len = sizeof(cli_addr);

char response[128];
fd_set readfds;

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
serv_addr.sin_addr.s_addr = INADDR_ANY;

bind(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

printf("\nUDP SIMPLE CALCULATOR SERVER\n");

while(1){
    FD_ZERO(&readfds);
    FD_SET(sockfd, &readfds);
    FD_SET(0, &readfds);

    select(sockfd + 1, &readfds, NULL, NULL, NULL);

    /* 🔴 SERVER INPUT */
    if(FD_ISSET(0, &readfds)){
        fgets(buff, sizeof(buff), stdin);

        if(strncmp(buff, "exit", 4) == 0){
            printf("SERVER: Sending shutdown signal...\n");

            char msg[] = "SERVER_EXIT";

            sendto(sockfd, msg, strlen(msg), 0,
                   (struct sockaddr*)&cli_addr, len);
        }
    }

    /* 🔵 CLIENT REQUEST */
    if(FD_ISSET(sockfd, &readfds)){
        r = recvfrom(sockfd, buff, sizeof(buff), 0,
                     (struct sockaddr*)&cli_addr, &len);

        buff[r] = '\0';
        printf("CLIENT: %s", buff);

        if(strncmp(buff, "exit", 4) == 0){
            printf("Client exited.\n");
            continue;
        }

        int a, b;
        char op;

        if(sscanf(buff, "%d %c %d", &a, &op, &b) != 3){
            strcpy(response, "Invalid format");
        }
        else{
            switch(op){
                case '+': sprintf(response, "%d", a + b); break;
                case '-': sprintf(response, "%d", a - b); break;
                case '*': sprintf(response, "%d", a * b); break;

                case '/':
                    if(b == 0) strcpy(response, "Divide by zero error");
                    else sprintf(response, "%d", a / b);
                    break;

                case '%':
                    if(b == 0) strcpy(response, "Modulo by zero error");
                    else sprintf(response, "%d", a % b);
                    break;

                default:
                    strcpy(response, "Invalid operator");
            }
        }

        printf("SERVER RESULT: %s\n", response);

        sendto(sockfd, response, strlen(response), 0,
               (struct sockaddr*)&cli_addr, len);
    }
}

close(sockfd);
return 0;
}

/* UDP Simple Calculator Client */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define PORT 25050

char buff[128];

int main(){
int sockfd, r;
struct sockaddr_in serv_addr;
socklen_t len = sizeof(serv_addr);

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
inet_aton("127.0.0.1", &serv_addr.sin_addr);

printf("\nUDP SIMPLE CALCULATOR CLIENT\n");

while(1){
    printf("\nEnter expression (e.g., 5 + 3) or exit: ");
    fgets(buff, sizeof(buff), stdin);

    sendto(sockfd, buff, strlen(buff), 0,
           (struct sockaddr*)&serv_addr, len);

    if(strncmp(buff, "exit", 4) == 0){
        printf("Client exiting.\n");
        break;
    }

    r = recvfrom(sockfd, buff, sizeof(buff), 0,
                 (struct sockaddr*)&serv_addr, &len);

    buff[r] = '\0';

    /* 🔴 SERVER EXIT */
    if(strncmp(buff, "SERVER_EXIT", 11) == 0){
        printf("Server requested shutdown. Exiting...\n");
        break;
    }

    printf("RESULT: %s\n", buff);
}

close(sockfd);
return 0;
}

5.equation and conversion

/* UDP Calculator Server with Server Exit Feature */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>

#define PORT 25028

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
int sockfd, r;
struct sockaddr_in serv_addr, cli_addr;
socklen_t cli_len = sizeof(cli_addr);

char response[128];
fd_set readfds;

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
serv_addr.sin_addr.s_addr = INADDR_ANY;

bind(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

printf("\nUDP CALCULATOR SERVER\n");

while(1){
    FD_ZERO(&readfds);
    FD_SET(sockfd, &readfds);  // client
    FD_SET(0, &readfds);       // keyboard

    select(sockfd + 1, &readfds, NULL, NULL, NULL);

    /* SERVER KEYBOARD INPUT */
    if(FD_ISSET(0, &readfds)){
        fgets(buff, sizeof(buff), stdin);

        if(strncmp(buff, "exit", 4) == 0){
            printf("SERVER: Sending shutdown signal...\n");

            char msg[] = "SERVER_EXIT";

            sendto(sockfd, msg, strlen(msg), 0,
                   (struct sockaddr*)&cli_addr, cli_len);

            continue;
        }
    }

    /* CLIENT MESSAGE */
    if(FD_ISSET(sockfd, &readfds)){
        r = recvfrom(sockfd, buff, sizeof(buff), 0,
                     (struct sockaddr*)&cli_addr, &cli_len);

        buff[r] = '\0';
        printf("CLIENT: %s", buff);

        if(strncmp(buff, "exit", 4) == 0){
            printf("Client exited.\n");
            continue;
        }

        /* CHOICE 1 */
        if(buff[0] == '1'){
            int num;
            if(sscanf(buff, "1 %d", &num) != 1)
                strcpy(response, "Invalid format");
            else
                decToBinary(num, response);
        }

        /* CHOICE 2 */
        else if(buff[0] == '2'){
            char bin[100]; int val;
            if(sscanf(buff, "2 %s", bin) != 1)
                strcpy(response, "Invalid format");
            else{
                val = binToDecimal(bin);
                if(val == -1)
                    strcpy(response, "Invalid binary number");
                else
                    sprintf(response, "%d", val);
            }
        }

        /* CHOICE 3 */
        else if(buff[0] == '3'){
            char expr[100], command[200];
            FILE *fp;

            if(sscanf(buff, "3 %[^\n]", expr) != 1)
                strcpy(response, "Invalid format");
            else{
                sprintf(command, "echo \"%s\" | bc", expr);

                fp = popen(command, "r");

                if(fp == NULL)
                    strcpy(response, "Error executing bc");
                else{
                    if(fgets(response, sizeof(response), fp) == NULL)
                        strcpy(response, "Invalid expression");
                    else
                        response[strcspn(response, "\n")] = '\0';

                    pclose(fp);
                }
            }
        }

        else
            strcpy(response, "Invalid choice");

        printf("SERVER RESULT: %s\n", response);

        sendto(sockfd, response, strlen(response), 0,
               (struct sockaddr*)&cli_addr, cli_len);
    }
}

close(sockfd);
return 0;
}

/* UDP Calculator Client */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define PORT 25028

char buff[128];

int main(){
int sockfd, r;
struct sockaddr_in serv_addr;
socklen_t len = sizeof(serv_addr);
int choice;

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
inet_aton("127.0.0.1", &serv_addr.sin_addr);

printf("\nUDP CALCULATOR CLIENT\n");

while(1){
    printf("\n===== MENU =====\n1. Decimal to Binary\n2. Binary to Decimal\n3. Solve Expression\n4. Exit\n");
    printf("Enter choice: ");
    scanf("%d", &choice);
    getchar();

    if(choice == 4){
        strcpy(buff, "exit");
        sendto(sockfd, buff, strlen(buff), 0,
               (struct sockaddr*)&serv_addr, len);
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

    sendto(sockfd, buff, strlen(buff), 0,
           (struct sockaddr*)&serv_addr, len);

    r = recvfrom(sockfd, buff, sizeof(buff), 0,
                 (struct sockaddr*)&serv_addr, &len);

    buff[r] = '\0';

    /* SERVER EXIT HANDLING */
    if(strncmp(buff, "SERVER_EXIT", 11) == 0){
        printf("Server requested shutdown. Exiting...\n");
        break;
    }

    printf("RESULT: %s\n", buff);
}

close(sockfd);
return 0;
}

6.file

/* UDP Command Execution Server (WITH SERVER EXIT FEATURE) */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>

#define PORT 25036
#define BUF_SIZE 256

int main(){
int sockfd, r;
struct sockaddr_in serv_addr, cli_addr;
socklen_t cli_len = sizeof(cli_addr);

char buff[BUF_SIZE];
char response[2048];
fd_set readfds;

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
serv_addr.sin_addr.s_addr = INADDR_ANY;

bind(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

printf("\nUDP COMMAND SERVER\n");

while(1){
    FD_ZERO(&readfds);
    FD_SET(sockfd, &readfds); // client
    FD_SET(0, &readfds);      // keyboard

    select(sockfd + 1, &readfds, NULL, NULL, NULL);

    /* 🔴 SERVER KEYBOARD INPUT */
    if(FD_ISSET(0, &readfds)){
        fgets(buff, sizeof(buff), stdin);

        if(strncmp(buff, "exit", 4) == 0){
            printf("SERVER: Sending shutdown signal...\n");

            char msg[] = "SERVER_EXIT";

            sendto(sockfd, msg, strlen(msg), 0,
                   (struct sockaddr*)&cli_addr, cli_len);

            continue;
        }
    }

    /* 🔵 CLIENT MESSAGE */
    if(FD_ISSET(sockfd, &readfds)){
        r = recvfrom(sockfd, buff, sizeof(buff), 0,
                     (struct sockaddr*)&cli_addr, &cli_len);

        buff[r] = '\0';
        printf("CLIENT CMD: %s", buff);

        if(strncmp(buff, "exit", 4) == 0){
            printf("Client exited.\n");
            continue;
        }

        /* HANDLE cd */
        if(strncmp(buff, "cd", 2) == 0){
            char path[128];
            if(sscanf(buff, "cd %s", path) != 1)
                strcpy(response, "Invalid format");
            else{
                if(chdir(path) == 0)
                    strcpy(response, "Directory changed");
                else
                    strcpy(response, "Failed to change directory");
            }

            sendto(sockfd, response, strlen(response), 0,
                   (struct sockaddr*)&cli_addr, cli_len);
            continue;
        }

        /* EXECUTE COMMAND */
        FILE *fp = popen(buff, "r");

        if(fp == NULL){
            strcpy(response, "Error executing command");
            sendto(sockfd, response, strlen(response), 0,
                   (struct sockaddr*)&cli_addr, cli_len);
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
            sendto(sockfd, response, strlen(response), 0,
                   (struct sockaddr*)&cli_addr, cli_len);
        }
        /* LARGE OUTPUT */
        else{
            FILE *file = fopen("output.txt", "w");

            fputs(response, file);
            while(fgets(temp, sizeof(temp), fp) != NULL)
                fputs(temp, file);
            fclose(file);

            FILE *f = fopen("output.txt", "r");
            fseek(f, 0, SEEK_END);
            long size = ftell(f);
            rewind(f);

            sprintf(response, "FILE %ld", size);
            sendto(sockfd, response, strlen(response), 0,
                   (struct sockaddr*)&cli_addr, cli_len);

            int n;
            while((n = fread(temp, 1, sizeof(temp), f)) > 0){
                sendto(sockfd, temp, n, 0,
                       (struct sockaddr*)&cli_addr, cli_len);
                usleep(1000);
            }

            fclose(f);

            printf("SERVER RESULT: Sent as file (%ld bytes)\n", size);
        }

        pclose(fp);
    }
}

close(sockfd);
return 0;
}

/* UDP Command Execution Client */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define PORT 25036
#define BUF_SIZE 256

int main(){
int sockfd, r;
struct sockaddr_in serv_addr;
socklen_t len = sizeof(serv_addr);

char buff[BUF_SIZE];

sockfd = socket(AF_INET, SOCK_DGRAM, 0);

serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(PORT);
inet_aton("127.0.0.1", &serv_addr.sin_addr);

printf("\nUDP COMMAND CLIENT\n");

while(1){
    printf("\nEnter command (or exit): ");
    fgets(buff, sizeof(buff), stdin);

    sendto(sockfd, buff, strlen(buff), 0,
           (struct sockaddr*)&serv_addr, len);

    if(strncmp(buff, "exit", 4) == 0){
        printf("Client exiting.\n");
        break;
    }

    r = recvfrom(sockfd, buff, sizeof(buff), 0,
                 (struct sockaddr*)&serv_addr, &len);

    buff[r] = '\0';

    /* FILE CASE */
    if(strncmp(buff, "FILE", 4) == 0){
        long filesize;
        sscanf(buff, "FILE %ld", &filesize);

        FILE *fp = fopen("received.txt", "w");

        printf("Receiving %ld bytes...\n", filesize);

        long received = 0;

        while(received < filesize){
            r = recvfrom(sockfd, buff, sizeof(buff), 0,
                         (struct sockaddr*)&serv_addr, &len);

            fwrite(buff, 1, r, fp);
            received += r;
        }

        fclose(fp);
        printf("Saved to received.txt\n");
    }
    else{
        printf("OUTPUT:\n%s\n", buff);
    }
    /* SERVER EXIT HANDLING */
    if(strncmp(buff, "SERVER_EXIT", 11) == 0){
        printf("Server requested shutdown. Exiting...\n");
        break;
    }
}

close(sockfd);
return 0;
}

