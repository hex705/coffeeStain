// Basic example to retrieve data from an existing Pachube feed
//
// See many other methods available to the DataIn object here:
// http://www.eeml.org/library/docs/eeml/DataIn.html


/* 

NOTE:
becuse this library uses the V! API we can not address a stream by name --

only by index.

have to see if this can be changed

*/


import eeml.*;

DataIn dIn;

void setup(){
    // set up DataIn object; indicate the URL you want, your Pachube API key, and how often you want it to update
    // e.g. every 15 seconds    
    dIn = new DataIn(this,"https://api.xively.com/v1/feeds/516120207", "Pk6xwriwgLpAcIulDDBAVhJHnI8RIevTK8wH11d30naaRXji", 15000);
}

void draw()
{
    // do whatever needs doing in the main loop
}

// onReceiveEEML is run every time your app receives back EEML that it has requested from a Pachube feed. 
void onReceiveEEML(DataIn d){ 
    float myVariable = d.getValue(1); // get the value of the stream 1
    println(myVariable);
}
