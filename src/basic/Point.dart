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

/**
 * @name Point
 *
 * @class The Point object represents a point in the two dimensional space
 * of the Paper.js project. It is also used to represent two dimensional
 * vector objects.
 *
 * @classexample
 * // Create a point at x: 10, y: 5
 * var point = new Point(10, 5);
 * print(point.x); // 10
 * print(point.y); // 5
 */
class Point {
  num _x;
  num _y;
  // TODO try to support different constructor in the default?
  //Point(var first, [var second = null]) {
    //check types, etc.
  //}
  // unified constructor
  Point([arg0, arg1]) {
    if(arg1 != null) {
      _x = arg0;
      _y = arg1;
    } else {
      if(arg0 == null) {
        _x = 0;
        _y = 0;
      } else if(arg0 is Map) {
        if(arg0.containsKey("x")) {
          _x = arg0["x"];
          _y = arg0["y"];
        } else if(arg0.containsKey("width")) {
          _x = arg0["width"];
          _y = arg0["height"];
        } else if(arg0.containsKey("angle")) {
          _x = arg0["length"];
          _y = 0;
          setAngle(arg0["angle"]);
        }
      } else if(arg0 is List) {
        _x = arg0[0];
        _y = arg0.length > 1 ? arg0[1] : arg0[0];
      } else if(arg0 is num) {
        _x = _y = arg0;
      } else if(arg0 is Size) {
        _x = arg0.width;
        _y = arg0.height;
      }
    }
  }

  // screen Point-like objects
  // TODO turn this into a factory constructor
  static Point read(arg) {
    if(arg is Point) return arg;
    return new Point(arg);
  }

  /**
   * Creates a Point object with the given x and y coordinates.
   *
   * @name Point#initialize
   * @param {Number} x the x coordinate
   * @param {Number} y the y coordinate
   *
   * @example
   * // Create a point at x: 10, y: 5
   * Point point = new Point(10, 5);
   * print(point.x); // 10
   * print(point.y); // 5
   */
  /**
   * Provide a faster creator for Points out of two coordinates that
   * does not rely on Point#Point at all. This speeds up all math operations a lot
   *
   * @ignore
   */
  Point.create([num x = 0, num y = 0]) {
    _x = x;
    _y = y;
  }
  /**
   * Creates a Point object using the numbers in the given list as
   * coordinates.
   *
   * @name Point#initialize
   * @param {List} list
   *
   * @example
   * // Creating a point at x: 10, y: 5 using a list of numbers:
   * List list = [10, 5];
   * var point = new Point.fromList(list);
   * print(point.x); // 10
   * print(point.y); // 5
   *
   * TODO support below
   * @example
   * // Passing an array to a functionality that expects a point:
   *
   * // Create a circle shaped path at x: 50, y: 50
   * // with a radius of 30:
   * var path = new Path.Circle([50, 50], 30);
   * path.fillColor = 'red';
   *
   * // Which is the same as doing:
   * var path = new Path.Circle(new Point(50, 50), 30);
   * path.fillColor = 'red';
   */
  Point.fromList(List point) {
    _x = point[0];
    _y = point[1];
  }
  /**
   * Creates a Point object using the properties in the given map.
   *
   * @name Point#initialize
   * @param {Map} object
   *
   * @example
   * // Creating a point using an object literal with length and angle
   * // properties:
   *
   * var point = new Point({
   *   length: 10,
   *   angle: 90
   * });
   * print(point.length); // 10
   * print(point.angle); // 90
   *
   * @example
   * // Creating a point at x: 10, y: 20 using an object literal:
   *
   * var point = new Point({
   *   x: 10,
   *   y: 20
   * });
   * print(point.x); // 10
   * print(point.y); // 20
   *
   * @example
   * // Passing an object to a functionality that expects a point:
   *
   * var center = {
   *   x: 50,
   *   y: 50
   * };
   *
   * // Creates a circle shaped path at x: 50, y: 50
   * // with a radius of 30:
   * var path = new Path.Circle(center, 30);
   * path.fillColor = 'red';
   */
  Point.fromMap(Map map) {
    // read from {"x": x, "y": y}
    if(map.containsKey("x")) {
    _x = map["x"];
    _y = map["y"];
    }
    // read from {"length": length, "angle": angle}
    else if(map.containsKey("angle")) {
      _x = map["length"];
      setAngle(map["angle"]);
    }
    // read from {"width": width, "height": height}
    else if(map.containsKey("width")) {
      _x = map["width"];
      _y = map["height"];
    }
  }
  /**
   * Creates a Point object using the width and height values of the given
   * Size object.
   *
   * @name Point#initialize
   * @param {Size} size
   *
   * @example
   * // Creating a point using a size object.
   *
   * // Create a Size with a width of 100pt and a height of 50pt
   * var size = new Size(100, 50);
   * print(size); // { width: 100, height: 50 }
   * var point = new Point(size);
   * print(point); // { x: 100, y: 50 }
   */
  /**
   * Creates a Point object using the coordinates of the given Point object.
   *
   * @param {Point} point
   * @name Point#initialize
   */

