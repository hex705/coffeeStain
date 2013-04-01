void addNode(NodeDiscover nd) {
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
  catch (Exception e)  { 
    println("ZNET FAIL");
    e.printStackTrace();
  }   
}

///////////////////////////////////////////////////////////////////////////////////////
// Finds the node object with this address 
Node getNode(XBeeAddress64 addr) {
  for (Node node : network) {
    if (addr.equals(node.getNodeAddress64())) {
      println("yes");
      return node;
    }    
  }  
  return null;
}


