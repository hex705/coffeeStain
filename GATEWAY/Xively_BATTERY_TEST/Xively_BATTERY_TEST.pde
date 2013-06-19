// Basic example to update Pachube manually
// (e.g. when you're behind a firewall, or only want 
// to update occasionally).
//
// See many other methods available to the DataOut object here:
// http://www.eeml.org/library/docs/eeml/DataOut.html

import processing.serial.*;
import eeml.*;


Serial usbPort;
Scissors xbeeParse;  // new scissors object

char END_BYTE    =  '#';
// once this is running go back to your cosm feed.

import eeml.*;
DataOut dOut;
float lastUpdate;

int count;

String node = "";
int battLevel;
int co2Level;
boolean gotNew = false;

void setup() {
  println(Serial.list());
  usbPort = new Serial (this, Serial.list()[8], 9600);
  delay(5000);

  xbeeParse  = new Scissors( usbPort );

  // set up DataOut object; requires URL of the EEML you are updating, and your Pachube API key   
  dOut = new DataOut(this, "https://api.xively.com/v1/feeds/516120207", "Pk6xwriwgLpAcIulDDBAVhJHnI8RIevTK8wH11d30naaRXji");   

  //  and add and tag a datastream  -- that give the stream an ID  
  dOut.addData(0, "Battery_Level");
  dOut.addData(1, "CO2");
  // dOut.addData(2,"my tag 2, foo2, bar2");
}


void draw()
{
  // update once every 5 seconds (could also be e.g. every mouseClick)

  if (xbeeParse.update() > 0) {  // returns number of elements in MESSAGE
    print("message received @ " );
    println(hour() +":"+ minute() +":"+second());
    println(xbeeParse.getRaw());
    node =  xbeeParse.getString(0);
    battLevel =  xbeeParse.getInt(1);
    co2Level =  xbeeParse.getInt(2);

    gotNew = true;
  } 

  // debug -->  https://xively.com/develop/PmIFq4alJOymD6r21igB
  // view -->  https://xively.com/feeds/516120207

  if (gotNew) {
    println("ready to POST: ");
    dOut.update(0, battLevel); // update the datastream 
    dOut.update(1, co2Level);
    // dOut.update(2,count++);
    int response = dOut.updatePachube(); // updatePachube() updates by an authenticated PUT HTTP request
    println(response); // should be 200 if successful; 401 if unauthorized; 404 if feed doesn't exist
    gotNew = false;
  }   
  delay(1000);
}