  /**
   * The x coordinate of the point
   *
   * @name Point#x
   * @type Number
   */
  num get x() => _x;
      set x(num value) => _x = value;

  /**
   * The y coordinate of the point
   *
   * @name Point#y
   * @type Number
   */
  num get y() => _y;
      set y(num value) => _y = value;

  Point set(num x, num y) {
    _x = x;
    _y = y;
    return this;
  }

  /**
   * Returns a copy of the point.
   *
   * @example
   * var point1 = new Point();
   * var point2 = point1;
   * point2.x = 1; // also changes point1.x
   *
   * var point2 = point1.clone();
   * point2.x = 1; // doesn't change point1.x
   *
   * @returns {Point} the cloned point
   */
  Point clone() {
    return new Point.create(_x, _y);
  }

  /**
   * @return {String} A string representation of the point.
   */
  String toString() {
    var format = Base.formatNumber;
    return '{ x: ${format(x)}, y: ${format(y)} }';
  }

  // TODO support adding scalar?
  /**
   * Returns the addition of the supplied value to both coordinates of
   * the point as a new point.
   * The object itself is not modified!
   *
   * @name Point#add
   * @function
   * @param {Number} number the number to add
   * @return {Point} the addition of the point and the value as a new point
   *
   * @example
   * var point = new Point(5, 10);
   * var result = point + 20;
   * print(result); // {x: 25, y: 30}
   */
  /**
   * Returns the addition of the supplied point to the point as a new
   * point.
   * The object itself is not modified!
   *
   * @name Point#add
   * @function
   * @param {Point} point the point to add
   * @return {Point} the addition of the two points as a new point
   *
   * @example
   * var point1 = new Point(5, 10);
   * var point2 = new Point(10, 20);
   * var result = point1 + point2;
   * print(result); // {x: 15, y: 30}
   */
  Point add(/*Point*/ point) {
    point = Point.read(point);
    return new Point.create(x + point.x, y + point.y);
  }
  // operator version
  Point operator + (/*Point*/ point) {
    return add(point);
  }

  /**
   * Returns the subtraction of the supplied value to both coordinates of
   * the point as a new point.
   * The object itself is not modified!
   *
   * @name Point#subtract
   * @function
   * @param {Number} number the number to subtract
   * @return {Point} the subtraction of the point and the value as a new point
   *
   * @example
   * var point = new Point(10, 20);
   * var result = point - 5;
   * print(result); // {x: 5, y: 15}
   */
  /**
   * Returns the subtraction of the supplied point to the point as a new
   * point.
   * The object itself is not modified!
   *
   * @name Point#subtract
   * @function
   * @param {Point} point the point to subtract
   * @return {Point} the subtraction of the two points as a new point
   *
   * @example
   * var firstPoint = new Point(10, 20);
   * var secondPoint = new Point(5, 5);
   * var result = firstPoint - secondPoint;
   * print(result); // {x: 5, y: 15}
   */
  Point subtract(/*Point*/ point) {
    point = Point.read(point);
    return new Point.create(x - point.x, y - point.y);
  }
  // operator version
  Point operator - (/*Point*/ point) {
    return subtract(point);
  }

