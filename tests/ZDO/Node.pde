class Node {

  int LINK_LENGTH = 400; // for drawing/physics purposes 
  float LINK_STRENTGH = 0.2;

  NodeDiscover nd;  // node descriptor information  
  Particle p;  
  color c;
  int nodeDisplaySize = 80;
  int link = -1; // quality of the link between the USB device and this node 

  HashMap<XBeeAddress64, Integer> connections; // master list of neighbours for this node

  ArrayList<XBeeAddress64> connected; // nodes that have been linked by springs
  ArrayList<XBeeAddress64> repelled; // nodes that have been pushed away by repulsions 

  //---------------------------------------------------------------------------------
  Node(NodeDiscover nd) {
    println("building a new Node");
    this.nd = nd;
    p = physics.makeParticle();
    p.position().set(random(-width/2, width/2), random(-height/2, height/2), 0);  

    NodeDiscover.DeviceType t = nd.getDeviceType(); 
    if (t == NodeDiscover.DeviceType.DEV_TYPE_COORDINATOR) c = color(0, 255, 0);
    else if (t == NodeDiscover.DeviceType.DEV_TYPE_ROUTER) c = color(0, 128, 255);
    else c = color(255);

    connections = new HashMap();

    connected = new ArrayList();
    repelled = new ArrayList();
  }

  //---------------------------------------------------------------------------------
  void shuffle() {
    p.position().set(random(-width/2, width/2), random(-height/2, height/2), 0);
  }

  //---------------------------------------------------------------------------------
  void display() {
    pushMatrix();
    translate(p.position().x(), p.position().y()); 
    fill(0);
    stroke(c);
    strokeWeight(2);
    ellipse(0, 0, nodeDisplaySize, nodeDisplaySize);
    fill(c); 
    textAlign(CENTER);

    // calculate the textSize
    textSize(12); 
    String id = nd.getNodeIdentifier();
    float w = textWidth(id);
    if ( w > 80 ) {
      textSize( 12 * 70/w);
    }
    text(id+"\n"+link, 0, 0);  
    popMatrix();
  }

  //---------------------------------------------------------------------------------
  void update() {
    // check if we need to make new connections since more nodes may have been 
    // discovered 
    for (Map.Entry entry : connections.entrySet()) {
      XBeeAddress64 addr = (XBeeAddress64)entry.getKey();
      int lqi = (Integer)entry.getValue();
      Node toNode = getNode(addr);
      if (toNode != null && connected.contains(addr) == false) {

        // make sure we don't double connect
        if (toNode.connected.contains( getNodeAddress64())) {
          println("ALREADY CONNECTED!");
          connected.add(addr); 
          continue;
        }

        // scale the link length based on the link quality indicator
        // low quality == full distance
        // high quality = shorter link
        float ll = map(lqi, 0, 255, 1, 0.3);

        physics.makeSpring(p, toNode.p, LINK_STRENTGH, LINK_STRENTGH, ll * LINK_LENGTH);
        connected.add(addr);
      }
    }
  }

  //---------------------------------------------------------------------------------
  // Connect this node with another 
  // lqi is 0-255
  // 255 is the best, 0 is the worst
  void connect(XBeeAddress64 addr, int lqi) {     
    connections.put(addr, lqi);  
    if (addr.equals(ourAddress)) {
      link = lqi; // used to display the link quality from each node to our radio
    }
  }

  //---------------------------------------------------------------------------------
  XBeeAddress64 getNodeAddress64() {
    return nd.getNodeAddress64();
  }

  //---------------------------------------------------------------------------------
  boolean hasNeighbour(Node n) {
    XBeeAddress64 addr = n.getNodeAddress64();
    if (connections.keySet().contains(addr)) return true;
    return false;
  }

  //---------------------------------------------------------------------------------
  public String toString() {
    return "[" + nd.getNodeIdentifier() + "]";
  }


  //---------------------------------------------------------------------------------
  // On-click event 
  void click() {
    println("============================================================");
    println("Neighbour Table for: " + this); 
    // for now, print that node's neighbour list
    for (Map.Entry entry : connections.entrySet()) {
      XBeeAddress64 addr = (XBeeAddress64)entry.getKey();
      int lqi = (Integer)entry.getValue();
      Node n = getNode(addr);
      String nodeId = "[unknown]";
      if (n != null) nodeId = n.toString();
      else if (addr.equals(ourAddress)) nodeId = "[me]";       
      String output = String.format("%-20s [%s] link: %d", nodeId, addr, lqi); 
      println(output);
    }
    
    //readSensors();
  }

  //---------------------------------------------------------------------------------
  // Request sensor readings on that node
  void readSensors() {
    try {
      RemoteAtRequest request;  
      request = new RemoteAtRequest(getNodeAddress64(), "IS");
      xbee.sendAsynchronous(request);
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}

