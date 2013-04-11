void readPacket(AtCommandResponse r) {
  println("reading AT response");
  String command = r.getCommand();
  if (command.equals("ND")) {
    // response from a node discovery command
    NodeDiscover node = NodeDiscover.parse(r);
    addNode(node);
  }
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
void readPacket(RemoteAtResponse r) {
  println("reading remote AT response");
  String command = r.getCommand();
  XBeeAddress64 addr = r.getRemoteAddress64(); 
  // respond to different commands 
  if (command.equals("IS")) {
    // the IO samples are encoded in the response's values() array 
    // but the easiest thing is to let this class to the parsing:
    try {
      ZNetRxIoSampleResponse sample =  ZNetRxIoSampleResponse.parseIsSample(r);
      println(sample);
    }
    catch( IOException e ) {
      e.printStackTrace();
    }
  }
}

