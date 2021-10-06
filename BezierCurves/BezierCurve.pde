class BezierCurve {
  ControlPoint[] cPoints;

  BezierCurve(PVector[] positions) {
    cPoints = new ControlPoint[positions.length];
    
    for (int i=0; i<cPoints.length; i++) {
      cPoints[i] = new ControlPoint(positions[i]);
    }
  }

  void draw() {
    stroke(255);
    for (int i=0; i<cPoints.length-1; i++) {
      line(cPoints[i].pos.x, cPoints[i].pos.y, cPoints[i+1].pos.x, cPoints[i+1].pos.y);
    }

    for (ControlPoint p : cPoints) {
      p.draw();
    }
  }
}
