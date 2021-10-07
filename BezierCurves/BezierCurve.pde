class BezierCurve {
  ControlPoint[] cPoints;

  /**
   * Initializes the {@code BezierCurve}.
   * 
   * @param positions The positions of the {@code ControlPoint}s.
   */
  BezierCurve(PVector[] positions) {
    cPoints = new ControlPoint[positions.length];

    for (int i=0; i<cPoints.length; i++) {
      cPoints[i] = new ControlPoint((int) positions[i].x, (int) positions[i].y);
    }
  }

  /**
   * Moves {@code ControlPoint p} to (x, y).
   * 
   * @param p The {@code ControlPoint} to move.
   * @param x The new x position.
   * @param y The new y position.
   */
  void movePoint(ControlPoint p, int x, int y) {
    p.moveTo(x, y);
  }

  /**
   * Returns the {@code ControlPoint} that the position (x, y) is within the handle square of.
   * If there are multiple {@code ControlPoint}s that satisfy this condition, only the first one in the {@code cPoints} array is returned.
   * 
   * @param x The x position of the mouse.
   * @param y The y position of the mouse.
   * @return The {@code ControlPoint} that (x, y) is within.
   */
  ControlPoint pointToMove(int x, int y) {
    for (ControlPoint p : cPoints) {
      if (p.mouseOnPoint(x, y)) {
        return p;
      }
    }
    return null;
  }

  /**
   * Draws all components relevant to the Bezier curve.
   */
  void draw() {
    // Draw control point connecting lines
    stroke(255);
    for (int i=0; i<cPoints.length-1; i++) {
      line(cPoints[i].x(), cPoints[i].y(), cPoints[i+1].x(), cPoints[i+1].y());
    }

    // Draw control point handles
    for (ControlPoint p : cPoints) {
      p.draw();
    }
  }
}