  /**
   * Returns the multiplication of the supplied value to both coordinates of
   * the point as a new point.
   * The object itself is not modified!
   *
   * @name Point#multiply
   * @function
   * @param {Number} number the number to multiply by
   * @return {Point} the multiplication of the point and the value as a new point
   *
   * @example
   * var point = new Point(10, 20);
   * var result = point * 2;
   * print(result); // {x: 20, y: 40}
   */
  /**
   * Returns the multiplication of the supplied point to the point as a new
   * point.
   * The object itself is not modified!
   *
   * @name Point#multiply
   * @function
   * @param {Point} point the point to multiply by
   * @return {Point} the multiplication of the two points as a new point
   *
   * @example
   * var firstPoint = new Point(5, 10);
   * var secondPoint = new Point(4, 2);
   * var result = firstPoint * secondPoint;
   * print(result); // {x: 20, y: 20}
   */
  Point multiply(/*Point*/ point) {
    point = Point.read(point);
    return new Point.create(x * point.x, y * point.y);
  }
  // operator version
  // TODO NOTE: this does dot product for Point argument, instead of component-wise like above
  Object operator * (/*Point*/ value) {
    if(value is num) {
      return new Point.create(x * value, y * value);
    }
    value = Point.read(value);
    return x * value.x + y * value.y;
  }

  /**
   * Returns the division of the supplied value to both coordinates of
   * the point as a new point.
   * The object itself is not modified!
   *
   * @name Point#divide
   * @function
   * @param {Number} number the number to divide by
   * @return {Point} the division of the point and the value as a new point
   *
   * @example
   * var point = new Point(10, 20);
   * var result = point / 2;
   * print(result); // {x: 5, y: 10}
   */
  /**
   * Returns the division of the supplied point to the point as a new
   * point.
   * The object itself is not modified!
   *
   * @name Point#divide
   * @function
   * @param {Point} point the point to divide by
   * @return {Point} the division of the two points as a new point
   *
   * @example
   * var firstPoint = new Point(8, 10);
   * var secondPoint = new Point(2, 5);
   * var result = firstPoint / secondPoint;
   * print(result); // {x: 4, y: 2}
   */
  Point divide(/*Point*/ point) {
    point = Point.read(point);
    return new Point.create(x / point.x, y / point.y);
  }
  // operator version
  Point operator / (/*Point*/ point) {
    return divide(point);
  }

  /**
   * The modulo operator returns the integer remainders of dividing the point
   * by the supplied value as a new point.
   *
   * @name Point#modulo
   * @function
   * @param {Number} value
   * @return {Point} the integer remainders of dividing the point by the value
   *                 as a new point
   *
   * @example
   * var point = new Point(12, 6);
   * print(point % 5); // {x: 2, y: 1}
   */
  /**
   * The modulo operator returns the integer remainders of dividing the point
   * by the supplied value as a new point.
   *
   * @name Point#modulo
   * @function
   * @param {Point} point
   * @return {Point} the integer remainders of dividing the points by each
   *                 other as a new point
   *
   * @example
   * var point = new Point(12, 6);
   * print(point % new Point(5, 2)); // {x: 2, y: 0}
   */
  Point modulo(/*Point*/ point) {
    point = Point.read(point);
    return new Point.create(x % point.x, y % point.y);
  }
  // operator version
  Point operator % (/*Point*/ point) {
    return modulo(point);
  }

  // depending on the language version, this may already be the operator
  Point negate() {
    return new Point.create(-x, -y);
  }
  // TODO implement operator version once they push the language changes

  /**
   * Transforms the point by the matrix as a new point. The object itself
   * is not modified!
   *
   * @param {Matrix} matrix
   * @return {Point} The transformed point
   */
  Point transform(Matrix matrix) {
    // TODO operator for matrix-point multiplication?
    return matrix != null ? matrix.transformPoint(this) : this;
  }

