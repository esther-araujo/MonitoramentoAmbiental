#include <stdio.h>
#include <string.h>
#include <wiringPi.h>
#include <lcd.h>
#include "ads/ads1115_rpi.h"
#include "ads/ads1115_rpi.c"
#include "ads/ads1115.c"
#include "dht11/DHT11library.h"
#include "dht11/DHT11library.c"
#include <mosquitto.h>

// list wiringPi-RPi pins $ gpio readall

// gcc -o file file.c -lwiringPi -lwiringPiDev -lmosquitto
//Teste com o mosquitto.org
#define MQTT_ADDRESS   "10.0.0.101"
#define CLIENTID       "clientID"  

/*Topicos de publish e subscribe*/
#define MQTT_PUBLISH_TEMP    "medida/temperatura"
#define MQTT_PUBLISH_UMID    "medida/umidade"
#define MQTT_PUBLISH_PRESSAO    "medida/pressaoAtm"
#define MQTT_PUBLISH_LUMI    "medida/luminosidade"
#define MQTT_PUBLISH_HIST_TEMP    "historico/temperatura"
#define MQTT_PUBLISH_HIST_UMID    "historico/umidade"
#define MQTT_PUBLISH_HIST_PRESSAO    "historico/pressaoAtm"
#define MQTT_PUBLISH_HIST_LUMI    "historico/luminosidade"
#define MQTT_PUBLISH_TEMPO    "config/tempo"



//#define MQTT_SUBSCRIBE_TOPIC   "PBL3/teste"
//Passar por parâmetro
#define USERNAME "aluno"
#define PASSWORD "aluno*123"

#define DHT11PIN 4

float temperatura, umidade, luminosidade, pressao;
float temperaturaH[10], umidadeH[10], luminosidadeH[10], pressaoH[10];
int historicoIndex = 0;
int historicoQtd = 0;

int lcd;
int menuLocalizacao = 0;
int menuPosicao = 0;
int changeInterface = 1;

int configTempo = 1;
int chaveTempo = 0;
// variaveis para armazenar o nivel logico das chaves que configuram o tempo
int chaveT1 = 4;//esses são numeros na placa é necessario trocar para a numeração do wiringPi
int chaveT2 = 17;
int chaveT3 = 27;
int chaveT4 = 22;
//

char menu2nivel = '*';
char menu3nivel = '-';
char menuOpcoes[3][32] = {
    "1: Acompanhar em tempo real",
    "2: Historico",
    "3: Configurar tempo"
};

int rc;
struct mosquitto * mosq;

void resetLcd(int lcd);
void printMedidas();
void menu();
void proximo();
void voltar();
void confirmar();
void updateMedidas();
void updateHistorico();
float mapValue(float value, int max);
void remoteUpdateMQTT();
void updateConfigTempo();
void updateChaveTempo();
int getChaveTempo();
void on_message(struct mosquitto *mosq, void *obj, const struct mosquitto_message *message);


PI_THREAD (medidasThread)
{
    while (1)
    {
        updateMedidas();
        remoteUpdateMQTT();
        usleep(configTempo * 1000000);
    }
}

void remoteUpdateMQTT(){

    char temp[10], umid[10], luz[10], pressaoAtm[10];
    int read_dht;
    sprintf(temp, "%.2f", temperatura);
    sprintf(umid, "%.2f", umidade);
    sprintf(luz, "%.2f", luminosidade);
    sprintf(pressaoAtm, "%.2f", pressao);

    
    if(read_dht!=-1){
        mosquitto_publish(mosq, NULL, MQTT_PUBLISH_TEMP , strlen(temp), temp, 0, false);
        mosquitto_publish(mosq, NULL, MQTT_PUBLISH_UMID , strlen(umid), umid, 0, false);
        mosquitto_publish(mosq, NULL, MQTT_PUBLISH_PRESSAO , strlen(pressaoAtm), pressaoAtm, 0, false);
        mosquitto_publish(mosq, NULL, MQTT_PUBLISH_LUMI , strlen(luz), luz, 0, false);
    }

}


int main(){
    mosquitto_lib_init();

    mosq = mosquitto_new(CLIENTID, true, NULL);
    mosquitto_username_pw_set(mosq,USERNAME, PASSWORD);

    rc = mosquitto_connect(mosq, MQTT_ADDRESS, 1883, 60);
    if(rc != 0){
        printf("Client could not connect to broker! Error Code: %d\n", rc);
        mosquitto_destroy(mosq);
        return -1;
    }
	mosquitto_message_callback_set(mosq, on_message);
    printf("We are now connected to the broker!\n");
    wiringPiSetup();
    lcd = lcdInit(2,16,4,6,31,26,27,28,29,0,0,0,0);

    // configuração do ADS1115 
    configADS1115();
    // inicialização do sensor DHT11
    InitDHT(DHT11PIN);

    wiringPiISR (21, INT_EDGE_FALLING, &voltar);//botão voltar
    wiringPiISR (24, INT_EDGE_FALLING, &proximo);//botão proximo
    wiringPiISR (25, INT_EDGE_FALLING, &confirmar);//botão confirmar
    
    int x = piThreadCreate(medidasThread);
    if (x !=0 ){
        printf("Erro ao iniciar a thread.");
    }

    menu();

    return 0;
}

