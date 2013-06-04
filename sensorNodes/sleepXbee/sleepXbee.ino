/*

xBee sleep test -- based upon :
http://electronics.stackexchange.com/questions/33397/how-to-make-xbee-sleep

using an Xbee shiled and a V - divider -- see maual for details.

*/


#define XBEE_sleepPin 6  // toggle wakes -- it goes back t osleep on its own
boolean isSleeping = true;
int count = 0;


void setup() {
  // declare the ledPin as an OUTPUT:
  pinMode(XBEE_sleepPin, OUTPUT);

  Serial.begin(9600);
  Serial.println("xBee Sleep Test");

}



int i = 0;

void loop() {
  
if (i==0)
    xbeeWake();  // we should see the numbers 0,1,3,4,5 -- then a big pause and see 'em again.
  else if (i==5)
    xbeeSleep();
  Serial.println(i);
  i = (i+1) % 10;
  delay(2000);
}



// NOTE falling edge puts this guy to sleep

void xbeeSleep() {
  
  Serial.println("going to sleep");   
  
  digitalWrite(XBEE_sleepPin, LOW); // wake-up XBee
  delay(1);
  digitalWrite(XBEE_sleepPin, HIGH); // wake-up XBee
  
  // blocking to ensure that other stray communication does not keep the xBee awake
  delay (3100); // make this a little bigger than the ST paramter (time before sleep)
  
  isSleeping = true;
}



// NOTE the xBEE wakes on FALLING edge -- it is not level controlled

void xbeeWake() {
  
  digitalWrite(XBEE_sleepPin, HIGH); // wake-up XBee
  delay(1);
  digitalWrite(XBEE_sleepPin, LOW); // wake-up XBee
  delay( 25 );  // xBee wake up time
  
  isSleeping = false;
  
  Serial.println("awake!"); 
  
}


  
