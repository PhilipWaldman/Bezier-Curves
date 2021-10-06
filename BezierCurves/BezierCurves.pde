BezierCurve curve;

void setup() {
  fullScreen();

  PVector[] positions = new PVector[4];
  for (int i=0; i<positions.length; i++) {
    positions[i] = new PVector(random(width), random(height));
  }

  curve = new BezierCurve(positions);
}

void draw() {
  background(0);

  curve.draw();
}