  /**
   * {@grouptitle Distance & Length}
   *
   * Returns the distance between the point and another point.
   *
   * @param {Point} point
   * @param {Boolean} squared Controls whether the distance should remain
   *        squared, or its square root should be calculated.
   * @return {Number}
   */
  num getDistance(/*Point*/ point, [bool squared = false]) {
    point = Point.read(point);
    num x = point.x - this.x;
    num y = point.y - this.y;
    num d = x * x + y * y;
    return squared ? d : Math.sqrt(d);
  }

  /**
   * The length of the vector that is represented by this point's coordinates.
   * Each point can be interpreted as a vector that points from the origin
   * ({@code x = 0}, {@code y = 0}) to the point's location.
   * Setting the length changes the location but keeps the vector's angle.
   *
   * @type Number
   * @bean
   */
  num getLength([bool square = false]) {
    // Supports a hidden parameter 'squared', which controls whether the
    // squared length should be returned. Hide it so it produces a bean
    // property called #length.
    var l = x * x + y * y;
    return square ? l : Math.sqrt(l);
  }
  // property getter for length
  num get length() => Math.sqrt(x*x + y*y);

  Point setLength(num length) {
    // TODO: Whenever setting x/y, use #set() instead of direct assignment,
    // so LinkedPoint does not report changes twice.
    if (isZero()) {
      num angle = this.angle;
      x = Math.cos(angle) * length;
      y = Math.cos(angle) * length;
    } else {
      var scale = length / this.length;
      // Force calculation of angle now, so it will be preserved even when
      // x and y are 0
      if (scale == 0)
        this.getAngle();
      this.x *= scale;
      this.y *= scale;
    }
    return this;
  }
  // property setter for length
  set length(num value) => setLength(value);

  /**
   * Normalize modifies the {@link #length} of the vector to {@code 1} without
   * changing its angle and returns it as a new point. The optional
   * {@code length} parameter defines the length to normalize to.
   * The object itself is not modified!
   * 
   * TODO I don't really like that normalize doesn't modify the object
   * it should be called normalized then
   *
   * @param {Number} [length=1] The length of the normalized vector
   * @return {Point} The normalized vector of the vector that is represented
   *                 by this point's coordinates.
   */
  Point normalize([num length = 1]) {
    num current = this.length;
    num scale = current != 0 ? length / current : 0;
    Point point = this * scale;
    // Preserve angle.
    // TODO does this not happen automatically
    point.angle = angle;
    return point;
  }

  /**
   * {@grouptitle Angle & Rotation}
   * Returns the smaller angle between two vectors. The angle is unsigned, no
   * information about rotational direction is given.
   *
   * @name Point#getAngle
   * @function
   * @param {Point} point
   * @return {Number} the angle in degrees
   */
  /**
   * The vector's angle in degrees, measured from the x-axis to the vector.
   *
   * The angle is unsigned, no information about rotational direction is
   * given.
   *
   * @name Point#getAngle
   * @bean
   * @type Number
   */
  num getAngle([/*Point*/ point]) {
    // Hide parameters from Bootstrap so it injects bean too
    _angle = getAngleInRadians(point) * 180 / Math.PI;
    return _angle;
  }
  // backing field
  num _angle;
  // property getter
  num get angle() => getAngle();

  Point setAngle(angle) {
    angle = this._angle = angle * Math.PI / 180;
    if (!isZero()) {
      var length = this.getLength();
      // TODO Use #set() instead of direct assignment of x/y, so LinkedPoint
      // does not report changes twice.
      _x = Math.cos(angle) * length;
      _y = Math.sin(angle) * length;
    }
    return this;
  }
  // property setter
  set angle(num angle) => setAngle(angle);

