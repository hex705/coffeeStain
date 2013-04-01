void addNode(NodeDiscover nd) {
  if (getNode(nd.getNodeAddress64()) != null) return; // ignore this if we have this node already
  
  println("adding a node ******");
  network.add(new Node(nd)); //arrayList of nodes
    
  // we found a new node, display it
  println("New node: " + nd.getNodeIdentifier() + " - " + nd.getNodeAddress64());  

  // initiate building the neighbour table
  ZNetExplicitTxRequest zdo = buildNeighbourTableRequest(nd.getNodeAddress64(), 0, 0); 
  try {
    println("looking for table");
    // maybe consider having a global "outgoing" message queue as well? 
    xbee.sendAsynchronous(zdo);
  }
  catch (Exception e) { 
    println("ZNET FAIL");
    e.printStackTrace();
  }
}

///////////////////////////////////////////////////////////////////////////////////////
// Finds the node object with this address  in the 'network' array
Node getNode(XBeeAddress64 addr) {
  for (Node node : network) {
    if (addr.equals(node.getNodeAddress64())) {      
      return node;
    }
  }  
  return null;
}

///////////////////////////////////////////////////////////////////////////////////////
// Create negative attractions between nodes that aren't neighbours
void updateRepulsions() {
  println("Updating repulsions");    
  for (Node n1 : network) {
    for (Node n2 : network) {
      if (n1 != n2) {        
        if (n1.hasNeighbour(n2) == false && n2.hasNeighbour(n1) == false) {
          physics.makeAttraction(n1.p, n2.p, 0.2, -2 * n1.LINK_LENGTH);
          println("added repulstion " + n1 + ", " + n2);
        }
      }
    }
  }
}

