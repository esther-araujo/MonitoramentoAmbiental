#include <stdio.h>
#include <wiringPi.h>
#include <lcd.h>
// lcdInit (int rows, int cols, int bits, int rs, int strb, int d0, int d1, int d2, int d3, int d4, int d5, int d6, int d7)
// d0 - d7 pin data
// rs - gpio 25 - pin 22
// strb - gpio ID_SC - pin 28

int main(){
    int fd = lcdInit(2, 16, 4, 22,28, 32,36,38,40,0,0,0,0);
    int state = 1;
    lcdDisplay(fd, state);
    lcdCursor(fd, state);
    lcdCursorBlink(fd, state);

    lcdPosition(fd,0,0);
    lcdPrintf(fd,"hello world");
    return 0;
}