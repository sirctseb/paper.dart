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
 * @name CurveLocation
 *
 * @class CurveLocation objects describe a location on {@link Curve}
 * objects, as defined by the curve {@link #parameter}, a value between
 * {@code 0} (beginning of the curve) and {@code 1} (end of the curve). If
 * the curve is part of a {@link Path} item, its {@link #index} inside the
 * {@link Path#curves} array is also provided.
 *
 * The class is in use in many places, such as
 * {@link Path#getLocationAt(offset)}, Path#getNearestLocation(point), etc.
 */
class CurveLocation {
  // DOCS: CurveLocation class description: add these back when the  mentioned
  // functioned have been added: {@link Path#split(location)},
  // {@link PathItem#getIntersections(path)}, etc.
  /**
   * Creates a new CurveLocation object.
   *
   * @param {Curve} curve
   * @param {Number} parameter
   * @param {Point} point
   */
  CurveLocation(Curve curve, num parameter, Point point, num distance) {
    _curve = curve;
    _parameter = parameter;
    _point = point;
    _distance = distance;
  }

  /**
   * The segment of the curve which is closer to the described location.
   *
   * @type Segment
   * @bean
   */
  Segment _segment;
  Segment getSegment() {
    if (_segment == null) {
      var curve = _curve,
        parameter = getParameter();
      if (parameter == 0) {
        _segment = curve._segment1;
      } else if (parameter == 1) {
        _segment = curve._segment2;
      } else if (parameter == null) {
        return null;
      } else {
        // Determine the closest segment by comparing curve lengths
        _segment = curve.getLength(0, parameter)
          < curve.getLength(parameter, 1)
            ? curve._segment1
            : curve._segment2;
      }
    }
    return _segment;
  }
  Segment get segment => getSegment();

  /**
   * The curve by which the location is defined.
   *
   * @type Curve
   * @bean
   */
  Curve _curve;
  Curve getCurve() {
    return _curve;
  }
  Curve get curve => getCurve();

  /**
   * The path this curve belongs to, if any.
   *
   * @type Item
   * @bean
   */
  Item getPath() {
    return _curve != null ? _curve._path : null;
  }
  Item get path => getPath();

  /**
   * The index of the curve within the {@link Path#curves} list, if the
   * curve is part of a {@link Path} item.
   *
   * @type Index
   * @bean
   */
  int getIndex() {
    return _curve != null ? _curve.getIndex() : null;
  }
  int get index => getIndex();

  /**
   * The length of the path from its beginning up to the location described
   * by this object.
   *
   * @type Number
   * @bean
   */
  num getOffset() {
    var path = _curve != null ? _curve._path : null;
    return path != null ? path._getOffset(this) : null;
  }
  num get offset => getOffset();

  /**
   * The length of the curve from its beginning up to the location described
   * by this object.
   *
   * @type Number
   * @bean
   */
  num getCurveOffset() {
    var parameter = getParameter();
    return parameter != null && _curve != null ?
        _curve.getLength(0, parameter) : null;
  }
  num get curveOffset => getCurveOffset();

  /**
   * The curve parameter, as used by various bezier curve calculations. It is
   * value between {@code 0} (beginning of the curve) and {@code 1} (end of
   * the curve).
   *
   * @type Number
   * @bean
   */
  num _parameter;
  num getParameter() {
    if (_parameter == null && _curve != null && _point != null)
      _parameter = _curve.getParameterAt(_point);
    return _parameter;
  }
  num get parameter => getParameter();

  /**
   * The point which is defined by the {@link #curve} and
   * {@link #parameter}.
   *
   * @type Point
   * @bean
   */
  num _point;
  Point getPoint() {
    if (_point == null && _curve != null && _parameter != null)
      _point = _curve.getPoint(_parameter);
    return _point;
  }
  Point get point => getPoint();

  /**
   * The tangential vector to the {@link #curve} at the given location.
   *
   * @type Point
   * @bean
   */
  Point getTangent() {
    var parameter = getParameter();
    return parameter != null && _curve != null
        ? _curve.getTangent(parameter) : null;
  }
  Point get tangent => getTangent();

  /**
   * The normal vector to the {@link #curve} at the given location.
   *
   * @type Point
   * @bean
   */
  Point getNormal() {
    var parameter = getParameter();
    return parameter != null && _curve != null
        ? _curve.getNormal(parameter) : null;
  }
  Point get normal => getNormal();

  /**
   * The distance from the queried point to the returned location.
   *
   * @type Number
   * @bean
   */
  num _distance;
  num getDistance() {
    return _distance;
  }
  num get distance => getDistance();

  /**
   * @return {String} A string representation of the curve location.
   */
  String toString() {
    StringBuffer sb = new StringBuffer();
    Point point = getPoint();
    if (point != null)
      sb.add('point: ${point.toString()}');
    int index = getIndex();
    if (index != null) {
      if (!sb.isEmpty()) sb.add(', ');
      sb.add('index: $index');
    }
    var parameter = getParameter();
    if (parameter != null) {
      if(!sb.isEmpty()) sb.add(', ');
      sb.add('parameter: ${Base.formatNumber(parameter)}');
    }
    if (_distance != null) {
      if(!sb.isEmpty()) sb.add(', ');
      sb.add('distance: ${Base.formatNumber(this._distance)}');
    }
    return sb.toString();
  }
}
