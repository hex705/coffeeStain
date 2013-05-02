///////////////////////////////////////////////////////////////////////////////////////
void addNode(NodeDiscover nd) {
  if (graph.findNode(nd.getNodeAddress64()) != null) return; // ignore this if we have this node already
  
  Node n = new Node(nd);    
  graph.add(n); 
  camera.auto();
  
  // initiate building the neighbour table
  ZNetExplicitTxRequest zdo = buildNeighbourTableRequest(nd.getNodeAddress64(), 0, 0); 
  try {
    // maybe consider having a global "outgoing" message queue as well? 
    xbee.sendAsynchronous(zdo);
  }
  catch (Exception e) { 
    e.printStackTrace();
  }
}
 

