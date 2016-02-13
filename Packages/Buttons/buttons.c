// Button Switch buttons.c
// Makes use of WIRINGPI Library
// USES Raspberry Pi GPIO
// 1 2 or 3 button press or hold
//
// C. Yarnold 1 Feb 2016
//
// Compile with gcc buttons.c -obuttons -lwiringPi
//
// Make sure you have the most upto date WiringPi installed on the Pi to be used.

#include <stdio.h>
#include <wiringPi.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define PressTimeout 1000            // Timeout for reading button presses (1sec)
#define Big_Delay 200                // Delay to remove bounce etc (2ms)
#define Small_Delay 100              // Delay to perform short waits (1ms)
#define FILENAME "/etc/buttons.conf" //Check Config File
#define MAXBUF 1024 
#define DELIM "="

static volatile int State = 0;

struct cfg
{
    int Dbg;                         // 1 debug messages, 0 none
    int GPIO_No;                     // Define the Raspberry Pi IO Pin being used
    char Cmd1[MAXBUF];               // Command to run with 1 press
    char Cmd2[MAXBUF];               // Command to run with 2 presses
    char Cmd3[MAXBUF];               // Command to run with 3 presses
    char CmdHold[MAXBUF];            // What happens when button is held down
};

int read_int_from_config_line(char* config_line) {    
    char prm_name[MAXBUF];
    int val;
    sscanf(config_line, "%s %d\n", prm_name, &val);
    return val;
}
void read_double_from_config_line(char* config_line, double* val) {    
    char prm_name[MAXBUF];
    sscanf(config_line, "%s %lf\n", prm_name, val);
}

void read_str_from_config_line(char* config_line, char* val, int len) {    
    int	i, j, n;

    n = strlen (config_line);	/* how long is src		*/
    i = len;		/* starting point in src	*/
    j = 0;			/* starting point in dest	*/
    for ( ; i < n && config_line [i] != '\0'; i++) {
        val [j] = config_line [i];
        j++;
    }
    val [j] = '\0';
}

struct cfg get_config(char *filename) 
{
    struct cfg cfgstruct;
    FILE *file = fopen (filename, "r");

    if (file != NULL)
    { 
        char line[MAXBUF];
        int i = 0;

        while(fgets(line, MAXBUF, file) != NULL)
        {
            if (line[0] == '#' || strlen(line) < 4){
                continue;
            }
            if (strstr(line, "Debug_Level ")){
                cfgstruct.Dbg = read_int_from_config_line(line);
            }
            if (strstr(line, "GPIO_HW_No ")){
                cfgstruct.GPIO_No = read_int_from_config_line(line);
            }
            if (strstr(line, "Command_1 ")){
                read_str_from_config_line(line, cfgstruct.Cmd1, strlen("Command_1 "));
            }
            if (strstr(line, "Command_2 ")){
                read_str_from_config_line(line, cfgstruct.Cmd2, strlen("Command_2 "));
            }
            if (strstr(line, "Command_3 ")){
                read_str_from_config_line(line, cfgstruct.Cmd3, strlen("Command_3 "));
            }
            if (strstr(line, "Command_Hold ")){
                read_str_from_config_line(line, cfgstruct.CmdHold, strlen("Command_Hold "));
            }
                      
            i++;
        } // End while

        fclose(file);

    } // End if file
        
    return cfgstruct;
}

int Setup_IO(int,int);              // Initial Setup of the GPIO Pin
void switchInterrupt(void);         // switchInterrupt:  called every time an event occurs
int pressed(int,char *,char *,char *,char *,int);                  // Each time a press cycle is started

