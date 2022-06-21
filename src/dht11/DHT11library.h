#ifndef _DHTLIB 
#define _DHTLIB 
#ifdef __cplusplus 
extern "C" { 
#endif
extern int InitDHT(int pinval); 
extern float getTemp(); 
extern float getHumidity(); 
extern int dht11_read_val(); 
extern void dht11_read_val2(); 
extern int read_dht11_dat();

#ifdef __cplusplus 
} 
#endif 
#endif 
