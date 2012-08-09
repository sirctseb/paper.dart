/*
 * Paper.dart
 *
 * This file is part of Paper.dart, a Dart port of Paper.js, a Javascript Vector Graphics Library,
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

/**
 * @name Line
 *
 * @class The Line object represents..
 */
class Line /** @lends Line# */ {

  // DOCS: document Line class and constructor
  /**
  * Creates a Line object.
  *
  * @param {Point} point1
  * @param {Point} point2
  * @param {Boolean} [infinite=true]
  */
  Line(/*Point*/ point1, /*Point*/ point2, [bool infinite]) {
    _point1 = Point.read(point1);
    point2 = Point.read(point2);
    if(infinite == null) {
      _infinite = true;
      _vector = point2;
    } else {
      _infinite = infinite;
      _vector = point2 - _point1;
    }
  }

  Line.fromVector(Point point, Point vector) {
    _point1 = point;
    _vector = vector;
    _infinite = true;
  }


  Point _point1;
  Point _vector;
  bool _infinite;

  /**
   * The starting point of the line
   *
   * @name Line#point
   * @type Point
   */
   Point get point() => _point1;

  /**
   * The vector of the line
   *
   * @name Line#vector
   * @type Point
   */
   Point get vector() => _vector;

  /**
   * Specifies whether the line extends infinitely
   *
   * @name Line#infinite
   * @type Boolean
   */
   bool get infinite() => _infinite;

  /**
   * @param {Line} line
   * @return {Point} the intersection point of the lines
   */
  Point intersect(Line line) {
    num cross = this.vector.cross(line.vector);
    // Avoid divisions by 0, and errors when getting too close to 0
    if (cross.abs() <= Numerical.EPSILON)
      return null;
    Point v = line.point - this.point;
    num t1 = v.cross(line.vector) / cross;
    num t2 = v.cross(this.vector) / cross;
    // Check the ranges of t parameters if the line is not allowed to
    // extend beyond the definition points.
    return (this.infinite || 0 <= t1 && t1 <= 1)
        && (line.infinite || 0 <= t2 && t2 <= 1)
      ? this.point + (this.vector * t1) : null;
  }

  // DOCS: document Line#getSide(point)
  /**
   * @param {Point} point
   * @return {Number}
   */
  num getSide(Point point) {
    Point v1 = this.vector;
    Point v2 = point - this.point;
    num ccw = v2.cross(v1);
    if (ccw == 0) {
      ccw = v2*v1;
      if (ccw > 0) {
        ccw = (v2 - v1)*v1;
        if (ccw < 0)
            ccw = 0;
      }
    }
    return ccw < 0 ? -1 : ccw > 0 ? 1 : 0;
  }

  // DOCS: document Line#getDistance(point)
  /**
   * @param {Point} point
   * @return {Number}
   */
  num getDistance(Point point) {
    num m = this.vector.y / this.vector.x; // slope
    num b = this.point.y - (m * this.point.x); // y offset
    // Distance to the linear equation
    num dist = (point.y - (m * point.x) - b).abs() / Math.sqrt(m * m + 1);
    return infinite ? dist : Math.min(dist,
        point.getDistance(this.point),
        point.getDistance(this.point + this.vector));
  }
}
