class Graph {

  VerletPhysics2D physics;

  ArrayList<Node> nodes;
  ArrayList<Edge> edges; 
  
  ArrayList<Connection> waitlist;
  
  //---------------------------------------------------------------------------------
  Graph() {
    nodes = new ArrayList();
    edges = new ArrayList();
    waitlist = new ArrayList();    
    physics = new VerletPhysics2D();
    physics.setDrag(0.5f);  
  }

  //---------------------------------------------------------------------------------
  void update() {
    physics.update();  
    
    ArrayList<Connection> garbage = new ArrayList();
    
    // check if we need to make connections
    for (Connection c : waitlist) {
      Node n1 = findNode(c.a);
      Node n2 = findNode(c.b);
      
      if (n1 != null && n2 != null) {
        add(new Edge(n1, n2));
        garbage.add(c); 
      }
    }
    
    for (Connection c : garbage) waitlist.remove(c); 
  }
  
  //---------------------------------------------------------------------------------
  void add( Node n ) {
    nodes.add(n);
    physics.addParticle(n);
    // create a negative attraction field aroud this node
    // the last param (jitter) seems necessary
    physics.addBehavior(new AttractionBehavior(n, 100, -2.2f, 0.05));
  }
  
  //---------------------------------------------------------------------------------
  void add(Edge e) {
    // see if we have this edge already
    for (Edge edge : edges) {
      if (edge.sameAs(e)) {
        edge.c++; // this should never exceed 2... 
        return;
      }  
    }
    edges.add(e);
    //physics.addSpring(new VerletMinDistanceSpring2D(e.n1, e.n2, 100, 0.5f));
    physics.addSpring(new VerletSpring2D(e.n1, e.n2, 200, 0.02f));  
  }
  
  //---------------------------------------------------------------------------------
  Node findNode(XBeeAddress64 a) {
    for (Node node : nodes) {
      if (a.equals(node.getAddress())) {      
        return node;
      }
    }  
    return null;
  }

  //---------------------------------------------------------------------------------
  void addConnection(XBeeAddress64 a, XBeeAddress64 b) {
    Connection c = new Connection(a, b); 
    waitlist.add(c);
  }
}

/////////////////////////////////////////////////////////////////////////////////////
class Connection { 
  XBeeAddress64 a;
  XBeeAddress64 b;

  Connection(XBeeAddress64 a, XBeeAddress64 b) {
    this.a = a;
    this.b = b;
  }
}

/////////////////////////////////////////////////////////////////////////////////////
class Edge {
  Node n1;
  Node n2;
 
  int c; 

  Edge(Node n1, Node n2) {
    this.n1 = n1;
    this.n2 = n2;
    c = 1;
  }
  
  boolean sameAs(Edge e) {
    if (e.n1 == n1 && e.n2 == n2) return true;
    if (e.n1 == n2 && e.n2 == n1) return true; 
    return false;   
  }
  
  String toString() {
    return n1 + " <--> " + n2;
  }
}


