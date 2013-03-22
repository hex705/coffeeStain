void readPacket(AtCommandResponse r) {
  String command = r.getCommand();
  if (command.equals("ND")) {
    // response from a node discovery command
    NodeDiscover node = NodeDiscover.parse(r);
    addNode(node);
  }
}
////////////////////////////////////////////////////////////
void readPacket(ZNetExplicitRxResponse r) {
  int clusterId = r.getClusterId().get16BitValue();
  println("cluster id " + hex(clusterId, 4));
  if (clusterId == 0x8031) { // NeighbourTable reply 
    parseNeighbourTableResponse(r); 
  } 
}

////////////////////////////////////////////////////////////



