// library from 
//  


import processing.serial.*;
import java.util.concurrent.*;
import java.util.*;

String modem = "/dev/tty.usbserial-A80081Dt"; // red board
int baud = 9600;

XBee xbee;
Queue<XBeeResponse> queue = new ConcurrentLinkedQueue<XBeeResponse>();

// Hardcoded address for my test wall router
// This could be obtained from the "ND" command results..
XBeeAddress64 alex_104 = new XBeeAddress64(0x00,0x13,0xa2,0x00,0x40,0x70,0x7d,0x9d);

//////////////////////////////////////////////////////////////////////////////////////
void setup() {
  xbee = new XBee();
  try {
    
    xbee.open(modem, baud);

    xbee.addPacketListener(new PacketListener() {
      public void processResponse(XBeeResponse response) {
        queue.offer(response);
      }
    }
    );
    
    xbee.sendAsynchronous(new AtCommand("NI"));
    xbee.sendAsynchronous(new AtCommand("ND"));
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

//////////////////////////////////////////////////////////////////////////////////////
void draw() {
  try { 
    readPackets();
  }
  catch (Exception e) { 
    e.printStackTrace();
  }
}

//////////////////////////////////////////////////////////////////////////////////////
void readPackets() throws Exception {

  XBeeResponse response;
  while ( (response = queue.poll ()) != null) {
    println("-----------------------------------------------------------");

    ApiId id = response.getApiId();
    // cast the response to the proper class
    if (id == ApiId.AT_RESPONSE) {
      
      AtCommandResponse atResponse = (AtCommandResponse) response;
      String command = atResponse.getCommand();
      boolean ok = atResponse.isOk();
      println("AT response: " + command + ", OK? " + ok);
      if (command.equals("ND")) {
        // we got a Node Discover response
        com.rapplogic.xbee.api.zigbee.NodeDiscover nd = com.rapplogic.xbee.api.zigbee.NodeDiscover.parse(atResponse);
        print(nd.getNodeIdentifier() + " | ");
        print(nd.getNodeAddress64() + " | " );
        print(nd.getDeviceType());
      }
      else {
        println(atResponse);  
      }
      
    }
    else if (id == ApiId.REMOTE_AT_RESPONSE) {
      println("Remote AT response");
      RemoteAtResponse remoteResponse = (RemoteAtResponse) response;
      String command = remoteResponse.getCommand();
      boolean ok = remoteResponse.isOk();
      XBeeAddress64 addr = remoteResponse.getRemoteAddress64();
      println(command + " --> " + addr + ", OK? " + ok);
      
      // respond to different commands 
      if (command.equals("IS")) {
        // the IO samples are encoded in the response's values() array 
        // but the easiest thing is to let this class to the parsing:
        ZNetRxIoSampleResponse sample =  ZNetRxIoSampleResponse.parseIsSample(remoteResponse);
        println(sample);  
      }     
    }
    // We get these responses when interval sampling is enabled 
    else if (id == ApiId.ZNET_IO_SAMPLE_RESPONSE) {
      
      ZNetRxIoSampleResponse sample = (ZNetRxIoSampleResponse)response;
      println(sample);  
    }
    else {
      println("What is this response? " + id);
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////
void keyPressed() {
  // trigger a sample reading on the wall router
  RemoteAtRequest request;  
  try {
    //** DN doesn't seem to work at all... 
    //request = new RemoteAtRequest(alex_104, "DN", ByteUtils.stringToIntArray("USB"));
    //xbee.sendAsynchronous(request);
    
    //** This is for automated samples. The DL/DH address of the device must
    //be set to a specific device on the network, or else we receive nothing
    //request = new RemoteAtRequest(alex_104, "IR", ByteUtils.convertInttoMultiByte(30*1000));
    //xbee.sendAsynchronous(request);
    
    //** This triggers a forced sample reading. It appears that it will 
    //automatically send the results back to us, even if the destination 
    //address is not set on the remote device.
    request = new RemoteAtRequest(alex_104, "IS");
    xbee.sendAsynchronous(request);
  }
  catch (Exception e) {
    e.printStackTrace();  
  }
}

