#include <stdio.h>
#include <wiringPi.h>
#include <lcd.h>
// list wiringPi-RPi pins $ gpio readall

int main(){
    int fd = lcdInit(2, 16, 4, 6, 31, 26, 27, 28, 29,40,0,0,0,0);

    lcdPuts(fd,"hello world");
    return 0;
}