void resetLcd(int lcd){
    lcdClear(lcd);
    lcdPosition(lcd, 0, 0);
}

void printMedidas(){

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
        if(changeInterface){
            if(menuLocalizacao == 0){
                resetLcd(lcd);
                lcdPuts(lcd, menuOpcoes[menuPosicao]);
            }
            else if (menuLocalizacao == 1){
                printMedidas();
            }
            else if (menuLocalizacao == 2){
                printHistorico();
            }
            else if (menuLocalizacao == 3){
                strcat(mensagemTempo1, (char*) ('0'+configTempo) );
                strcat(mensagemTempo1, " s");

                strcat(mensagemTempo2, (char*) ('0'+chaveTempo) );
                strcat(mensagemTempo2, " s");

                resetLcd(lcd);
                lcdPuts(lcd, mensagemTempo1);
                lcdPosition(lcd, 0, 1);
                lcdPuts(lcd, mensagemTempo2);
            }
            changeInterface = 0;
        }
    }
    
}

void proximo(){
    if (menuLocalizacao == 2){
        historicoIndex++;
        if(historicoIndex >= historicoQtd ){
            historicoIndex = 0;
        }
    }
    else if (menuLocalizacao == 0) {
        menuPosicao >= 2 ? menuPosicao = 0 : menuPosicao++;
    }
    changeInterface = 1;
}


void confirmar(){
    if (menuLocalizacao == 0) {
        menuLocalizacao = menuPosicao+1;
    }
    else if (menuLocalizacao == 1) {// 
        updateMedidas();//quando estiver exibindo as medidas atuais o botão confirmar força a atualização das medidas
    }
    else if (menuLocalizacao == 3) {
        updateConfigTempo();//confirma a atualização do tempo e publica a mesma no topico MQTT
    }
    changeInterface = 1;
}

void voltar(){
    if(menuLocalizacao == 0){
        menuPosicao <= 0 ? menuPosicao = 2 : menuPosicao--;
    }
    else {
        menuLocalizacao = 0;
    }
    changeInterface = 1;
}

void updateMedidas(){
    luminosidade = mapValue(getLuminosity(), 10);
    pressao = mapValue(getPressure(), 100);
    read_dht11_dat();
    temperatura = getTemp();
    umidade = getHumidity();
    updateHistorico();
    changeInterface =1;
}

void updateHistorico(){
    for(int i=0;i<historicoQtd-1;i++){
        temperaturaH[i+1] = temperaturaH[i];
        umidadeH[i+1] = umidadeH[i];
        pressaoH[i+1] = pressaoH[i];
        luminosidadeH[i+1] = luminosidadeH[i];
    }
    temperaturaH[0] = temperatura; 
    umidadeH[0] = umidade; 
    pressaoH[0] = pressao; 
    luminosidadeH[0] = luminosidade; 
    if(historicoQtd < 10) 
        historicoQtd++;
}

void updateConfigTempo(){
    char charTempo[4];

    configTempo = chaveTempo;
    changeInterface = 1;

    sprintf(charTempo, "%d", configTempo);
    mosquitto_publish(mosq, NULL, MQTT_PUBLISH_TEMPO , strlen(charTempo), charTempo, 0, false);
}

void updateChaveTempo(){
    chaveTempo = getChaveTempo();
    changeInterface = 1;
}

int getChaveTempo(){
    if(digitalRead(chaveT4)){
        return 100;
    }
    if(digitalRead(chaveT3)){
        return 80;
    }
    if(digitalRead(chaveT2)){
        return 60;
    }
    if(digitalRead(chaveT1)){
        return 40;
    }
    return 20;
}

void on_message(struct mosquitto *mosq, void *obj, const struct mosquitto_message *msg) {
	printf("Nova mensagem\n %s: %s\n", msg->topic, (char *) msg->payload);
    if( strcmp(msg->topic, MQTT_PUBLISH_TEMPO) == 0 ){
        chaveTempo = atoi(msg->payload);
        changeInterface = 1;
    }
}

float mapValue(float value, int max){
    return (float) ((value * max) / 3.3);
}
