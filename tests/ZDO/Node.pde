class Node extends VerletParticle2D {

  color c;
  int diameter;  
  String id;
  XBeeAddress64 address;
  
  NodeDiscover nd;  
  
  // quality of the link between the USB device and this node 
  int link = -1; 

  // master list of neighbours for this node
  // addr --> link quality map
  HashMap<XBeeAddress64, Integer> neighbours; 

  //---------------------------------------------------------------------------------
  // Creates a Node object from the XBee-Api NodeDiscover (response from ND command)
  Node(NodeDiscover nd) {
    // better to start at random
    super(random(-width/2, width/2), random(-height/2, height/2));
    
    this.nd = nd;
    
    NodeDiscover.DeviceType t = nd.getDeviceType(); 
    if (t == NodeDiscover.DeviceType.DEV_TYPE_COORDINATOR) c = color(0, 255, 0);
    else if (t == NodeDiscover.DeviceType.DEV_TYPE_ROUTER) c = color(0, 128, 255);
    else c = color(255);

    diameter = 80;
    id = nd.getNodeIdentifier();
    address = nd.getNodeAddress64();

    // Each node will maintain a list of neighbour addresses
    neighbours = new HashMap(); 
    println("Created a new Node: " + this + ", " + address);        
  }
     
  //---------------------------------------------------------------------------------
  // Randomize this node's position
  void shuffle() {
    set( random(-width/2, width/2), random(-height/2, height/2) );
  }
     
     
  //---------------------------------------------------------------------------------
  void display() {
    pushMatrix();
    translate(x, y); 
    fill(0);
    stroke(c);
    strokeWeight(2);
    ellipse(0, 0, diameter, diameter);
    // add some rings to indicate signal strength -- we need to represent ourselves.
    // add a node at beginning and place it at center ?
    pushStyle();
        noFill();
        strokeWeight(3);  
        stroke(color(255-red(c), 255-green(c),0));
        arc(0,0,diameter+8, diameter+8,-PI/2, radians( map(link,0,255,0,360))-PI/2);
        stroke(100);
        arc(0,0,diameter+8, diameter+8,radians( map(link,0,255,0,360))-PI/2,TWO_PI-PI/2);
    popStyle();
    ellipse(0, 0, diameter, diameter);
    String id = nd.getNodeIdentifier();
      // see if device has a short name 
      // if so display the short name ONLY when 
      // displayShort = true
      if (displayShort) {
        int i = id.indexOf('_');
        if ( i > 0 ) {
          id = id.substring (0,i);
          textSize(20);
        }
      }
    fill(c);
    textAlign(CENTER);
    float w = textWidth(id);
    if ( w > 80 ) {
      textSize( 12 * 70/w);
    }
    text(id, 0, 0); 
    textSize(12);
    text("\n"+link, 0, 0);  
    popMatrix();
  }


  //---------------------------------------------------------------------------------
  // Add an entry to the node's neighbour table 
  // lqi is 0-255
  // 255 is the best, 0 is the worst
  void addNeighbour(XBeeAddress64 addr, int lqi) {         
    neighbours.put(addr, lqi);  
    if (addr.equals(ourAddress)) {
      link = lqi; // used to display the link quality from each node to our radio
    }   
  }

  //---------------------------------------------------------------------------------
  XBeeAddress64 getAddress() {
    return nd.getNodeAddress64();
  }

  //---------------------------------------------------------------------------------
  boolean hasNeighbour(Node n) {
    XBeeAddress64 addr = n.getAddress();
    if (neighbours.keySet().contains(addr)) return true;
    return false;
  }
  
  //---------------------------------------------------------------------------------
  public String toString() {
    return "[" + nd.getNodeIdentifier() + "]";
  }
  
  //---------------------------------------------------------------------------------
  // On-click event 
  void click() {
    println("");
    println("====== Neighbour Table for " + this + " ======"); 
    println(""); 
    // for now, print that node's neighbour list
    for (Map.Entry entry : neighbours.entrySet()) {
      XBeeAddress64 addr = (XBeeAddress64)entry.getKey();
      int lqi = (Integer)entry.getValue();
      Node n = graph.findNode(addr); // get the node object for this node 
      String nodeId = "[unknown]"; // assume unknown
      if (n != null) nodeId = n.toString();
      else if (addr.equals(ourAddress)) nodeId = "[me]";       
      String output = String.format("%-20s [%s] link: %d", nodeId, addr, lqi); 
      println(output);
    }
    println("");
    
    //readSensors();
  }

  //---------------------------------------------------------------------------------
  // Request sensor readings on that node
  void readSensors() {
    try {
      RemoteAtRequest request;  
      request = new RemoteAtRequest(getAddress(), "IS");
      xbee.sendAsynchronous(request);
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}

