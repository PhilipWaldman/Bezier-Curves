ControlPoint[] cPoints = new ControlPoint[4];

void setup() {
  fullScreen();
  for (int i=0; i<cPoints.length; i++) {
    cPoints[i] = new ControlPoint(new PVector(random(width), random(height)));
  }
}

void draw() {
  background(0);
  
  stroke(255);
  for (int i=0; i<cPoints.length-1; i++) {
    line(cPoints[i].pos.x, cPoints[i].pos.y, cPoints[i+1].pos.x, cPoints[i+1].pos.y);
  }
  
  for (ControlPoint p : cPoints) {
    p.draw();
  }
}
