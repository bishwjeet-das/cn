/* TCP Time + Greeting Server */

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

int listenfd, connfd, r, cli_addr_len;

unsigned short serv_port = 25020;
char serv_ip[] = "127.0.0.1";

char buff[128];

void getTimeGreeting(char *result)
{
    time_t t;
    struct tm *tm_info;

    time(&t);
    tm_info = localtime(&t);

    int hour = tm_info->tm_hour;

    char *greet;

    if(hour >= 5 && hour < 12)
        greet = "Good Morning";
    else if(hour >= 12 && hour < 17)
        greet = "Good Afternoon";
    else if(hour >= 17 && hour < 21)
        greet = "Good Evening";
    else
        greet = "Good Night";

    sprintf(result, "%s - %s", greet, asctime(tm_info));
}

int main()
{
    bzero(&serv_addr, sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);
    inet_aton(serv_ip, (&serv_addr.sin_addr));

    printf("\nTCP TIME + GREETING SERVER.\n");

    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    listen(listenfd, 5);

    cli_addr_len = sizeof(cli_addr);

    while(1)
    {
        printf("\nSERVER: Waiting for client...\n");

        connfd = accept(listenfd, (struct sockaddr*)&cli_addr, &cli_addr_len);

        printf("\nConnected to %s\n", inet_ntoa(cli_addr.sin_addr));

        while(1)
        {
            // SERVER INPUT
            printf("\nSERVER: ");
            fgets(buff, 128, stdin);
            buff[strcspn(buff, "\n")] = 0;

            if(strcmp(buff, "time") == 0)
            {
                getTimeGreeting(buff);
                printf("%s", buff);
                write(connfd, buff, strlen(buff));
                continue;
            }

            if(strcmp(buff, "exit") == 0)
            {
                write(connfd, "exit", 4);
                close(connfd);
                close(listenfd);
                exit(0);
            }

            // RECEIVE FROM CLIENT
            r = read(connfd, buff, 128);

            if(r <= 0)
            {
                printf("\nClient disconnected.\n");
                break;
            }

            buff[r] = '\0';
            printf("\nCLIENT: %s\n", buff);

            if(strcmp(buff, "time") == 0)
            {
                getTimeGreeting(buff);
                printf("%s", buff);
                write(connfd, buff, strlen(buff));
            }

            if(strcmp(buff, "exit") == 0)
            {
                printf("\nClient exited.\n");
                break;
            }
        }

        close(connfd);
    }
}