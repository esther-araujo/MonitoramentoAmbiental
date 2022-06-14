#include <stdio.h>
#include <mosquitto.h>
#include "dht11/DHT11library.h"
#include "dht11/DHT11library.c"
#include "ads/ads1115_rpi.h"
#include "ads/ads1115_rpi.c"
#include "ads/ads1115.c"
#include <string.h>
#include <wiringPi.h>
#include <unistd.h>
#include <time.h>

//Teste com o mosquitto.org
#define MQTT_ADDRESS   "10.0.0.101"
#define CLIENTID       "clientID"  

/*Topicos de publish e subscribe*/
#define MQTT_PUBLISH_TEMP    "medida/temperatura"
#define MQTT_PUBLISH_UMID    "medida/umidade"
#define MQTT_PUBLISH_PRESSAO    "medida/pressaoAtm"
#define MQTT_PUBLISH_LUMI    "medida/luminosidade"


//#define MQTT_SUBSCRIBE_TOPIC   "PBL3/teste"
//Passar por parâmetro
#define USERNAME "aluno"
#define PASSWORD "aluno*123"

#define DHT11PIN 4


float mapValue(float value){
    return (float) ((value * 255) / 3.3);
}


int main(){
	int rc;
	float temperatura, umidade, pressao, luminosidade;
	struct mosquitto * mosq;

	mosquitto_lib_init();

	mosq = mosquitto_new(CLIENTID, true, NULL);
	mosquitto_username_pw_set(mosq,USERNAME, PASSWORD);

	rc = mosquitto_connect(mosq, MQTT_ADDRESS, 1883, 60);
	if(rc != 0){
		printf("Client could not connect to broker! Error Code: %d\n", rc);
		mosquitto_destroy(mosq);
		return -1;
	}
	printf("We are now connected to the broker!\n");

	wiringPiSetup();

	// configuração do ADS1115 
    configADS1115();
    // inicialização do sensor DHT11
    InitDHT(DHT11PIN);

    char temp[10], umid[10], luz[10], pressaoAtm[10];
    int read_dht;

	while(1){
		luminosidade = mapValue(getLuminosity());
    	pressao = mapValue(getPressure());
		read_dht = read_dht11_dat();
		temperatura = getTemp();
		umidade = getHumidity();
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


	//mosquitto_disconnect(mosq);
	//mosquitto_destroy(mosq);

	//mosquitto_lib_cleanup();
	return 0;
}
