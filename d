#include <stdio.h>

int puzzle[4][4];


void displayTable()
{
    int i, j;

    printf("\n");

    for(i = 0; i < 4; i++)
    {
        for(j = 0; j < 4; j++)
        {
            if(puzzle[i][j] == 0)
                printf("   ");
            else
                printf("%2d ", puzzle[i][j]);
        }

        printf("\n");
    }
}


void moveLeft()
{
    int i, j, temp;

    for(i = 0; i < 4; i++)
    {
        for(j = 1; j < 4; j++)
        {
            if(puzzle[i][j] == 0)
            {
                temp = puzzle[i][j];
                puzzle[i][j] = puzzle[i][j - 1];
                puzzle[i][j - 1] = temp;

                printf("\nMove Left:");
                displayTable();

                return;
            }
        }
    }
}


void moveRight()
{
    int i, j, temp;

    for(i = 0; i < 4; i++)
    {
        for(j = 0; j < 3; j++)
        {
            if(puzzle[i][j] == 0)
            {
                temp = puzzle[i][j];
                puzzle[i][j] = puzzle[i][j + 1];
                puzzle[i][j + 1] = temp;

                printf("\nMove Right:");
                displayTable();

                return;
            }
        }
    }
}


void moveUp()
{
    int i, j, temp;

    for(i = 1; i < 4; i++)
    {
        for(j = 0; j < 4; j++)
        {
            if(puzzle[i][j] == 0)
            {
                temp = puzzle[i][j];
                puzzle[i][j] = puzzle[i - 1][j];
                puzzle[i - 1][j] = temp;

                printf("\nMove Up:");
                displayTable();

                return;
            }
        }
    }
}


void moveDown()
{
    int i, j, temp;

    for(i = 0; i < 3; i++)
    {
        for(j = 0; j < 4; j++)
        {
            if(puzzle[i][j] == 0)
            {
                temp = puzzle[i][j];
                puzzle[i][j] = puzzle[i + 1][j];
                puzzle[i + 1][j] = temp;

                printf("\nMove Down:");
                displayTable();

                return;
            }
        }
    }
}

int main()
{
    int i, j;
    int choice;

    printf("Enter 15 Puzzle Elements (Use 0 for blank):\n");

    for(i = 0; i < 4; i++)
    {
        for(j = 0; j < 4; j++)
        {
            scanf("%d", &puzzle[i][j]);
        }
    }

    printf("\nInitial Puzzle State:");
    displayTable();

    while(1)
    {
        printf("\n");
        printf("\n1. Move Left");
        printf("\n2. Move Right");
        printf("\n3. Move Up");
        printf("\n4. Move Down");
        printf("\n5. Exit");

        printf("\n\nEnter Choice: ");
        scanf("%d", &choice);

        switch(choice)
        {
            case 1:
                moveLeft();
                break;

            case 2:
                moveRight();
                break;

            case 3:
                moveUp();
                break;

            case 4:
                moveDown();
                break;

            case 5:
                printf("\nProgram Ended.\n");
                return 0;

            default:
                printf("\nInvalid Choice!");
        }
    }

    return 0;
}
