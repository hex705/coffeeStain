// Basic example to update Pachube manually
// (e.g. when you're behind a firewall, or only want 
// to update occasionally).
//
// See many other methods available to the DataOut object here:
// http://www.eeml.org/library/docs/eeml/DataOut.html



// once this is running go back to your cosm feed.

import eeml.*;
DataOut dOut;
float lastUpdate;

int count;


void setup(){
    // set up DataOut object; requires URL of the EEML you are updating, and your Pachube API key   
    dOut = new DataOut(this, "https://api.xively.com/v1/feeds/516120207", "Pk6xwriwgLpAcIulDDBAVhJHnI8RIevTK8wH11d30naaRXji");   

    //  and add and tag a datastream  -- that give the stream an ID  
    dOut.addData(0,"Battery_Level");
    dOut.addData(1,"CO2");
   // dOut.addData(2,"my tag 2, foo2, bar2");
}


void draw()
{
    // update once every 5 seconds (could also be e.g. every mouseClick)
    if ((millis() - lastUpdate) > 10000){
        println("ready to POST: ");
        dOut.update(0, random(1000)); // update the datastream 
        dOut.update(1, random(10,100));
       // dOut.update(2,count++);
        int response = dOut.updatePachube(); // updatePachube() updates by an authenticated PUT HTTP request
        println(response); // should be 200 if successful; 401 if unauthorized; 404 if feed doesn't exist
        lastUpdate = millis();
    }   
}
