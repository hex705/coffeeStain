class Camera {
  float tx;
  float ty;
  float scale;

  float minX, minY, maxX, maxY;
  
  //--------------------------------------------------------------------------------
  Camera() {
    tx = ty = 0;
    scale = 1;  
  }  

  //---------------------------------------------------------------------------------
  void apply() {
    translate(width/2, height/2);
    scale(scale);
    translate(tx, ty);
  }

  //---------------------------------------------------------------------------------
  void zoomBy(float delta) {
    scale += delta;  
    scale = constrain(scale, 0, 2);
  }

  //---------------------------------------------------------------------------------
  void move() {
    tx += (mouseX-pmouseX); 
    ty += (mouseY-pmouseY);
  }

  //---------------------------------------------------------------------------------
  // Calculate the camera parameters so that the whole network will be 
  // visible on screen 
  void auto() {
    minY = minX = 999999;
    maxY = maxX = -999999;
    for (Node n : network) {
      minX = min(n.p.position().x(), minX);
      minY = min(n.p.position().y(), minY);
      maxX = max(n.p.position().x(), maxX);
      maxY = max(n.p.position().y(), maxY);
    }

    // center of mass
    float centerX = minX + (maxX - minX)/2;
    float centerY = minY + (maxY - minY)/2;

    tx = -centerX;
    ty = -centerY;

    // calculate optimal scale
    if (maxX-minX != 0) scale = 0.8 * width/(maxX-minX);
    scale = min(scale, 1);
    //scale = map(mouseX, 0, width, 0.1, 2);
  }
  
  //---------------------------------------------------------------------------------
  // Get the location of the mouse, in "camera coordinates" 
  PVector mouse() {
    float mx = (mouseX - width/2) / scale - tx;
    float my = (mouseY - height/2) / scale - ty;  
    return new PVector(mx, my);
  }
}

