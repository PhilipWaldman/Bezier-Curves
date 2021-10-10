import java.util.Map;
import java.util.Set;

class BezierCurve {
  ControlPoint[] cPoints;
  PVector[] curvePoints;
  boolean updateCurve = true;
  boolean drawAlgo = false;
  HashMap<Float, Float> lut = new HashMap<Float, Float>(); // <t-value, distance to t>
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
   * Runs de Casteljau's algorithm to find a point on the curve.
   *
   * @param t The t-value to calculate the point on the curve at. Assumes t is in range [0, 1].
   * @return The point on the curve.
   */
  PVector deCasteljausAlgorithm(float t) {
    return deCasteljausAlgorithm(t, false);
  }

  /**
   * Runs de Casteljau's algorithm to find a point on the curve.
   *
   * @param t The t-value to calculate the point on the curve at. Assumes t is in range [0, 1].
   * @param drawRecursion Whether to draw the recursive steps.
   * @return The point on the curve.
   */
  PVector deCasteljausAlgorithm(float t, boolean drawRecursion) {
    return deCasteljausAlgorithm(cPoints, t, drawRecursion);
  }

  /**
   * Runs de Casteljau's algorithm to find a point on the curve.
   *
   * @param points The {@code ControlPoint}s of the curve.
   * @param t The t-value to calculate the point on the curve at. Assumes t is in range [0, 1].
   * @param drawRecursion Whether to draw the recursive steps.
   * @return The point on the curve.
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
   * Preforms linear interpolation on two {@code ControlPoint}s.
   *
   * p = (1 - t) * p0 + t * p1
   *
   * @param cp0 The {@code ControlPoint} to interpolate from.
   * @param cp1 The {@code ControlPoint} to interpolate to.
   * @param t How far between the two points should be interpolated. Assumes t is in range [0, 1].
   * @return The interpolated {@code ControlPoint}.
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
    if (drawAlgo) {
      float p = 20000;
      float m = millis();
      float t = 2 * abs(m / p - floor(m / p + 0.5));
      drawDeCasteljau(t);
    } else {
      drawControlPoints(cPoints);
    }
  }

  /**
   * Updates the values of the Bezier curve if needed and draws it.
   */
  void drawCurve() {
    strokeWeight(2);

    if (updateCurve) {
      curvePoints = new PVector[n_segs+1];
      PVector prev_point = deCasteljausAlgorithm(0);
      float dist = 0;
      for (int i=0; i<=n_segs; i++) {
        // Generate point on curve by t-value.
        float t = 1.0 / n_segs * i;
        PVector p = deCasteljausAlgorithm(t);
        curvePoints[i] = p;

        // Put dist to point in look up table.
        dist += prev_point.dist(p);
        lut.put(t, dist);
        prev_point = p;
      }

      // To prevent the interpolated points to not be generated in order because sets are not ordered.
      Map.Entry<Float, Float>[] entryArr = preprocessEntrySet(lut.entrySet());

      // Interpolate lut to get evenly spaced points.
      interpolatedPoints = new PVector[n_segs+1];
      for (int i=0; i<=n_segs; i++) {
        float d = dist * i / n_segs;
        Map.Entry lower = null;

        for (Map.Entry tDist : entryArr) {
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
   * Converts a {@code Set<Map.Entry<Float, Float>>} to a {@code Map.Entry<Float, Float>[]} sorted by t-value (the key).
   *
   * This is to fix a bug where is the Set was directly used not of line segments of the curve would be drawn in the correct order which led to line segments making big jumps.
   *
   * @param entrySet The entrySet to convert and sort.
   * @return An entryArray sorted by t-value (the key).
   */
  Map.Entry<Float, Float>[] preprocessEntrySet(Set<Map.Entry<Float, Float>> entrySet) {
    Map.Entry<Float, Float>[] entryArr = entrySet.toArray(new Map.Entry[0]);

    // Insertion sort http://rosettacode.org/wiki/Sorting_algorithms/Insertion_sort#Java
    for (int i = 1; i < entryArr.length; i++) {
      Map.Entry<Float, Float> value = entryArr[i];
      int j = i - 1;
      while (j >= 0 && entryArr[j].getKey() > value.getKey()) {
        entryArr[j + 1] = entryArr[j];
        j = j - 1;
      }
      entryArr[j + 1] = value;
    }

    return entryArr;
  }

  /**
   * Draws the control points in white.
   *
   * @param points The points to draw.
   */
  void drawControlPoints(ControlPoint[] points) {
    drawControlPoints(points, 255, 255, 255);
  }

  /**
   * Draws the control points.
   *
   * @param points The points to draw.
   * @param r The red value [0, 255].
   * @param g The green value [0, 255].
   * @param b The blue value [0, 255].
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
   * Draws the resursive steps de Casteljau's algorithm does.
   *
   * @param t The t-value to draw the recursion at.
   */
  void drawDeCasteljau(float t) {
    deCasteljausAlgorithm(t, true);
  }
}
