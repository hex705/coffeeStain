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
// d     - send a node discovery message
// space - automatically resize the layout 

// Mouse controls:
// Drag/Scroll - moves and zooms

import processing.serial.*;
import java.util.concurrent.*;
import java.util.*;
import java.awt.event.*;
import com.rapplogic.xbee.api.zigbee.NodeDiscover;

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

String modem =  "/dev/tty.usbserial-A7004nRz"; // Steve's other modem
//String modem =  "/dev/tty.usbserial-A80081Dt"; // Steve's modem
//String modem =  "/dev/tty.usbserial-A901JXFC"; // David's modem
int baud = 38400; // radio baud = 5

XBee xbee;
Queue<XBeeResponse> queue = new ConcurrentLinkedQueue<XBeeResponse>();
XBeeAddress64 ourAddress;

Camera camera;

boolean displayShort = false;

Node selection; 
Graph graph;

//------------------------------------------------------------------
void setup() {   
  size(1280, 720);
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

    // Discover the USB modem's 64 bit address
    AtCommandResponse rl;     
    rl = (AtCommandResponse)xbee.sendSynchronous(new AtCommand("SL"));
    AtCommandResponse rh;     
    rh = (AtCommandResponse)xbee.sendSynchronous(new AtCommand("SH"));
    int[] l = rl.getValue();
    int[] h = rh.getValue();
    int[] full = {
      h[0], h[1], h[2], h[3], l[0], l[1], l[2], l[3]
    };
    ourAddress = new XBeeAddress64(full);
    println("Our address: " + ourAddress);

    // send a Node Discovery command 
    xbee.sendAsynchronous(new AtCommand("ND"));
  }
  catch (Exception e) {
    e.printStackTrace();
  }

  graph = new Graph();
  
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
  background(0);
  camera.apply();

  readPackets();
  
  // draw the edges
  for (Edge edge : graph.edges) {
    boolean selected = false;    
    if (selection == edge.n1 || selection == edge.n2) selected = true;

    if (selected) strokeWeight(5);
    else strokeWeight(1);

    if (edge.count == 1) stroke(255, 128);
    else if (edge.count == 2) stroke(0, 255, 0, 128);
    else stroke(255, 0, 0); 
    line(edge.n1.x, edge.n1.y, edge.n2.x, edge.n2.y);

    if (selected) {
      textSize(12);
      float w = 1.5*textWidth(""+edge.quality);
      Vec2D middle = edge.getMidPoint();
      strokeWeight(1);
      stroke(255);
      fill(0);
      ellipse(middle.x, middle.y, w, w);
      fill(255);
      text(edge.quality, middle.x, middle.y+5);
    }
  }

  // draw the nodes 
  for (Node node : graph.nodes) node.display();
  
  // update/animate the layout
  graph.update(); 
}

//------------------------------------------------------------------
void readPackets() {
  XBeeResponse response;
  while ( (response = queue.poll ()) != null) { 
    ApiId id = response.getApiId();      
    println("Received: " + id);
    try {
      //--------------------------------------------------------------
      if (id == ApiId.ZNET_EXPLICIT_RX_RESPONSE ) readPacket((ZNetExplicitRxResponse)response);
      if (id == ApiId.AT_RESPONSE) readPacket((AtCommandResponse)response);
      if (id == ApiId.REMOTE_AT_RESPONSE) readPacket((RemoteAtResponse)response);
      println("------------------------------------------------------------------------------------");
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}

//------------------------------------------------------------------
void mouseDragged() {
  if (selection == null) { 
    camera.move();
  }
  else {
    selection.addSelf(new Vec2D(mouseX-pmouseX, mouseY-pmouseY));
  }
}

//------------------------------------------------------------------
void mouseReleased() {
  if (selection != null) {
    selection.unlock();
    selection = null;
  }
}

//------------------------------------------------------------------
// Mouse picking 
void mousePressed() { 
  PVector m = camera.mouse();
  for (Node n : graph.nodes) {
    float x = n.x;
    float y = n.y;  
    float d = dist(m.x, m.y, x, y); 
    if ( d < n.diameter ) {
      selection = n;
      selection.lock();
      n.click();
      return;
    }
  }
}

//------------------------------------------------------------------
void keyPressed() {

  if (key == ' ') {  // auto layout 
    camera.auto();
  }

  if (key == 's') {
    for (Node n : graph.nodes) n.shuffle();  
    camera.auto();
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

