BezierCurve curve;
ControlPoint pointToMove;

void setup() {
  fullScreen();

  // Initialize control points to random positions on the screen
  PVector[] positions = new PVector[4];
  for (int i=0; i<positions.length; i++) {
    positions[i] = new PVector((int) random(width), (int) random(height));
  }

  curve = new BezierCurve(positions);
}

void draw() {
  background(0);

  curve.draw();
}

void mouseDragged() {
  if (pointToMove != null) {
    curve.movePoint(pointToMove, mouseX, mouseY);
  }
}

void mousePressed() {
  pointToMove = curve.pointToMove(mouseX, mouseY);
}
