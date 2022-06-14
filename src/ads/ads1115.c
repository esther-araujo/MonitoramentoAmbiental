#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include "ads1115_rpi.h"
 
float getPressure(){
    return readVoltage(3);
}

float getLuminosity(){
    return readVoltage(0);
} 

int configADS1115(){
    if(openI2CBus("/dev/i2c-1") == -1) {
        return EXIT_FAILURE;
    }
    setI2CSlave(0x48);
    return 0;
}
