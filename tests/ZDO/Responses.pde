void readPacket(AtCommandResponse r) {
  println("reading AT response");
  String command = r.getCommand();
  if (command.equals("ND")) {
    // response from a node discovery command
    NodeDiscover node = NodeDiscover.parse(r);
    addNode(node);
  }
  // could add the capture routine for local node here ??
  
  
  
}
////////////////////////////////////////////////////////////
void readPacket(ZNetExplicitRxResponse r) {
  println("reading ZNet packet");
  int clusterId = r.getClusterId().get16BitValue();
  println("cluster id " + hex(clusterId, 4));
  if (clusterId == 0x8031) { // NeighbourTable reply 
    parseNeighbourTableResponse(r); 
  } 
}

////////////////////////////////////////////////////////////



