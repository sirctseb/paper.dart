/*
 * Paper.js
 *
 * This file is part of Paper.js, a JavaScript Vector Graphics Library,
 * based on Scriptographer.org and designed to be largely API compatible.
 * http://paperjs.org/
 * http://scriptographer.org/
 *
 * Copyright (c) 2011, Juerg Lehni & Jonathan Puckey
 * http://lehni.org/ & http://jonathanpuckey.com/
 *
 * Distributed under the MIT license. See LICENSE file for details.
 *
 * All rights reserved.
 */

// An Algorithm for Automatically Fitting Digitized Curves
// by Philip J. Schneider
// from "Graphics Gems", Academic Press, 1990
// Modifications and optimisations of original algorithm by Juerg Lehni.

class PathFitter {
  
  List<Point> points = [];
  List<Segment> segments;
  double error;

  PathFitter(Path path, double this.error) {
    var segments = path._segments,
      prev;
    // Copy over points from path and filter out adjacent duplicates.
    for (var i = 0, l = segments.length; i < l; i++) {
      var point = segments[i].point.clone();
      if (prev == null || !prev.equals(point)) {
        points.add(point);
        prev = point;
      }
    }
  }

  List<Segment> fit() {
    segments = [new Segment(points[0])];
    fitCubic(0, points.length - 1,
        // Left Tangent
        points[1].subtract(points[0]).normalize(),
        // Right Tangent
        points[points.length - 2].subtract(
          points[points.length - 1]).normalize());
    return segments;
  }

  // Fit a Bezier curve to a (sub)set of digitized points
  void fitCubic(first, last, tan1, tan2) {
    //  Use heuristic if region only has two points in it
    if (last - first == 1) {
      var pt1 = points[first],
        pt2 = points[last],
        dist = pt1.getDistance(pt2) / 3;
      addCurve([pt1, pt1.add(tan1.normalize(dist)),
          pt2.add(tan2.normalize(dist)), pt2]);
      return;
    }
    // Parameterize points, and attempt to fit curve
    var uPrime = chordLengthParameterize(first, last),
      maxError = max(error, error * error),
      // TODO i'm pretty sure this should not be redeclared here
      /*error,*/
      split;
    // Try 4 iterations
    for (var i = 0; i <= 4; i++) {
      var curve = generateBezier(first, last, uPrime, tan1, tan2);
      //  Find max deviation of points to fitted curve
      var max = findMaxError(first, last, curve, uPrime);
      if (max["error"] < error) {
        addCurve(curve);
        return;
      }
      split = max["index"];
      // If error not too large, try reparameterization and iteration
      if (max["error"] >= maxError)
        break;
      reparameterize(first, last, uPrime, curve);
      maxError = max["error"];
    }
    // Fitting failed -- split at max error point and fit recursively
    var V1 = points[split - 1].subtract(points[split]),
      V2 = points[split].subtract(points[split + 1]),
      tanCenter = V1.add(V2).divide(2).normalize();
    fitCubic(first, split, tan1, tanCenter);
    fitCubic(split, last, tanCenter.negate(), tan2);
  }

  void addCurve(curve) {
    var prev = segments[segments.length - 1];
    prev.setHandleOut(curve[1].subtract(curve[0]));
    segments.add(
        new Segment(curve[3], curve[2].subtract(curve[3])));
  }

