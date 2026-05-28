#include <stdio.h>
#include <string.h>

#define MAX 100
#define NAME_LEN 50


struct Soldier
{
    char name[NAME_LEN];
};


void eliminateSoldiers(struct Soldier soldiers[], int total, int n)
{
    int index = 0;
    int count = total;

    printf("\nElimination Order:\n");

    
    while(count > 1)
    {
       
        index = (index + n - 1) % count;

        printf("%s is eliminated\n", soldiers[index].name);

      
        for(int i = index; i < count - 1; i++)
        {
            soldiers[i] = soldiers[i + 1];
        }

        count--;
    }

   
    printf("\nSoldier who escapes: %s\n", soldiers[0].name);
}

int main()
{
    struct Soldier soldiers[MAX];

    int n;
    int total = 0;

    printf("Enter the number n: ");
    scanf("%d", &n);

    printf("Enter soldier names one by one (type end to stop):\n");

   
    while(1)
    {
        scanf("%s", soldiers[total].name);

        if(strcmp(soldiers[total].name, "end") == 0)
        {
            break;
        }

        total++;
    }

  
    if(total == 0)
    {
        printf("No soldiers entered.\n");
        return 0;
    }

    eliminateSoldiers(soldiers, total, n);

    return 0;
}
