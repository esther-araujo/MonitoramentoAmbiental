#include <stdio.h>
#include <wiringPi.h>
#include <lcd.h>
// lcdInit (int rows, int cols, int bits, int rs, int strb, int d0, int d1, int d2, int d3, int d4, int d5, int d6, int d7)
// d0 - d7 pin data
// rs - gpio 25 - pin 22
// strb - gpio ID_SC - pin 28

int main(){
    int fd = lcdInit(2, 16, 4, 6, 31, 26, 27, 28, 29,40,0,0,0,0);

    lcdPuts(fd,"hello world");
    return 0;
}