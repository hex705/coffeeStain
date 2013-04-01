//------------------------------------------------------------------
// Builds a ZDO request for Neighbour Tables  

ZNetExplicitTxRequest buildNeighbourTableRequest(XBeeAddress64 addr, int index, int messageCount) {
  DoubleByte clusterId = new DoubleByte(0x0, 0x31);  // neighbor table request message is 0x0031
  int frameId = 0x0;
  int[] payload = {
    messageCount, index
  }; 
  ZNetExplicitTxRequest zdo; 
  zdo = new ZNetExplicitTxRequest(frameId, 
  addr, // addr64
  XBeeAddress16.ZNET_BROADCAST, // addr16
  0, // broadcast radius
  ZNetTxRequest.Option.UNICAST, //option
  payload, // payload
  0x0, // source endpoint
  0x0, // dest endpoint
  clusterId, 
  ZNetExplicitTxRequest.zdoProfileId);
  return zdo;
}




///////////////////////////////////////////////////////////////////////////////////////
void parseNeighbourTableResponse(ZNetExplicitRxResponse r) {
  XBeeAddress64 from = r.getRemoteAddress64();
  Node fromNode = getNode(from);
  println("Neighbour Table Data received from: " + from);
  int[] d = r.getData();
  int msgCount = d[0];
  int total = d[2];
  int start = d[3];
  int count = d[4];
  int offset = 5;
  for (int entry=0; entry < count; entry++) { 
    int i = offset + entry*22;
    XBeeAddress64 panId = new XBeeAddress64(d[i+7], d[i+6], d[i+5], d[i+4], d[i+3], d[i+2], d[i+1], d[i]);
    println(panId);
    i += 8;
    XBeeAddress64 addr = new XBeeAddress64(d[i+7], d[i+6], d[i+5], d[i+4], d[i+3], d[i+2], d[i+1], d[i]);
    i += 8; 
    XBeeAddress16 addr16 = new XBeeAddress16(d[i+1], d[i]);
    println("[" + hex(addr16.get16BitValue(), 4) + "] " + addr);
    i += 2;     
    int packed = d[i++]; // the next byte contains packed info on device type, receiver on and relationship 
    println(binary(packed, 8)); 
    int permit = d[i++]; // this next byte contains permit joining info
    int depth = d[i++]; // depth in the tree, depth of 0 = coordinator 
    int lqi = d[i]; // link quality estimation (255 == best) 
    println(lqi); 
    
    fromNode.connect(addr); // build a physics string between two addresses
  }
  
  if ( start+count < total ) {
     // we still have neighbours to discover 
     ZNetExplicitTxRequest zdo = buildNeighbourTableRequest(r.getRemoteAddress64(), start+count, 0); 
     try { 
       xbee.sendAsynchronous(zdo);  
     }
     catch (Exception e) {
       e.printStackTrace();   
     }
  }
}