  /**
   * Returns the smaller angle between two vectors in radians. The angle is
   * unsigned, no information about rotational direction is given.
   *
   * @name Point#getAngleInRadians
   * @function
   * @param {Point} point
   * @return {Number} the angle in radians
   */
  /**
   * The vector's angle in radians, measured from the x-axis to the vector.
   *
   * The angle is unsigned, no information about rotational direction is
   * given.
   *
   * @name Point#getAngleInRadians
   * @bean
   * @type Number
   */
  num getAngleInRadians([/*Point*/ point]) {
    // Hide parameters from Bootstrap so it injects bean too
    if (point == null) {
      if (_angle == null)
        _angle = Math.atan2(y, x);
      return _angle;
    } else {
      point = Point.read(point);
      num div = getLength() * point.getLength();
      if (div == 0) {
        return double.NAN;
      } else {
        return Math.acos(this.dot(point) / div);
      }
    }
  }

  num getAngleInDegrees([Point point = null]) {
    return getAngle(point);
  }

  /**
   * The quadrant of the {@link #angle} of the point.
   *
   * Angles between 0 and 90 degrees are in quadrant {@code 1}. Angles between
   * 90 and 180 degrees are in quadrant {@code 2}, angles between 180 and 270
   * degrees are in quadrant {@code 3} and angles between 270 and 360 degrees
   * are in quadrant {@code 4}.
   *
   * @type Number
   * @bean
   *
   * @example
   * var point = new Point({
   *   angle: 10,
   *   length: 20
   * });
   * print(point.quadrant); // 1
   *
   * point.angle = 100;
   * print(point.quadrant); // 2
   *
   * point.angle = 190;
   * print(point.quadrant); // 3
   *
   * point.angle = 280;
   * print(point.quadrant); // 4
   */
  int getQuadrant() {
    return x >= 0 ? y >= 0 ? 1 : 4 : y >= 0 ? 2 : 3;
  }
  // quadrant getter
  int get quadrant() => getQuadrant();

  /**
   * Returns the angle between two vectors. The angle is directional and
   * signed, giving information about the rotational direction.
   *
   * Read more about angle units and orientation in the description of the
   * {@link #angle} property.
   *
   * @param {Point} point
   * @return {Number} the angle between the two vectors
   */
  num getDirectedAngle(/*Point*/ point) {
    point = Point.read(point);
    return Math.atan2(cross(point), dot(point)) * 180 / Math.PI;
  }

  /**
   * Rotates the point by the given angle around an optional center point.
   * The object itself is not modified.
   *
   * Read more about angle units and orientation in the description of the
   * {@link #angle} property.
   *
   * @param {Number} angle the rotation angle
   * @param {Point} center the center point of the rotation
   * @returns {Point} the rotated point
   */
  Point rotate(num angle, [Point center = null]) {
    angle = angle * Math.PI / 180;
    Point point = center != null ? this - center : this;
    num s = Math.sin(angle);
    num c = Math.cos(angle);
    point = new Point.create(
      point.x * c - point.y * s,
      point.y * c + point.x * s
    );
    return center != null ? point + center : point;
  }

  /**
   * Checks whether the coordinates of the point are equal to that of the
   * supplied point.
   *
   * @param {Point} point
   * @return {Boolean} {@true if the points are equal}
   *
   * @example
   * var point = new Point(5, 10);
   * print(point == new Point(5, 10)); // true
   * print(point == new Point(1, 1)); // false
   * print(point != new Point(1, 1)); // true
   */
  bool equals(/*Point*/ point) {
    if(point == null) return false;
    point = Point.read(point);
    return x == point.x && y == point.y;
  }
  // operator version
  bool operator == (Point point) => equals(point);

  /**
   * {@grouptitle Tests}
   *
   * Checks whether the point is inside the boundaries of the rectangle.
   *
   * @param {Rectangle} rect the rectangle to check against
   * @returns {Boolean} {@true if the point is inside the rectangle}
   */
  bool isInside(Rectangle rect) {
    return rect.contains(this);
  }

