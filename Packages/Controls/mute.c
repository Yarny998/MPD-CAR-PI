// mute.c
// Makes use of WIRINGPI Library
// USES Raspberry Pi GPIO
// Listens for mute wire activation
// Runs a mute command until unmuted, then runs unmute command
//
// C. Yarnold 9 Apr 2016
//
// Compile with gcc mute.c -omute -lwiringPi
//
// Make sure you have the most upto date WiringPi installed on the Pi to be used.

#include <stdio.h>
#include <wiringPi.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define Delay 100                    // Delay to perform short waits (1ms)
#define FILENAME "/etc/mute.conf"    // Check Config File
#define MAXBUF 1024 
#define DELIM "="

static volatile int State = 0;

static int GPIO2ToWPI[32] =
{
    30, 31,                          // GPIO 0, 1
     8,  9,                          // GPIO 2, 3
     7, 21,                          // GPIO 4, 5
    22, 11,                          // GPIO 6, 7
    10, 13,                          // GPIO 8, 9
    12, 14,                          // GPIO 10, 11
    26, 23,                          // GPIO 12, 13
    15, 16,                          // GPIO 14, 15
    27,  0,                          // GPIO 16, 17
     1, 24,                          // GPIO 18, 19
    28, 29,                          // GPIO 20, 21
     3,  4,                          // GPIO 22, 23
     5,  6,                          // GPIO 24, 25
    25,  2,                          // GPIO 26, 27
    17, 18,                          // GPIO 28, 29
    19, 20                           // GPIO 30, 31
};

struct cfg
{
    int Dbg;                         // 1 debug messages, 0 none
    int GPIO_No;                     // Define the Raspberry Pi IO Pin being used
    char Cmd1[MAXBUF];               // Command to run with mute
    char Cmd2[MAXBUF];               // Command to run with unmute
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
    int i, j, n;

    n = strlen (config_line);   /* how long is src      */
    i = len;        /* starting point in src    */
    j = 0;          /* starting point in dest   */
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
                      
            i++;
        } // End while

        fclose(file);

    } // End if file
        
    return cfgstruct;
}

void switchInterrupt(void){
    State=1;
}

int Setup_IO(int Mute_Pin, int Dbg){

    if (Dbg) printf("GPIO Initialisation\n");

    // setup GPIO
    if (wiringPiSetup() == -1){
        printf ("Unable to setup wiringPi: %s\n", strerror (errno));
        return -1;
    }

    if (Dbg) printf("GPIO Initialised, Setting Pullup. Pin is %i\n", Mute_Pin);

    // setup GPIO as input with pull-up
    // pull up is needed as button common is grounded
    pinMode (Mute_Pin, INPUT);
    pullUpDnControl (Mute_Pin, PUD_UP);
    
    if (Dbg) printf("Setting GPIO Interrupt\n");

    if(wiringPiISR (Mute_Pin, INT_EDGE_FALLING, &switchInterrupt) < 0){
        printf ("Unable to setup interrupt: %s\n", strerror (errno));
        return -2;
    }
}

int main(int argc, char * argv[])
{
    printf("External Mute Control v1.0 9 Apr 2016\n\n");
   
    int flag = 0;
    int WPI_Num = -1;
    struct cfg cfgstruct;
        
    cfgstruct = get_config(FILENAME);
    int Dbg_Lvl = (int)cfgstruct.Dbg;
    int GPIO_Num = (int)cfgstruct.GPIO_No;
    char *Mute_Cmd = cfgstruct.Cmd1;
    char *Unmute_Cmd = cfgstruct.Cmd2;
 
    WPI_Num = GPIO2ToWPI [GPIO_Num & 63];
    
    if(Setup_IO(WPI_Num, Dbg_Lvl) < 0){
        printf ("Unable to setup GPIO: %s\n", strerror (errno));
        return 1;
    }
    
    // main loop
    while (flag < 2)
    {
        flag = 0;            // reset flag
        State = 0;           // reset the interrupt status
        
        // waiting for interrupt from Mute pin
        if (Dbg_Lvl) printf("Waiting for Mute activation\n");
        
        while (State == 0)
            delay (Delay);

        // Interrupt has fired (State has changed), hence mute has activated. Write to file and loop until unmuted
        
        if (Dbg_Lvl) printf("Mute activated\n");
        
        // Mute
        system(Mute_Cmd);
        
        while (digitalRead(WPI_Num) == LOW)
            delay (Delay);
 
        // Unmuted
        if (Dbg_Lvl) printf("Unmuted\n");

        system(Unmute_Cmd);
    }

    if (Dbg_Lvl) printf("Exiting Program\n");
}