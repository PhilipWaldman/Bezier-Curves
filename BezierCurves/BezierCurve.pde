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
      cPoints[i] = new ControlPoint(positions[i]);
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
   * De Casteljau's algorithm.
   */
  PVector deCasteljausAlgorithm(float t) {
    return deCasteljausAlgorithm(cPoints, t);
  }

  /**
   * Recursive De Casteljau's algorithm.
   */
  PVector deCasteljausAlgorithm(ControlPoint[] points, float t) {
    if (points.length == 1) {
      return points[0].pos;
    }

    ControlPoint[] newPoints = new ControlPoint[points.length - 1];
    for (int i=0; i<newPoints.length; i++) {
      newPoints[i] = lerp(points[i], points[i+1], t);
    }
    return deCasteljausAlgorithm(newPoints, t);
  }

  /**
   * (1 - t) * p0 + t * p1
   *
   * @param cp0
   * @param cp1
   * @param t
   * @return 
   */
  ControlPoint lerp(ControlPoint cp0, ControlPoint cp1, float t) {
    PVector p0 = cp0.pos.copy();
    PVector p1 = cp1.pos.copy();
    PVector p = p0.mult(1 - t).add(p1.mult(t));
    return new ControlPoint(p);
  }

  /**
   * Draws all components relevant to the Bezier curve.
   */
  void draw() {
    drawControlPoints(cPoints);
    drawCurve();
  }

  void drawCurve() {
    stroke(255);
    strokeWeight(5);
    float dt = 0.001;
    for (float t=0; t<=1; t+=dt) {
      PVector p = deCasteljausAlgorithm(t);
      point(p.x, p.y);
    }
  }

  /**
   *
   *
   * @param points
   */
  void drawControlPoints(ControlPoint[] points) {
    // Draw control point connecting lines
    stroke(255);
    strokeWeight(1);
    for (int i=0; i<points.length-1; i++) {
      line(points[i].x(), points[i].y(), points[i+1].x(), points[i+1].y());
    }

    // Draw control point handles
    for (ControlPoint p : points) {
      p.draw();
    }
  }
}
