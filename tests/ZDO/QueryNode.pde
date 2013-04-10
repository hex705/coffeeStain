// get our own node type 
class QueryNode {

XBeeAddress16 our16Address;
XBeeAddress64 our64Address;
XBeeAddress64 ourPan;
String ourNodeIdentifier;
int  ourDeviceType;



QueryNode( XBeeAddress64 _queryAddress ){
  
  our64Address = _queryAddress;
  
  getQueryNodeCharacteristics();
}

void getQueryNodeCharacteristics(){
  
   try {
     println();
     println("Query Node Characteristics ");
     println("==========================");
  
     AtCommandResponse dd;            // AT command DD == get the local DEVICE type 
     AtCommandResponse ni;     // AT command  NI --> get identifier
     AtCommandResponse my;     // AT MY -- > get my 16 bit address
     AtCommandResponse id;     // AT id --> PAN
               
     // get query 16 bit address --> MY         
     my = (AtCommandResponse)xbee.sendSynchronous(new AtCommand("MY"));
     int[] d = my.getValue();
     our16Address = new XBeeAddress16(d[0], d[1]);
     
     // get Query PAN -- > ID                     
     id = (AtCommandResponse)xbee.sendSynchronous(new AtCommand("ID"));
     d = id.getValue();
     ourPan = new XBeeAddress64(d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7]);
     
     // get Node identifier  -- > NI
     ni = (AtCommandResponse)xbee.sendSynchronous(new AtCommand("NI"));
     d = ni.getValue();
     ourNodeIdentifier = convertToString(d);

     // get device type --> DD
     dd = (AtCommandResponse)xbee.sendSynchronous(new AtCommand("DD"));
     d = dd.getValue();
     ourDeviceType = d[0] * 1000 +d[1] *100 + d[2]* 10 + d[3];
     // if (ourDeviceType == 300) ourDeviceTypeprintln    
    
    
     println("Query Node Identifier: " + ourNodeIdentifier );
     println("16 bit address:         [" + hex(our16Address.get16BitValue(), 4) + "] ");
     println("64 bit address:         " + our64Address);
     println();
     
     println("Network PAN ID:  " + ourPan);
     
     println("my device type is ... " + ourDeviceType);
      }
      
  catch (Exception e) {
    e.printStackTrace();
  }
     
     
}

String convertToString( int[] v){
       String s= "";
       for (int i = 0; i < v.length; i ++ ){
          s+=char(v[i]);
       } 
       return s;
     } // end conver to string



} // end class

