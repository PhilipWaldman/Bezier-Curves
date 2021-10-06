class ControlPoint {
  PVector pos;
  int size = 10;
  
  ControlPoint(PVector pos) {
    this.pos = pos;
  }
  
  void draw() {
    stroke(255);
    noFill();
    rectMode(CENTER);
    square(pos.x, pos.y, size);
  }
}
