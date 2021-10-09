import java.util.Map;

class BezierCurve {
  ControlPoint[] cPoints;
  PVector[] curvePoints;
  boolean updateCurve = true;
  boolean drawAlgo = true;
  HashMap<Float, Float> lut = new HashMap<Float, Float>();
  PVector[] interpolatedPoints;
  final int n_segs = 1000;

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
    updateCurve = true;
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
   *
   * @param t
   * @return 
   */
  PVector deCasteljausAlgorithm(float t) {
    return deCasteljausAlgorithm(t, false);
  }

  /**
   * De Casteljau's algorithm.
   *
   * @param t
   * @param drawRecursion
   * @return 
   */
  PVector deCasteljausAlgorithm(float t, boolean drawRecursion) {
    return deCasteljausAlgorithm(cPoints, t, drawRecursion);
  }

  /**
   * Recursive De Casteljau's algorithm.
   *
   * @param points
   * @param t
   * @param drawRecursion
   * @return 
   */
  PVector deCasteljausAlgorithm(ControlPoint[] points, float t, boolean drawRecursion) {
    if (points.length == 1) {
      if (drawRecursion) {
        drawControlPoints(points);
      }
      return points[0].pos;
    }

    if (drawRecursion) {
      drawControlPoints(points, 
        points.length != 4 ? 255 : 0, 
        points.length != 3 ? 255 : 0, 
        points.length != 2 ? 255 : 0);
    }

    ControlPoint[] newPoints = new ControlPoint[points.length - 1];
    for (int i=0; i<newPoints.length; i++) {
      newPoints[i] = lerp(points[i], points[i+1], t);
    }

    return deCasteljausAlgorithm(newPoints, t, drawRecursion);
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
    drawCurve();
    float p = 10000;
    if (drawAlgo) {
      float m = millis();
      float t = 2 * abs(m / p - floor(m / p + 0.5));
      drawDeCasteljau(t);
    } else {
      drawControlPoints(cPoints);
    }
  }

  /**
   *
   */
  void drawCurve() {
    strokeWeight(2);

    if (updateCurve) {
      curvePoints = new PVector[n_segs+1];
      PVector prev_point = deCasteljausAlgorithm(0);
      float dist = 0;
      for (int i=0; i<=n_segs; i++) {
        // Generate point on curve by t value.
        float t = 1.0 / n_segs * i;
        PVector p = deCasteljausAlgorithm(t);
        curvePoints[i] = p;

        // Put dist to point in look up table.
        dist += prev_point.dist(p);
        lut.put(t, dist);
        prev_point = p;
      }

      // Interpolate lut to get evenly spaced points.
      interpolatedPoints = new PVector[n_segs+1];
      for (int i=0; i<=n_segs; i++) {
        float d = dist * i / n_segs;
        Map.Entry lower = null;
        for (Map.Entry tDist : lut.entrySet()) {
          if (d == (float) tDist.getValue()) {
            interpolatedPoints[i] = deCasteljausAlgorithm((float) tDist.getKey());
            break;
          } else if (d > (float) tDist.getValue()) {
            lower = tDist;
          } else if (lower != null) {
            float t = map(d, (float) lower.getValue(), (float) tDist.getValue(), (float) lower.getKey(), (float) tDist.getKey());
            interpolatedPoints[i] = deCasteljausAlgorithm(t);
            break;
          }
        }
      }

      updateCurve = false;
    }

    // Actually draw the line segments of the curve.
    for (int i=0; i<interpolatedPoints.length-1; i++) {
      float t = 1.0 / interpolatedPoints.length * i;
      PVector p0 = interpolatedPoints[i];
      PVector p1 = interpolatedPoints[i + 1];
      stroke(255 * (1 - t), 0, 255 * t);
      if (p0 != null && p1 != null) {
        line(p0.x, p0.y, p1.x, p1.y);
      }
    }
  }

  /**
   *
   *
   * @param points
   */
  void drawControlPoints(ControlPoint[] points) {
    drawControlPoints(points, 255, 255, 255);
  }

  /**
   *
   *
   * @param points
   * @param r
   * @param g
   * @param b
   */
  void drawControlPoints(ControlPoint[] points, int r, int g, int b) {
    // Draw control point connecting lines
    stroke(r, g, b);
    strokeWeight(1);
    for (int i=0; i<points.length-1; i++) {
      line(points[i].x(), points[i].y(), points[i+1].x(), points[i+1].y());
    }

    // Draw control point handles
    for (ControlPoint p : points) {
      p.draw();
    }
  }

  /**
   *
   *
   * @param t
   */
  void drawDeCasteljau(float t) {
    deCasteljausAlgorithm(t, true);
  }
}