  // TODO why not accept Point-like things in the is* methods below?
  /**
   * Checks if the point is within a given distance of another point.
   *
   * @param {Point} point the point to check against
   * @param {Number} tolerance the maximum distance allowed
   * @returns {Boolean} {@true if it is within the given distance}
   */
  bool isClose(Point point, num tolerance) {
    return this.getDistance(point) < tolerance;
  }

  /**
   * Checks if the vector represented by this point is colinear (parallel) to
   * another vector.
   *
   * @param {Point} point the vector to check against
   * @returns {Boolean} {@true it is parallel}
   */
  bool isColinear(Point point) {
    return this.cross(point) < Numerical.TOLERANCE;
  }

  /**
   * Checks if the vector represented by this point is orthogonal
   * (perpendicular) to another vector.
   *
   * @param {Point} point the vector to check against
   * @returns {Boolean} {@true it is orthogonal}
   */
  bool isOrthogonal(point) {
    return dot(point) < Numerical.TOLERANCE;
  }

  /**
   * Checks if this point has both the x and y coordinate set to 0.
   *
   * @returns {Boolean} {@true both x and y are 0}
   */
  bool isZero() {
    return x == 0 && y == 0;
  }

  /**
   * Checks if this point has an undefined value for at least one of its
   * coordinates.
   *
   * @returns {Boolean} {@true if either x or y are not a number}
   */
  bool isNaN() {
    return x.isNaN() || y.isNaN();
  }

  /**
   * {@grouptitle Vector Math Functions}
   * Returns the dot product of the point and another point.
   *
   * @param {Point} point
   * @returns {Number} the dot product of the two points
   */
  num dot(/*Point*/ point) {
    point = Point.read(point);
    return x * point.x + y * point.y;
  }

  /**
   * Returns the cross product of the point and another point.
   *
   * @param {Point} point
   * @returns {Number} the cross product of the two points
   */
  num cross(/*Point*/ point) {
    point = Point.read(point);
    return x * point.y - y * point.x;
  }

  /**
   * Returns the projection of the point on another point.
   * Both points are interpreted as vectors.
   *
   * @param {Point} point
   * @returns {Point} the projection of the point on another point
   */
  Point project(/*Point*/ point) {
    point = Point.read(point);
    if (point.isZero()) {
      return new Point.create(0, 0);
    } else {
      num scale = dot(point) / point.dot(point);
      return new Point.create(
        point.x * scale,
        point.y * scale
      );
    }
  }

  // TODO implement
  /**
   * This property is only present if the point is an anchor or control point
   * of a {@link Segment} or a {@link Curve}. In this case, it returns
   * {@true it is selected}
   *
   * @name Point#selected
   * @property
   * @return {Boolean} {@true the point is selected}
   */

  /**
   * Returns a new point object with the smallest {@link #x} and
   * {@link #y} of the supplied points.
   *
   * @static
   * @param {Point} point1
   * @param {Point} point2
   * @returns {Point} The newly created point object
   *
   * @example
   * var point1 = new Point(10, 100);
   * var point2 = new Point(200, 5);
   * var minPoint = Point.min(point1, point2);
   * print(minPoint); // {x: 10, y: 5}
   */
  static Point min(/*Point*/ point1, /*Point*/ point2) {
    point1 = Point.read(point1);
    point2 = Point.read(point2);
    return new Point.create(
      Math.min(point1.x, point2.x),
      Math.min(point1.y, point2.y)
    );
  }

  /**
   * Returns a new point object with the largest {@link #x} and
   * {@link #y} of the supplied points.
   *
   * @static
   * @param {Point} point1
   * @param {Point} point2
   * @returns {Point} The newly created point object
   *
   * @example
   * var point1 = new Point(10, 100);
   * var point2 = new Point(200, 5);
   * var maxPoint = Point.max(point1, point2);
   * print(maxPoint); // {x: 200, y: 100}
   */
  static Point max(/*Point*/ point1, /*Point*/ point2) {
    point1 = Point.read(point1);
    point2 = Point.read(point2);
    return new Point.create(
      Math.max(point1.x, point2.x),
      Math.max(point1.y, point2.y)
    );
  }

