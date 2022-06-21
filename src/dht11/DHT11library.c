#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "DHT11library.h"
#define MAX_TIME 85
#define false 0
#define true 1
#define MAXTIMINGS  85
#define DHTPIN      4

int DHT11PIN; 
int dht11_val[5] = { 0, 0, 0, 0, 0 }; 
int isinit = 0; 
int dht11_dat[5] = { 0, 0, 0, 0, 0 };

int InitDHT(int pinval) 
{ 
    if (wiringPiSetup() == -1) 
    { 
        isinit = false; 
        return isinit; 
    } 
    DHT11PIN = pinval; 
    // initialize pin 
    isinit = true; 
    return isinit; 
} 

float getTemp() 
{ 
    return (float)(dht11_dat[2] + dht11_dat[3] / 10.0 ); 
} 

float getHumidity() 
{ 
    return (float)(dht11_dat[0] + dht11_dat[1] / 10.0 ); 
} 

int read_dht11_dat()
{
    uint8_t laststate   = HIGH;
    uint8_t counter     = 0;
    uint8_t j       = 0, i;
    float   f; 
 
    dht11_dat[0] = dht11_dat[1] = dht11_dat[2] = dht11_dat[3] = dht11_dat[4] = 0;
 
    pinMode( DHTPIN, OUTPUT );
    digitalWrite( DHTPIN, LOW );
    delay( 18 );
    digitalWrite( DHTPIN, HIGH );
    delayMicroseconds( 40 );
    pinMode( DHTPIN, INPUT );
 
    for ( i = 0; i < MAXTIMINGS; i++ )
    {
        counter = 0;
        while ( digitalRead( DHTPIN ) == laststate )
        {
            counter++;
            delayMicroseconds( 1 );
            if ( counter == 255 )
            {
                break;
            }
        }
        laststate = digitalRead( DHTPIN );
 
        if ( counter == 255 )
            break;
 
        if ( (i >= 4) && (i % 2 == 0) )
        {
            dht11_dat[j / 8] <<= 1;
            if ( counter > 16 )
                dht11_dat[j / 8] |= 1;
            j++;
        }
    }
 
    if ( (j >= 40) && (dht11_dat[4] == ( (dht11_dat[0] + dht11_dat[1] + dht11_dat[2] + dht11_dat[3]) & 0xFF) ) ){
        f = dht11_dat[2] * 9. / 5. + 32;
        printf( "Humidity = %d.%d %% Temperature = %d.%d C (%.1f F)\n",
        dht11_dat[0], dht11_dat[1], dht11_dat[2], dht11_dat[3], f );
    }
    else 
        return -1;
    return 0;
}

void dht11_read_val2()  
{  
  uint8_t lststate=HIGH;  
  uint8_t counter=0;  
  uint8_t j=0,i;  
  printf("%d", DHT11PIN);
  float farenheit;  
  for(i=0;i<5;i++)  
     dht11_val[i]=0;  
  pinMode(DHT11PIN,OUTPUT);  
  digitalWrite(DHT11PIN,LOW);  
  delay(18);  
  digitalWrite(DHT11PIN,HIGH);  
  delayMicroseconds(40);  
  pinMode(DHT11PIN,INPUT);  
  for(i=0;i<MAX_TIME;i++)  
  {  
    counter=0;  
    while(digitalRead(DHT11PIN)==lststate){  
      counter++;  
      delayMicroseconds(1); 
      printf("%u %d", counter, digitalRead(DHT11PIN));
      if(counter==255)  
        break;  
    }  
    lststate=digitalRead(DHT11PIN);  
    if(counter==255)  
       break;  
    // top 3 transistions are ignored  
   //i>=4
    if((i>=2)&&(i%2==0)){ 
    printf("oi"); 
      dht11_val[j/8]<<=1;  
      if(counter>16)  
        dht11_val[j/8]|=1;  
      j++;  
    }  
  }  
 
    printf("Humidity = %d.%d %% Temperature = %d.%d *C (%.1f *F)\n",dht11_val[0],dht11_val[1],dht11_val[2],dht11_val[3],farenheit);  

}  

int dht11_read_val() 
{ 
    if (!isinit) 
        return false; 
    uint8_t lststate = HIGH; 
    uint8_t counter = 0; 
    uint8_t j = 0, i; 
    float farenheit; 
    for (i = 0; i < 5; i++) 
    dht11_val[i] = 0; 

    pinMode(DHT11PIN, OUTPUT); 
    digitalWrite(DHT11PIN, LOW); 
    delay(18); 
    digitalWrite(DHT11PIN, HIGH); 
    delayMicroseconds(40); 
    pinMode(DHT11PIN, INPUT); 
    for (i = 0; i < MAX_TIME; i++) 
    { 
        counter = 0; 
        while (digitalRead(DHT11PIN) == lststate){ 
            counter++; 
            delayMicroseconds(1); 
            if (counter == 255) 
                break; 
        } 
        lststate = digitalRead(DHT11PIN); 
        if (counter == 255) 
        break; 
        // top 3 transistions are ignored   
        if ((i >= 4) && (i % 2 == 0)){ 
            dht11_val[j / 8] = 1; 
            if (counter>16) 
                dht11_val[j / 8] |= 1; 
            j++; 
        } 
    } 
    return true; 
}