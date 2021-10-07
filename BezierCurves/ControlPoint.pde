class ControlPoint {
  PVector pos;
  static final int size = 10;

  /**
   * Initializes a contol point at (x, y).
   * 
   * @param x The x position of the {@code ControlPoint}.
   * @param y The y position of the {@code ControlPoint}.
   */
  ControlPoint(int x, int y) {
    pos = new PVector(x, y);
  }

  /**
   * Checks is the position (x, y) is within the control point handle square.
   * 
   * @param x The x position of the mouse.
   * @param y The y position of the mouse.
   * @return Whether the point (x, y) is within the control point square.
   */
  boolean mouseOnPoint(int x, int y) {
    return pos.x - size / 2 < x && 
      pos.x + size / 2 > x && 
      pos.y - size / 2 < y && 
      pos.y + size / 2 > y;
  }

  /**
   * Moves the {@code ControlPoint} to a new (x, y).
   * 
   * @param x The new x position.
   * @param y The new y position.
   */
  void moveTo(int x, int y) {
    pos.x = x;
    pos.y = y;
  }

  /**
   * Returns the x position of the {@code ControlPoint}.
   *
   * @return The x position of the {@code ControlPoint}.
   */
  int x() {
    return (int) pos.x;
  }

  /**
   * Returns the y position of the {@code ControlPoint}.
   *
   * @return The y position of the {@code ControlPoint}.
   */
  int y() {
    return (int) pos.y;
  }

  /**
   * Draws the control point as a square centered at {@code (pos.x, pos.y)} with side lengths of {@code size}.
   */
  void draw() {
    stroke(255);
    noFill();
    rectMode(CENTER);
    square(pos.x, pos.y, size);
  }
}
