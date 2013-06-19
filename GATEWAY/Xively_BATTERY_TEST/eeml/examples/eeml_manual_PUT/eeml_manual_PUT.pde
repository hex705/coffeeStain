// Basic example to update Pachube manually
// (e.g. when you're behind a firewall, or only want 
// to update occasionally).
//
// See many other methods available to the DataOut object here:
// http://www.eeml.org/library/docs/eeml/DataOut.html


import eeml.*;
DataOut dOut;
float lastUpdate;

int count;


void setup(){
    // set up DataOut object; requires URL of the EEML you are updating, and your Pachube API key   
    dOut = new DataOut(this, "http://www.pachube.com/api/19005.xml", "FEE5lHQ-eWzEpEw0Wy0p6-sUGhl5d957dRCZcx1QG5c");   

    //  and add and tag a datastream    
    dOut.addData(0,"my tag 0, tag0, tag0");
    dOut.addData(1,"my tag 1, foo1, bar1");
    dOut.addData(2,"my tag 2, foo2, bar2");
}


void draw()
{
    // update once every 5 seconds (could also be e.g. every mouseClick)
    if ((millis() - lastUpdate) > 5000){
        println("ready to POST: ");
        dOut.update(0, random(1000)); // update the datastream 
        dOut.update(1,random(10,100));
        dOut.update(2,count++);
        int response = dOut.updatePachube(); // updatePachube() updates by an authenticated PUT HTTP request
        println(response); // should be 200 if successful; 401 if unauthorized; 404 if feed doesn't exist
        lastUpdate = millis();
    }   
}