  // Use least-squares method to find Bezier control points for region.
  List<Point> generateBezier(first, last, uPrime, tan1, tan2) {
    var epsilon = Numerical.EPSILON,
      pt1 = points[first],
      pt2 = points[last],
      // Create the C and X matrices
       C = [[0, 0], [0, 0]],
      X = [0, 0];

    for (var i = 0, l = last - first + 1; i < l; i++) {
      var u = uPrime[i],
        t = 1 - u,
        b = 3 * u * t,
        b0 = t * t * t,
        b1 = b * t,
        b2 = b * u,
        b3 = u * u * u,
        a1 = tan1.normalize(b1),
        a2 = tan2.normalize(b2),
        tmp = points[first + i]
          .subtract(pt1.multiply(b0 + b1))
          .subtract(pt2.multiply(b2 + b3));
      C[0][0] += a1.dot(a1);
      C[0][1] += a1.dot(a2);
      // C[1][0] += a1.dot(a2);
      C[1][0] = C[0][1];
      C[1][1] += a2.dot(a2);
      X[0] += a1.dot(tmp);
      X[1] += a2.dot(tmp);
    }

    // Compute the determinants of C and X
    var detC0C1 = C[0][0] * C[1][1] - C[1][0] * C[0][1],
      alpha1, alpha2;
    if (detC0C1.abs() > epsilon) {
      // Kramer's rule
      var detC0X  = C[0][0] * X[1]    - C[1][0] * X[0],
        detXC1  = X[0]    * C[1][1] - X[1]    * C[0][1];
      // Derive alpha values
      alpha1 = detXC1 / detC0C1;
      alpha2 = detC0X / detC0C1;
    } else {
      // Matrix is under-determined, try assuming alpha1 == alpha2
      var c0 = C[0][0] + C[0][1],
        c1 = C[1][0] + C[1][1];
      if (c0.abs() > epsilon) {
        alpha1 = alpha2 = X[0] / c0;
      } else if (c1.abs() > epsilon) {
        alpha1 = alpha2 = X[1] / c1;
      } else {
        // Handle below
        alpha1 = alpha2 = 0;
      }
    }

    // If alpha negative, use the Wu/Barsky heuristic (see text)
    // (if alpha is 0, you get coincident control points that lead to
    // divide by zero in any subsequent NewtonRaphsonRootFind() call.
    var segLength = pt2.getDistance(pt1);
    epsilon *= segLength;
    if (alpha1 < epsilon || alpha2 < epsilon) {
      // fall back on standard (probably inaccurate) formula,
      // and subdivide further if needed.
      alpha1 = alpha2 = segLength / 3;
    }

    // First and last control points of the Bezier curve are
    // positioned exactly at the first and last data points
    // Control points 1 and 2 are positioned an alpha distance out
    // on the tangent vectors, left and right, respectively
    return [pt1, pt1.add(tan1.normalize(alpha1)),
        pt2.add(tan2.normalize(alpha2)), pt2];
  }

  // Given set of points and their parameterization, try to find
  // a better parameterization.
  void reparameterize(first, last, u, curve) {
    for (var i = first; i <= last; i++) {
      u[i - first] = findRoot(curve, points[i], u[i - first]);
    }
  }

  // Use Newton-Raphson iteration to find better root.
  double findRoot(curve, point, u) {
    var curve1 = [],
      curve2 = [];
    // Generate control vertices for Q'
    for (var i = 0; i <= 2; i++) {
      curve1[i] = curve[i + 1].subtract(curve[i]).multiply(3);
    }
    // Generate control vertices for Q''
    for (var i = 0; i <= 1; i++) {
      curve2[i] = curve1[i + 1].subtract(curve1[i]).multiply(2);
    }
    // Compute Q(u), Q'(u) and Q''(u)
    var pt = evaluate(3, curve, u),
       pt1 = evaluate(2, curve1, u),
       pt2 = evaluate(1, curve2, u),
       diff = pt.subtract(point),
      df = pt1.dot(pt1) + diff.dot(pt2);
    // Compute f(u) / f'(u)
    if (df.abs() < Numerical.TOLERANCE)
      return u;
    // u = u - f(u) / f'(u)
    return u - diff.dot(pt1) / df;
  }

  // Evaluate a Bezier curve at a particular parameter value
  Point evaluate(degree, curve, t) {
    // Copy array
    var tmp = curve.slice();
    // Triangle computation
    for (var i = 1; i <= degree; i++) {
      for (var j = 0; j <= degree - i; j++) {
        tmp[j] = tmp[j].multiply(1 - t).add(tmp[j + 1].multiply(t));
      }
    }
    return tmp[0];
  }

  // Assign parameter values to digitized points
  // using relative distances between points.
  List<double> chordLengthParameterize(first, last) {
    var u = [0];
    for (var i = first + 1; i <= last; i++) {
      u[i - first] = u[i - first - 1]
          + points[i].getDistance(points[i - 1]);
    }
    for (var i = 1, m = last - first; i <= m; i++) {
      u[i] /= u[m];
    }
    return u;
  }

  // Find the maximum squared distance of digitized points to fitted curve.
  Map findMaxError(first, last, curve, u) {
    var index = ((last - first + 1) / 2).floor(),
      maxDist = 0;
    for (var i = first + 1; i < last; i++) {
      var P = evaluate(3, curve, u[i - first]);
      var v = P.subtract(points[i]);
      var dist = v.x * v.x + v.y * v.y; // squared
      if (dist >= maxDist) {
        maxDist = dist;
        index = i;
      }
    }
    return {
      "error": maxDist,
      "index": index
    };
  }
}
