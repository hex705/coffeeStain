////////////////////////////////////////////////////////////
// XBee Packet response handlers 
////////////////////////////////////////////////////////////

void readPacket(AtCommandResponse r) {
  String command = r.getCommand();
  println("reading AT response, command " + command);
  if (command.equals("ND")) {
    // response from a node discovery command
    NodeDiscover node = NodeDiscover.parse(r);
    addNode(node);
  }
}
////////////////////////////////////////////////////////////
void readPacket(ZNetExplicitRxResponse r) {
  int clusterId = r.getClusterId().get16BitValue();
  println("reading ZNet packet, cluster id " + hex(clusterId, 4));
  if (clusterId == 0x8031) { // NeighbourTable reply 
    parseNeighbourTableResponse(r);
  }
}

////////////////////////////////////////////////////////////
void readPacket(RemoteAtResponse r) throws IOException {
  String command = r.getCommand();
  println("reading remote AT response, command " + command);
  XBeeAddress64 addr = r.getRemoteAddress64(); 
  // respond to different commands 
  if (command.equals("IS")) {
    // the IO samples are encoded in the response's values() array 
    // but the easiest thing is to let this class to the parsing:
    ZNetRxIoSampleResponse sample =  ZNetRxIoSampleResponse.parseIsSample(r);
    println(sample);    
  }
}