  /**
   * Returns a point object with random {@link #x} and {@link #y} values
   * between {@code 0} and {@code 1}.
   *
   * @returns {Point} The newly created point object
   * @static
   *
   * @example
   * var maxPoint = new Point(100, 100);
   * var randomPoint = Point.random();
   *
   * // A point between {x:0, y:0} and {x:100, y:100}:
   * var point = maxPoint * randomPoint;
   */
  Point.random() {
    _x = Math.random();
    _y = Math.random();
  }

  /**
   * {@grouptitle Math Functions}
   *
   * Returns a new point with rounded {@link #x} and {@link #y} values. The
   * object itself is not modified!
   *
   * @name Point#round
   * @function
   * @return {Point}
   *
   * @example
   * var point = new Point(10.2, 10.9);
   * var roundPoint = point.round();
   * print(roundPoint); // {x: 10, y: 11}
   */
  Point round() {
    // TODO check if dart's round is the same as js
    return new Point.create(x.round(), y.round());
  }

  /**
   * Returns a new point with the nearest greater non-fractional values to the
   * specified {@link #x} and {@link #y} values. The object itself is not
   * modified!
   *
   * @name Point#ceil
   * @function
   * @return {Point}
   *
   * @example
   * var point = new Point(10.2, 10.9);
   * var ceilPoint = point.ceil();
   * print(ceilPoint); // {x: 11, y: 11}
   */
  Point ceil() {
    return new Point.create(x.ceil(), y.ceil());
  }

  /**
   * Returns a new point with the nearest smaller non-fractional values to the
   * specified {@link #x} and {@link #y} values. The object itself is not
   * modified!
   *
   * @name Point#floor
   * @function
   * @return {Point}
   *
   * @example
   * var point = new Point(10.2, 10.9);
   * var floorPoint = point.floor();
   * print(floorPoint); // {x: 10, y: 10}
   */
  Point floor() {
    return new Point.create(x.floor(), y.floor());
  }

  /**
   * Returns a new point with the absolute values of the specified {@link #x}
   * and {@link #y} values. The object itself is not modified!
   *
   * @name Point#abs
   * @function
   * @return {Point}
   *
   * @example
   * var point = new Point(-5, 10);
   * var absPoint = point.abs();
   * print(absPoint); // {x: 5, y: 10}
   */
  Point abs() {
    return new Point.create(x.abs(), y.abs());
  }
}

/**
 * @name LinkedPoint
 *
 * @class An internal version of Point that notifies its owner of each change
 * through setting itself again on the setter that corresponds to the getter
 * that produced this LinkedPoint. See uses of LinkedPoint.create()
 * Note: This prototype is not exported.
 *
 * @ignore
 */
// TODO I think this implementation doesn't require storing the owner
// separately from the setter
class LinkedPoint extends Point {
  Object _owner;
  var _setter;

  LinkedPoint set(num x, num y, [dontNotify = false]) {
    _x = x;
    _y = y;
    if (!dontNotify)
      _setter(this);
      //this._owner[this._setter](this);
    return this;
  }

  // TODO Point should already have this method
  /*num getX() {
    return _x;
  }*/

  void setX(num x) {
    _x = x;
    //_owner[_setter](this);
    _setter(this);
  }
  set x(num value) => setX(value);

  // TODO Point should already have this method
  //num getY() {
  //  return _y;
  //}

  void setY(num y) {
    _y = y;
    //_owner[_setter](this);
    _setter(this);
  }
  set y(num value) => setY(value);

  LinkedPoint._construct() {}

  factory LinkedPoint.create(owner, setter, x, y, [dontLink = false])
  {
    // Support creation of normal Points rather than LinkedPoints
    // through an optional parameter that can be passed to the getters.
    // See e.g. Rectangle#getPoint(true).
    if (dontLink)
      return new Point.create(x, y);
    var point = new LinkedPoint._construct();
    point._x = x;
    point._y = y;
    point._owner = owner;
    point._setter = setter;
    return point;
  }
}