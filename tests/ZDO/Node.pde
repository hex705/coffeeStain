class Node {
  
  int LINK_LENGTH = 200; // for drawing
  
  NodeDiscover nd;  // node descriptor information  
  Particle p;
  color c;
  int nodeDisplaySize = 80;
  
  ArrayList<XBeeAddress64> connections; 
  
  Node(NodeDiscover nd) {
    println("building a new NODE");
    this.nd = nd;
    p = physics.makeParticle();
    p.position().set(random(nodeDisplaySize/2,width-nodeDisplaySize/2), random(nodeDisplaySize/2,height-nodeDisplaySize/2), 0);  
    
    NodeDiscover.DeviceType t = nd.getDeviceType(); 
    if (t == NodeDiscover.DeviceType.DEV_TYPE_COORDINATOR) c = color(0, 255, 0);
    else if (t == NodeDiscover.DeviceType.DEV_TYPE_ROUTER) c = color(0, 128, 255);
    else c = color(255);
    connections = new ArrayList();
  }
  
  void display() {
    pushMatrix();
    translate(p.position().x(), p.position().y()); 
    fill(0);
    stroke(c);
    strokeWeight(2);
    ellipse(0, 0, nodeDisplaySize, nodeDisplaySize);
    fill(c); 
    textAlign(CENTER);
    text(nd.getNodeIdentifier(), 0, 6);  
    popMatrix();  
  }
  
  void update() {
    // check if we need to make connections
    for (int i=0; i < connections.size(); i++) {
       XBeeAddress64 addr = connections.get(i);
       Node toNode = getNode(addr);
       if (toNode != null) {
         physics.makeSpring(p, toNode.p, 0.2, 0.2, LINK_LENGTH);
         connections.remove(addr); 
       }  
    }
  }
  
  void connect(XBeeAddress64 addr) {
    connections.add(addr);   
  }
  
  XBeeAddress64 getNodeAddress64() {
    return nd.getNodeAddress64();  
  }
}
