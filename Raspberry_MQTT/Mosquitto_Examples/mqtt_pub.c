#include <stdio.h>
#include <mosquitto.h>

//Teste com o mosquitto.org
#define MQTT_ADDRESS   "10.0.0.101"
#define CLIENTID       "clientID"  

/*Topicos de publish e subscribe*/
#define MQTT_PUBLISH_TOPIC     "PBL3/teste"
#define MQTT_SUBSCRIBE_TOPIC   "PBL3/teste"
//Passar por parâmetro
#define USERNAME "aluno"
#define PASSWORD "aluno*123"

int main(){
	int rc;
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
	while(1){
	mosquitto_publish(mosq, NULL, MQTT_PUBLISH_TOPIC , 6, "Hello", 0, false);
	}


	//mosquitto_disconnect(mosq);
	//mosquitto_destroy(mosq);

	//mosquitto_lib_cleanup();
	return 0;
}