int main(int argc, char * argv[])
{
    printf("Pi Button Press Control v1.0 1 Feb 2016\n\n");
   
    int flag = 0;

    struct cfg cfgstruct;
        
    cfgstruct = get_config(FILENAME);
    int Dbg_Lvl = (int)cfgstruct.Dbg;
    int GPIO_Num = (int)cfgstruct.GPIO_No;
    char *Command1 = cfgstruct.Cmd1;
    char *Command2 = cfgstruct.Cmd2;
    char *Command3 = cfgstruct.Cmd3;
    char *CommandHold = cfgstruct.CmdHold;
 
    if(Setup_IO(GPIO_Num, Dbg_Lvl) < 0){
        printf ("Unable to setup GPIO: %s\n", strerror (errno));
        return 1;
    }

    // main loop, exit only when button held down
    while (flag < 3)
    {
        flag = 0;            // reset flag
        State = 0;           // reset the interrupt status

        // waiting for interrupt from button press
        if (Dbg_Lvl) printf("Waiting for initial button press\n");
        
        while (State == 0)
            delay (Small_Delay);

        flag = pressed(GPIO_Num, Command1, Command2, Command3, CommandHold, Dbg_Lvl);
    }

    if (Dbg_Lvl) printf("Exiting Program\n");
}



int Setup_IO(int Button_Pin, int Dbg){

    if (Dbg) printf("GPIO Initialisation\n");

    // setup GPIO
    if (wiringPiSetup() == -1){
        printf ("Unable to setup wiringPi: %s\n", strerror (errno));
        return -1;
    }

    if (Dbg) printf("GPIO Initialised, Setting Pullup. Pin is %i\n", Button_Pin);

    // setup GPIO as input with pull-up
    // pull up is needed as button common is grounded
    pinMode (Button_Pin, INPUT);
    pullUpDnControl (Button_Pin, PUD_UP);
    
    if (Dbg) printf("Setting GPIO Interrupt\n");

    if(wiringPiISR (Button_Pin, INT_EDGE_FALLING, &switchInterrupt) < 0){
        printf ("Unable to setup interrupt: %s\n", strerror (errno));
        return -2;
    }
}

void switchInterrupt(void){
    State=1;
}

int pressed(int Button_Pin, char *cmd1, char *cmd2, char *cmd3, char *cmdhold, int Dbg){

    int flag = 1;
    int pressMSec = 0;
    int presses = 0;
    int holdMSec = 0;
    char *command = "";

    // delay for debouncing
    delay(Big_Delay);

    State = 0;        // reset state to look for more presses

    if (Dbg) printf("Button Pressed\n");
        
    // Button flag, start checking for held or subsequent presses within timeout period
    while (pressMSec <= PressTimeout && presses < 3)
    {
        holdMSec = 0;     // reset and wait for button release

        while (digitalRead(Button_Pin) == LOW && flag < 3)
        {
            if (Dbg) printf("Checking Button Held\n");

            // delay for debouncing
            delay(Big_Delay);
            holdMSec += Big_Delay;

            // held down longer than press timeout?
            if (holdMSec > PressTimeout){
                // set presses and flag so that we exit straight away
                presses = 4;
                flag = 3;
            }
            holdMSec += Big_Delay;
        }
 
        if (Dbg) printf("Button Released\n");
 
        // button was released, but only record 1 press while waiting
        if (flag == 1){
            flag = 2;
            presses++;
            if (Dbg) printf("Presses = %i\n", presses);
        }
		 
        // increase flag loop time, add time while button was held down
        // add additional for when button wasn't held down
        pressMSec = pressMSec + holdMSec + Big_Delay;

        delay(Small_Delay);     // Give it a small wait and check for another press

        if (State == 1){        // button must have been flag again
            flag = 1;

            // delay for debouncing
            delay(Big_Delay);

            State = 0;        // reset state to look for more presses
        }
    }

    // button timeout expired, process command

    switch(presses) {
    case 1 :
        command = cmd1;
        break;
    case 2 :
        command = cmd2;
        break;
    case 3 :
        command = cmd3;
        break;
    case 4 :
        command = cmdhold;
        break;
    default :
        presses = 5;
        break;
    }

    if (Dbg) printf("Command = %s\n", command);

    if (presses <= 4 )
        system(command);     // run whichever command was selected

    return(flag);
}
