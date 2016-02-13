#!/usr/bin/env python

import RPi.GPIO as GPIO
import time
import os
from time import sleep

GPIO.setmode(GPIO.BCM)

mainButton = 17
pressTimeout = 1

# state of some application, starts with "0"
state = 0

# main loop, exit if button held down
while (state < 3):

    # setup GPIO "mainButton" as input with pull-up
    GPIO.setup(mainButton, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    # waiting for interrupt from button press
    GPIO.wait_for_edge(mainButton, GPIO.FALLING)  

    # waiting for multiple presses
    pressSec = 0
    # count presses
    presses = 0
    #keep a status
    state = 0

    while (pressSec <= pressTimeout and presses < 3):
        # waiting for button release
        holdSec = 0
        while (GPIO.input(mainButton) == GPIO.LOW and state < 3):
            # delay for debouncing
            sleep(0.2)
            holdSec += 0.2

            # record that a button was pressed
            state = 1

            # pressed longer than press timeout?
            if (holdSec > pressTimeout):
                # set presses and state so that we exit straight away
                presses = 20
                state = 3

        # button was released, but prevent recording multiple presses while waiting
        if (state == 1):
            state = 2
            presses += 1

        # increase presses, add time while button was held down
        # add additional for when button wasn't held down
        pressSec = pressSec + holdSec + 0.2

        # check for additiona press within 2 second window
        # but only wait for half a second
        GPIO.wait_for_edge(mainButton, GPIO.FALLING, timeout=500)

    # button timeout expired
    if (presses == 3):
        # toggle play/pause
        os.system('mpc toggle')
    if (presses == 2):
        # go backwards
        os.system('mpc prev')
    if (presses == 1):
        # next
        os.system('mpc next')

# reset interrupt
GPIO.cleanup()

#     	        system("/sbin/shutdown -h now")
#     	        exit(0)
