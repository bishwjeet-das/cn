/* TCP Time Client (Both Side Display) */

#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<string.h>
#include<stdlib.h>
#include<stdio.h>
#include<unistd.h>

struct sockaddr_in serv_addr;

int skfd, r;

unsigned short serv_port = 25020;
char serv_ip[] = "127.0.0.1";

char rbuff[128], sbuff[128];

int main()
{
    bzero(&serv_addr, sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(serv_port);
    inet_aton(serv_ip, (&serv_addr.sin_addr));

    printf("\nTCP TIME CLIENT.\n");

    skfd = socket(AF_INET, SOCK_STREAM, 0);
    connect(skfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

    while(1)
    {
        printf("\nCLIENT: ");
        fgets(sbuff, 128, stdin);
        sbuff[strcspn(sbuff, "\n")] = 0;

        write(skfd, sbuff, strlen(sbuff));

        if(strcmp(sbuff, "exit") == 0)
        {
            printf("CLIENT EXIT\n");
            break;
        }

        r = read(skfd, rbuff, 128);

        if(r <= 0)
        {
            printf("Server disconnected\n");
            break;
        }

        rbuff[r] = '\0';
        printf("SERVER: %s\n", rbuff);

        if(strcmp(rbuff, "exit") == 0)
        {
            printf("Server exited\n");
            break;
        }
    }

    close(skfd);
}