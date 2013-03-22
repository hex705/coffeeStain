// Testing ZDO commands (advanced network management) 
// using xbee-api and the "explicit frame" feature
// this requires the router to be configured to receive 
// explicit frames (AO=1) 

// This programs kicks things off with a Node Discover (ND) command
// from the host device 

// Nodes are added to a list as they are discovered
// Neighbour tables are requested for each node. A spring is created between two nodes if they are neighbours.

import processing.serial.*;
import java.util.concurrent.*;
import java.util.*;
import com.rapplogic.xbee.api.zigbee.NodeDiscover;
import traer.physics.*;

String modem = "/dev/tty.usbserial-A901JXFC";
int baud = 38400;

// xbee-api object 
XBee xbee;
Queue<XBeeResponse> queue = new ConcurrentLinkedQueue<XBeeResponse>();

// some addresses for testing
XBeeAddress64 deskAddr = new XBeeAddress64(0x00, 0x13, 0xa2, 0x00, 0x40, 0x70, 0x7e, 0xee);
XBeeAddress64 gatewayAddr = new XBeeAddress64(0x00, 0x13, 0xa2, 0x00, 0x40, 0x9f, 0xb9, 0xbd);

// automatically generated device list 
ArrayList<Node> network = new ArrayList();

// for the drawing 
ParticleSystem physics;

//------------------------------------------------------------------
void setup() {   
  size(500, 500);
  try {
    xbee = new XBee();
    xbee.open(modem, baud);
    xbee.addPacketListener(new PacketListener() {
      public void processResponse(XBeeResponse response) {
        queue.offer(response);
      }
    }
    );    
    // send a Node Discovery command 
    xbee.sendAsynchronous(new AtCommand("ND"));
    
    // test a ZDO command
    //ZNetExplicitTxRequest zdo = buildNeighbourTableRequest(deskAddr, 0, 0);     
    //xbee.sendAsynchronous(zdo);
    
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  
  physics = new ParticleSystem( 0, 0.1 );
}

//------------------------------------------------------------------
void draw() {
  physics.tick();
  try { 
    readPackets();
  }
  catch (Exception e) { 
    e.printStackTrace();
  }

  background(0);
  
  // draw the springs
  stroke(255, 128);
  for (int i=0; i < physics.numberOfSprings(); i++) {
    Spring s = physics.getSpring(i); 
    Particle a = s.getOneEnd();
    Particle b = s.getTheOtherEnd();
    line (a.position().x(), a.position().y(), b.position().x(), b.position().y());
  }
  
  for (Node node : network) {
    node.update();    
    node.display();
  }
}

//------------------------------------------------------------------
void readPackets() {
  XBeeResponse response;
  while ( (response = queue.poll ()) != null) { 
    ApiId id = response.getApiId();      
    println("Received: " + id);
    //--------------------------------------------------------------
    if (id == ApiId.ZNET_EXPLICIT_RX_RESPONSE ) readPacket((ZNetExplicitRxResponse)response);
    if (id == ApiId.AT_RESPONSE) readPacket((AtCommandResponse)response);
    println("------------------------------------------------------------------------------------");
  }
}


//------------------------------------------------------------------
// Builds a ZDO request for Neighbour Tables  

ZNetExplicitTxRequest buildNeighbourTableRequest(XBeeAddress64 addr, int index, int messageCount) {
  DoubleByte clusterId = new DoubleByte(0x0, 0x31);  // neighbor table request message is 0x0031
  int frameId = 0x0;
  int[] payload = {
    messageCount, index
  }; 
  ZNetExplicitTxRequest zdo; 
  zdo = new ZNetExplicitTxRequest(frameId, 
  addr, // addr64
  XBeeAddress16.ZNET_BROADCAST, // addr16
  0, // broadcast radius
  ZNetTxRequest.Option.UNICAST, //option
  payload, // payload
  0x0, // source endpoint
  0x0, // dest endpoint
  clusterId, 
  ZNetExplicitTxRequest.zdoProfileId);
  return zdo;
}

