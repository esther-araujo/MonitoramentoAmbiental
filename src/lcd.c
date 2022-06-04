#include <stdio.h>
#include <wiringPi.h>
#include <lcd.h>
// list wiringPi-RPi pins $ gpio readall

int main(){
    int state = 1;
    int lcd;
    float temperatura=22.45, umidade= 84.6, luminosidade=39.369, pressao=14.233;

    wiringPiSetup();
    lcd = lcdInit(2,16,4,6,31,26,27,28,29,0,0,0,0);

    //resetLcd(lcd);
    lcdPrintf(lcd,"%.1f C %.1f I %.1f U %1.f Pa", temperatura, luminosidade, umidade, pressao);


    return 0;
}




void resetPosLcd(int lcd, int x, int y){
    lcdClear(lcd);
    lcdPosition(lcd, x, y);
}

void resetLcd(int lcd){
    resetPosLcd(lcd, 0, 0);
}
