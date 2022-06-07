/* Pro RPi
 * $ gcc -o file_name file_name.c -lpaho-mqtt3c -L ~/Documents/g01/paho.mqtt.c/build/output
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
//Biblioteca paho.mqtt.c
#include <MQTTClient.h>

//Teste com o mosquitto.org
#define MQTT_ADDRESS   "10.0.0.101"
#define CLIENTID       "clientID"  

/*Topicos de publish e subscribe*/
#define MQTT_PUBLISH_TOPIC     "PBL3/teste"
#define MQTT_SUBSCRIBE_TOPIC   "PBL3/teste"
//Passar por parâmetro
#define USERNAME "aluno"
#define PASSWORD "aluno*123"

MQTTClient client;

void publish(MQTTClient client, char* topic, char* payload);
int on_message(void *context, char *topicName, int topicLen, MQTTClient_message *message);

//Publisher de mensagens MQTT
void publish(MQTTClient client, char* topic, char* payload) {
    MQTTClient_message pubmsg = MQTTClient_message_initializer;

    pubmsg.payload = payload;
    pubmsg.payloadlen = strlen(pubmsg.payload);
    pubmsg.qos = 2;
    pubmsg.retained = 0;
    MQTTClient_deliveryToken token;
    MQTTClient_publishMessage(client, topic, &pubmsg, &token);
    MQTTClient_waitForCompletion(client, token, 1000L);
}

//Callback de mensagens MQTT recebidas
int on_message(void *context, char *topicName, int topicLen, MQTTClient_message *message) {
    char* payload = message->payload;

    printf("Mensagem recebida! \n\rTopico: %s Mensagem: %s\n", topicName, payload);

    MQTTClient_freeMessage(&message);
    MQTTClient_free(topicName);
    return 1;
}

int main(int argc, char *argv[])
{
   int rc;
   MQTTClient_connectOptions conn_opts = MQTTClient_connectOptions_initializer;
   conn_opts.keepAliveInterval = 10;
   conn_opts.cleansession = 1;
   conn_opts.username = USERNAME;
   conn_opts.password = PASSWORD;
   /* Inicializacao do MQTT (conexao & subscribe) */
   MQTTClient_create(&client, MQTT_ADDRESS, CLIENTID, MQTTCLIENT_PERSISTENCE_NONE, NULL);
   MQTTClient_setCallbacks(client, NULL, NULL, on_message, NULL);

   rc = MQTTClient_connect(client, &conn_opts);

   if (rc != MQTTCLIENT_SUCCESS)
   {
       printf("\n\rFalha na conexao ao broker MQTT. Erro: %d\n", rc);
       exit(-1);
   }
   //Inscrevendo
   MQTTClient_subscribe(client, MQTT_SUBSCRIBE_TOPIC, 0);
   

   while(1)
   {
        //Publicando
        publish(client, MQTT_PUBLISH_TOPIC, "teste");
        sleep(5000);
        
   }
}
