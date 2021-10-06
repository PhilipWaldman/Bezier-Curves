class ControlPoint {
  PVector pos;
  int size = 10;

  ControlPoint(PVector pos) {
    this.pos = pos;
  }

  boolean mouseOnPoint(int x, int y) {
    return pos.x - size / 2 < x && 
      pos.x + size / 2 > x && 
      pos.y - size / 2 < y && 
      pos.y + size / 2 > y;
  }

  void move(int x, int y) {
    pos.x = x;
    pos.y = y;
  }

  void draw() {
    stroke(255);
    noFill();
    rectMode(CENTER);
    square(pos.x, pos.y, size);
  }
}
