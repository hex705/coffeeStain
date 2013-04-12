class Graph {

  float MIN_NOTE_DISTANCE = 80;
  float MIN_EDGE_LENGTH = 120;
  float MAX_EDGE_LENGTH = 400; 

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
        add(new Edge(n1, n2, c.quality));
        garbage.add(c);
      }
    }

    for (Connection c : garbage) waitlist.remove(c); 

    // check if nodes overlap with edges
    // if so, try to move them apart
    for (Node n : nodes) {
      for (Edge e : edges) {
        if (e.n1 != n && e.n2 != n) {
          Vec2D closestPoint = e.getClosestPointTo(n);
          Vec2D distance = n.sub(closestPoint);
          if (distance.magnitude() < n.diameter*0.6) {
          
          stroke(255, 0, 0);
          line(closestPoint.x, closestPoint.y, n.x, n.y);
            n.addForce(distance.normalize());
          }
        }
      }
    }
  }

  //---------------------------------------------------------------------------------
  void add( Node n ) {
    nodes.add(n);
    physics.addParticle(n);
    // create a negative attraction field aroud this node
    // the last param (jitter) seems necessary
    physics.addBehavior(new toxi.physics2d.behaviors.AttractionBehavior(n, n.diameter*1.2, -2.2f, 0.05));
  }

  //---------------------------------------------------------------------------------
  void add(Edge e) {
    // see if we have this edge already
    for (Edge edge : edges) {
      if (edge.sameAs(e)) {
        edge.quality = (edge.quality + e.quality) / 2; // average the link quality 
        edge.count++; // this should never exceed 2...  
        edge.spring.setRestLength(map(edge.quality, 0, 255, MAX_EDGE_LENGTH, MIN_EDGE_LENGTH));
        return;
      }
    }
    edges.add(e);

    float springLength = map(e.quality, 0, 255, MAX_EDGE_LENGTH, MIN_EDGE_LENGTH); 

    //VerletSpring2D s = new VerletMinDistanceSpring2D(e.n1, e.n2, springLength, 0.02f);
    VerletSpring2D s = new VerletSpring2D(e.n1, e.n2, springLength, 0.02f);
    // Save the spring on the edge itself, so that we can refer to it later 
    e.spring = s;
    physics.addSpring(s);
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
  void addConnection(XBeeAddress64 a, XBeeAddress64 b, int quality) {
    if (random(1) < 0.7) return;
    Connection c = new Connection(a, b, quality); 
    waitlist.add(c);
  }
}

/////////////////////////////////////////////////////////////////////////////////////
class Connection { 
  XBeeAddress64 a;
  XBeeAddress64 b;
  int quality;

  Connection(XBeeAddress64 a, XBeeAddress64 b, int quality) {
    this.a = a;
    this.b = b;
    this.quality = quality;
  }
}

/////////////////////////////////////////////////////////////////////////////////////
class Edge {

  Node n1;
  Node n2;
  VerletSpring2D spring;

  int quality;
  int count; 

  Edge(Node n1, Node n2, int quality) {
    this.n1 = n1;
    this.n2 = n2;
    count = 1;
    this.quality = quality;
  }

  boolean sameAs(Edge e) {
    if (e.n1 == n1 && e.n2 == n2) return true;
    if (e.n1 == n2 && e.n2 == n1) return true; 
    return false;
  }

  String toString() {
    return n1 + " <--> " + n2;
  }

  Vec2D getMidPoint() {
    return n1.interpolateTo(n2, 0.5);
  }

  Vec2D getClosestPointTo(Vec2D v) {
    Line2D l = new Line2D(n1, n2); 
    return l.closestPointTo(v);
  }
}

