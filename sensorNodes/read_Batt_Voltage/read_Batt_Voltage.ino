// read voltage
// using pololu step/up down 5V switching regulator

void setup() {
  Serial.begin(9600);
}


void loop(){
  
  Serial.print(analogRead(A0));
  Serial.print("\t\t");
  Serial.println(analogRead(A1));
  
  delay(100);
    

}

