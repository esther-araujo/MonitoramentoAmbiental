#include <stdio.h>
#include <string.h>
#include <wiringPi.h>
#include <lcd.h>
// list wiringPi-RPi pins $ gpio readall

float temperatura, umidade, luminosidade, pressao;
float temperaturaH[10], umidadeH[10], luminosidadeH[10], pressaoH[10];
int historicoIndex = 0;
int historicoQtd = 0;

int lcd;
int menuLocalizacao = 0;
int menuPosicao = 0;
int change = 1;

int configTempo = 10;
int chaveTempo = 0;

char menu2nivel = '*';
char menu3nivel = '-';
char menuOpcoes[3][32] = {
        "1: Acompanhar em tempo real",
        "2: Historico",
        "3: Configurar   tempo"
    };

void resetLcd(int lcd);
void printMedicoes();
void menu();
void proximo();
void voltar();
void confirmar();

int main(){
    wiringPiSetup();
    lcd = lcdInit(2,16,4,6,31,26,27,28,29,0,0,0,0);


    temperatura=22.45;
    umidade= 84.6;
    luminosidade=39.369;
    pressao=14.233;

    temperaturaH[0] = temperatura;
    umidadeH[0] = umidade;
    luminosidadeH[0] = luminosidade;
    pressaoH[0] = pressao;
    historicoQtd = 1;


    wiringPiISR (21, INT_EDGE_FALLING, &voltar);//botão voltar
    wiringPiISR (24, INT_EDGE_FALLING, &proximo);//botão proximo
    wiringPiISR (25, INT_EDGE_FALLING, &confirmar);//botão confirmar

    menu();
    //raspberry

    return 0;
}

void resetLcd(int lcd){
    lcdClear(lcd);
    lcdPosition(lcd, 0, 0);
}

void printMedicoes(){

    resetLcd(lcd);
    lcdPrintf(lcd,"%.1f C | %.1f I", temperatura, luminosidade);
    lcdPosition(lcd, 0, 1);
    lcdPrintf(lcd,"%.1f U | %.1f Pa", umidade, pressao);
}

void printHistorico(){

    resetLcd(lcd);
    lcdPrintf(lcd,"%.1f C | %.1f I", temperaturaH[historicoIndex], luminosidadeH[historicoIndex] );
    lcdPosition(lcd, 0, 1);
    lcdPrintf(lcd,"%.1f U | %.1f Pa", umidadeH[historicoIndex], pressaoH[historicoIndex] );
}

void menu(){
    char mensagemTempo1[32] = "Tempo salvo: ";
    char mensagemTempo2[32] = " ";

    while(1){
        if(change){
            if(menuLocalizacao == 0){
                resetLcd(lcd);
                lcdPuts(lcd, menuOpcoes[menuPosicao]);
            }
            else if (menuLocalizacao == 1){
                printMedicoes();
            }
            else if (menuLocalizacao == 2){
                printHistorico();
            }
            else if (menuLocalizacao == 3){
                strcat(mensagemTempo1, (char*) ('0'+configTempo) );
                strcat(mensagemTempo1, "s");

                strcat(mensagemTempo2, (char*) ('0'+chaveTempo) );
                strcat(mensagemTempo2, " s");

                resetLcd(lcd);
                lcdPuts(lcd, mensagemTempo1);
                lcdPosition(lcd, 0, 1);
                lcdPuts(lcd, mensagemTempo2);
            }
            change = 0;
        }
    }
    
}

void proximo(){
    menuPosicao >= 2 ? menuPosicao = 0 : menuPosicao++;
    change = 1;
}


void confirmar(){
    menuLocalizacao = menuPosicao+1;
    change = 1;
}

void voltar(){
    if(menuLocalizacao == 0){
        menuPosicao <= 0 ? menuPosicao = 2 : menuPosicao--;
    }
    else {
        menuLocalizacao = 0;
    }
    change = 1;
}