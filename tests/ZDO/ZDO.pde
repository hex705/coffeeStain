// Testing ZDO commands (advanced network management) 
// using xbee-api and the "explicit frame" feature
// this requires the router to be configured to receive 
// explicit frames (AO=1, API Output Explicit)

// This programs kicks things off with a Node Discover (ND) command
// from the host device 

// Nodes are added to a list as they are discovered
// Neighbour tables are requested for each node. A spring is created between two nodes if they are neighbours.


//  http://code.google.com/p/xbee-api/


// Key controls:
// s     - randomly re-shuffle the nodes 
// d     - send a node discovery message
// space - automatically resize the layout
// r     - insert repulsions between unconnected nodes

// Mouse controls:
// Drag/Scroll - moves and zooms

import processing.serial.*;
import java.util.concurrent.*;
import java.util.*;
import java.awt.event.*;
import com.rapplogic.xbee.api.zigbee.NodeDiscover;
import traer.physics.*;

String modem =  "/dev/tty.usbserial-A7004nRz"; // Steve's modem
//String modem =  "/dev/tty.usbserial-A901JXFC"; // David's modem
int baud = 38400; // radio baud = 5

// xbee-api object 
XBee xbee;
Queue<XBeeResponse> queue = new ConcurrentLinkedQueue<XBeeResponse>();

XBeeAddress64 ourAddress;

// automatically generated device list 
ArrayList<Node> network = new ArrayList();

// for the drawing 
ParticleSystem physics;
Camera camera;

boolean displayShort = false;

//------------------------------------------------------------------
void setup() {   
  size(720, 500);
  try {
    xbee = new XBee();
    xbee.open(modem, baud);

    // I am not sure what this is about -- i get it, but where is it documented?  or did u make it up?
    xbee.addPacketListener( 
    new PacketListener() {
      public void processResponse(XBeeResponse response) {
        queue.offer(response);
      }
    }
    );

    // Discover our 64 bit address
    AtCommandResponse rl;     
    rl = (AtCommandResponse)xbee.sendSynchronous(new AtCommand("SL"));
    AtCommandResponse rh;     
    rh = (AtCommandResponse)xbee.sendSynchronous(new AtCommand("SH"));
    int[] l = rl.getValue();
    int[] h = rh.getValue();
    int[] full = {h[0], h[1], h[2], h[3], l[0], l[1], l[2], l[3]};
    ourAddress = new XBeeAddress64(full);
    println("Our address: " + ourAddress);
    
    // send a Node Discovery command 
    xbee.sendAsynchronous(new AtCommand("ND"));    
  }
  catch (Exception e) {
    e.printStackTrace();
  }

  physics = new ParticleSystem( 0, 0.1 );
  camera = new Camera();


  // Here's another one of those anonymous classes!
  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      float delta = mwe.getWheelRotation();
      camera.zoomBy(delta * -0.05);
    }
  }
  );
}

//------------------------------------------------------------------
void draw() {

  try { 
    readPackets();
  }
  catch (Exception e) { 
    e.printStackTrace();
  }

  physics.tick();
  background(0);
  camera.apply();

  // draw the springs
  stroke(255, 128);
  for (int i=0; i < physics.numberOfSprings(); i++) {
    Spring s = physics.getSpring(i); 
    Particle a = s.getOneEnd();
    Particle b = s.getTheOtherEnd();
    line (a.position().x(), a.position().y(), b.position().x(), b.position().y());
  }

  // draw and update the nodes 
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
void mouseDragged() {
  camera.move();
}

//------------------------------------------------------------------
// Mouse picking 
void mouseClicked() { 
  PVector m = camera.mouse();
  for (Node n : network) {
    float x = n.p.position().x();
    float y = n.p.position().y();   
    float d = dist(m.x, m.y, x, y); 
    if ( d < n.nodeDisplaySize ) {
      n.click();
    }
  }
}

//------------------------------------------------------------------
void keyPressed() {

  if (key == ' ') {  // auto layout 
    camera.auto();
  }

  if (key == 'r') {  // update repulsions across the network
    updateRepulsions();
  } 

  if (key == 's') { // shuffle the nodes around
    for (Node n : network) n.shuffle();
  }
  
  if (key == '#') {  // update repulsions across the network
    displayShort = !displayShort;  // toggle full name 
  }

  if (key == 'd') { // re-send the ND command
    try {
      println("Sending node discover");
      xbee.sendAsynchronous(new AtCommand("ND"));
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}



