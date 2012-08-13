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

// Based on goog.graphics.AffineTransform, as part of the Closure Library.
// Copyright 2008 The Closure Library Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");

/**
 * @name Matrix
 *
 * @class An affine transform performs a linear mapping from 2D coordinates
 * to other 2D coordinates that preserves the "straightness" and
 * "parallelness" of lines.
 *
 * Such a coordinate transformation can be represented by a 3 row by 3
 * column matrix with an implied last row of [ 0 0 1 ]. This matrix
 * transforms source coordinates (x,y) into destination coordinates (x',y')
 * by considering them to be a column vector and multiplying the coordinate
 * vector by the matrix according to the following process:
 * <pre>
 *      [ x ]   [ a  b  tx ] [ x ]   [ a * x + b * y + tx ]
 *      [ y ] = [ c  d  ty ] [ y ] = [ c * x + d * y + ty ]
 *      [ 1 ]   [ 0  0  1  ] [ 1 ]   [         1          ]
 * </pre>
 *
 * This class is optimized for speed and minimizes calculations based on its
 * knowledge of the underlying matrix (as opposed to say simply performing
 * matrix multiplication).
 */
class Matrix {
  num _a, _b, _c, _d, _tx, _ty;
  /**
   * Creates a 2D affine transform.
   *
   * @param {Number} a The scaleX coordinate of the transform
   * @param {Number} c The shearY coordinate of the transform
   * @param {Number} b The shearX coordinate of the transform
   * @param {Number} d The scaleY coordinate of the transform
   * @param {Number} tx The translateX coordinate of the transform
   * @param {Number} ty The translateY coordinate of the transform
   */
  Matrix([num a = 1, num c = 0, num b = 0, num d = 1, num tx = 0, num ty = 0]) {
    _a = a; _c = c; _b = b; _d = d; _tx = tx; _ty = ty;
  }
  Matrix.fromList(List list) {
    _a = list[0]; _c = list[1]; _b = list[2]; _d = list[3]; _tx = list[4]; _ty = list[5];
  }

  /**
   * @return {Matrix} A copy of this transform.
   */
  Matrix clone() {
    return new Matrix(_a, _c, _b, _d, _tx, _ty);
  }

  /**
   * Sets this transform to the matrix specified by the 6 values.
   *
   * @param {Number} a The scaleX coordinate of the transform
   * @param {Number} c The shearY coordinate of the transform
   * @param {Number} b The shearX coordinate of the transform
   * @param {Number} d The scaleY coordinate of the transform
   * @param {Number} tx The translateX coordinate of the transform
   * @param {Number} ty The translateY coordinate of the transform
   * @return {Matrix} This affine transform
   */
  Matrix set(a, c, b, d, tx, ty) {
    _a = a;
    _c = c;
    _b = b;
    _d = d;
    _tx = tx;
    _ty = ty;
    return this;
  }

  Matrix setIdentity() {
    _a = _d = 1;
    _c = _b = _tx = _ty = 0;
    return this;
  }

  /**
   * Concatentates this transform with a scaling transformation.
   *
   * @name Matrix#scale
   * @function
   * @param {Number} scale The scaling factor
   * @param {Point} [center] The center for the scaling transformation
   * @return {Matrix} This affine transform
   */
  /**
   * Concatentates this transform with a scaling transformation.
   *
   * @name Matrix#scale
   * @function
   * @param {Number} hor The horizontal scaling factor
   * @param {Number} ver The vertical scaling factor
   * @param {Point} [center] The center for the scaling transformation
   * @return {Matrix} This affine transform
   */
  // Concatenate this transform with a scaling transformation
  Matrix scale(num hor, /*num or Point*/ vert, [/*Point*/ center = null]) {

    if(vert is! num) {
      center = Point.read(vert);
      vert= hor;
    } else {
      center = Point.read(center);
    }

    // do translate if center supplied
    if(center != null) {
      this.translate(center);
    }

    _a *= hor;
    _c *= hor;
    _b *= vert;
    _d *= vert;

    // undo translate if center supplied   
    if(center != null) {
      translate(-center);
    }

    return this;
  }

  /**
   * Concatentates this transform with a translate transformation.
   *
   * @name Matrix#translate
   * @function
   * @param {Point} point The vector to translate by
   * @return {Matrix} This affine transform
   */
  /**
   * Concatentates this transform with a translate transformation.
   *
   * @name Matrix#translate
   * @function
   * @param {Number} dx The distance to translate in the x direction
   * @param {Number} dy The distance to translate in the y direction
   * @return {Matrix} This affine transform
   */
  Matrix translate(/*Point*/ point) {
    point = Point.read(point);
    _tx += point.x * _a + point.y * _b;
    _ty += point.x * _c + point.y * _d;
    return this;
  }

  /**
   * Concatentates this transform with a rotation transformation around an
   * anchor point.
   *
   * @name Matrix#rotate
   * @function
   * @param {Number} angle The angle of rotation measured in degrees
   * @param {Point} center The anchor point to rotate around
   * @return {Matrix} This affine transform
   */
  /**
   * Concatentates this transform with a rotation transformation around an
   * anchor point.
   *
   * @name Matrix#rotate
   * @function
   * @param {Number} angle The angle of rotation measured in degrees
   * @param {Number} x The x coordinate of the anchor point
   * @param {Number} y The y coordinate of the anchor point
   * @return {Matrix} This affine transform
   */
  Matrix rotate(num angle, [Point center = null]) {
    concatenate(new Matrix.fromRotation(angle, center));
  }

  /**
   * Concatentates this transform with a shear transformation.
   *
   * @name Matrix#shear
   * @function
   * @param {Point} point The shear factor in x and y direction
   * @param {Point} [center] The center for the shear transformation
   * @return {Matrix} This affine transform
   */
  /**
   * Concatentates this transform with a shear transformation.
   *
   * @name Matrix#shear
   * @function
   * @param {Number} hor The horizontal shear factor
   * @param {Number} ver The vertical shear factor
   * @param {Point} [center] The center for the shear transformation
   * @return {Matrix} This affine transform
   */
  Matrix shear(num hor, [/*num or Point*/ ver, /*Point*/ center]) {
    if(ver is! num) {
      center = Point.read(ver);
      ver = hor;
    } else {
      center = Point.read(center);
    }

    if(center != null)
      this.translate(center);
    var a = _a,
      c = _c;
    _a += ver * _b;
    _c += ver * _d;
    _b += hor * a;
    _d += hor * c;
    if(center != null)
      translate(center.negate());
    return this;
  }

  /**
   * @return {String} A string representation of this transform.
   */
  String toString() {
    // TODO formatting numbers
    //var format = Base.formatNumber;
    return '[[ $_a, $_b, $_tx, $_c, $_d, $_ty ]]';
  }

  /**
   * The scaling factor in the x-direction ({@code a}).
   *
   * @name Matrix#scaleX
   * @type Number
   */
  num get a() => _a;
  num get scaleX() => _a;

  /**
   * The scaling factor in the y-direction ({@code d}).
   *
   * @name Matrix#scaleY
   * @type Number
   */
  num get d() => _d;
  num get scaleY() => _d;

  /**
   * @return {Number} The shear factor in the x-direction ({@code b}).
   *
   * @name Matrix#shearX
   * @type Number
   */
  num get b() => _b;
  num get shearX() => _b;

  /**
   * @return {Number} The shear factor in the y-direction ({@code c}).
   *
   * @name Matrix#shearY
   * @type Number
   */
  num get c() => _c;
  num get shearY() => _c;

  /**
   * The translation in the x-direction ({@code tx}).
   *
   * @name Matrix#translateX
   * @type Number
   */
  num get tx() => _tx;
  num get translateX() => _tx;

  /**
   * The translation in the y-direction ({@code ty}).
   *
   * @name Matrix#translateY
   * @type Number
   */
  num get ty() => _ty;
  num get translateY() => _ty;

  /**
   * The transform values as an array, in the same sequence as they are passed
   * to {@link #initialize(a, c, b, d, tx, ty)}.
   *
   * @type Number[]
   * @bean
   */
  List<num> getValues() {
    return [ _a, _c, _b, _d, _tx, _ty ];
  }
  List<num> get values() => getValues();

  /**
   * Concatenates an affine transform to this transform.
   *
   * @param {Matrix} mx The transform to concatenate
   * @return {Matrix} This affine transform
   */
  Matrix concatenate(Matrix m) {
    num a = _a;
    num b = _b;
    num c = _c;
    num d = _d;
    _a = m._a * a + m._c * b;
    _b = m._b * a + m._d * b;
    _c = m._a * c + m._c * d;
    _d = m._b * c + m._d * d;
    _tx += m._tx * a + m._ty * b;
    _ty += m._tx * c + m._ty * d;
    return this;
  }

  /**
   * Pre-concatenates an affine transform to this transform.
   *
   * @param {Matrix} mx The transform to preconcatenate
   * @return {Matrix} This affine transform
   */
  Matrix preConcatenate(Matrix m) {
    num a = _a;
    num b = _b;
    num c = _c;
    num d = _d;
    num tx = _tx;
    num ty = _ty;
    _a = m._a * a + m._b * c;
    _b = m._a * b + m._b * d;
    _c = m._c * a + m._d * c;
    _d = m._c * b + m._d * d;
    _tx = m._a * tx + m._b * ty + m._tx;
    _ty = m._c * tx + m._d * ty + m._ty;
    return this;
  }

  /**
   * Transforms a point and returns the result.
   *
   * @name Matrix#transform
   * @function
   * @param {Point} point The point to be transformed
   * @return {Point} The transformed point
   */
  /**
   * Transforms an array of coordinates by this matrix and stores the results
   * into the destination array, which is also returned.
   *
   * @name Matrix#transform
   * @function
   * @param {Number[]} src The array containing the source points
   *        as x, y value pairs
   * @param {Number} srcOff The offset to the first point to be transformed
   * @param {Number[]} dst The array into which to store the transformed
   *        point pairs
   * @param {Number} dstOff The offset of the location of the first
   *        transformed point in the destination array
   * @param {Number} numPts The number of points to tranform
   * @return {Number[]} The dst array, containing the transformed coordinates.
   */
  transform(/* point | */ src, [srcOff, dst, dstOff, numPts]) {
    return numPts == null
      // TODO: Check for rectangle and use _tranformBounds?
      ? this.transformPoint(Point.read(src))
      : this._transformCoordinates(src, srcOff, dst, dstOff, numPts);
  }

  /**
   * A faster version of transform that only takes one point and does not
   * attempt to convert it.
   */
  Point transformPoint(Point point, [Point dest]) {
    num x = point.x;
    num y = point.y;
    if (dest == null)
      dest = new Point();
    return dest.set(
      x * this._a + y * this._b + this._tx,
      x * this._c + y * this._d + this._ty
    );
  }

  List _transformCoordinates(List src, int srcOff, List dst, int dstOff, int numPts) {
    int i = srcOff;
    int j = dstOff;
    int srcEnd = srcOff + 2 * numPts;
    while (i < srcEnd) {
      num x = src[i++];
      num y = src[i++];
      dst[j++] = x * _a + y * _b + _tx;
      dst[j++] = x * _c + y * _d + _ty;
    }
    return dst;
  }

  List _transformCorners(Rectangle rect) {
    num x1 = rect.x;
    num y1 = rect.y;
    num x2 = x1 + rect.width;
    num y2 = y1 + rect.height;
    List coords = [ x1, y1, x2, y1, x2, y2, x1, y2 ];
    return this._transformCoordinates(coords, 0, coords, 0, 4);
  }

  /**
   * Returns the 'transformed' bounds rectangle by transforming each corner
   * point and finding the new bounding box to these points. This is not
   * really the transformed reactangle!
   */
  Rectangle _transformBounds(Rectangle bounds, [Rectangle dest]) {
    List coords = this._transformCorners(bounds);
    // TODO check these
    List min = coords.getRange(0,2);
    List max = new List.from(coords);
    for (var i = 2; i < 8; i++) {
      int val = coords[i];
      int j = i & 1;
      if (val < min[j])
        min[j] = val;
      else if (val > max[j])
        max[j] = val;
    }
    if (dest == null)
      dest = new Rectangle();
    return dest.set(min[0], min[1], max[0] - min[0], max[1] - min[1]);
  }

  /**
   * Inverse transforms a point and returns the result.
   *
   * @param {Point} point The point to be transformed
   */
  Point inverseTransform(/*Point*/ point) {
    return _inverseTransform(Point.read(point));
  }

  /**
   * Returns the determinant of this transform, but only if the matrix is
   * reversible, null otherwise.
   */
  num _getDeterminant() {
    var det = _a * _d - _b * _c;
    return isFinite(det) && det.abs() > Numerical.EPSILON
        && isFinite(_tx) && isFinite(_ty)
        ? det : null;
  }

  Point _inverseTransform(Point point, [Point dest]) {
    var det = _getDeterminant();
    if (det == null)
      return null;
    var x = point.x - _tx,
      y = point.y - _ty;
    if (dest == null)
      dest = new Point();
    return dest.set(
      (x * _d - y * _b) / det,
      (y * _a - x * _c) / det
    );
  }

  Point getTranslation() {
    return new Point(_tx, _ty);
  }

  Point getScaling() {
    num hor = Math.sqrt(_a * _a + _c * _c);
    num ver = Math.sqrt(_b * _b + _d * _d);
    return new Point(_a < 0 ? -hor : hor, _b < 0 ? -ver : ver);
  }

  // TODO: find out what beans are. I think they make properties
  /**
   * The rotation angle of the matrix. If a non-uniform rotation is applied as
   * a result of a shear() or scale() command, undefined is returned, as the
   * resulting transformation cannot be expressed in one rotation angle.
   *
   * @type Number
   * @bean
   */
  num getRotation() {
    num angle1 = -Math.atan2(_b, _d);
    num angle2 = Math.atan2(_c, _a);
    return (angle1 - angle2).abs() < Numerical.TOLERANCE
        ? angle1 * 180 / Math.PI : null;
  }

  /**
   * Checks whether the two matrices describe the same transformation.
   *
   * @param {Matrix} matrix the matrix to compare this matrix to
   * @return {Boolean} {@true if the matrices are equal}
   */
  bool equals(Matrix mx) {
    return _a == mx._a && _b == mx._b && _c == mx._c
        && _d == mx._d && _tx == mx._tx && _ty == mx._ty;
  }
  // operator version
  bool operator == (Matrix mx) {
    return equals(mx);
  }

  /**
   * @return {Boolean} Whether this transform is the identity transform
   */
  bool isIdentity() {
    return _a == 1 && _c == 0 && _b == 0 && _d == 1
        && _tx == 0 && _ty == 0;
  }

  /**
   * Returns whether the transform is invertible. A transform is not
   * invertible if the determinant is 0 or any value is non-finite or NaN.
   *
   * @return {Boolean} Whether the transform is invertible
   */
  bool isInvertible() {
    return _getDeterminant() != null;
  }

  /**
   * Checks whether the matrix is singular or not. Singular matrices cannot be
   * inverted.
   *
   * @return {Boolean} Whether the matrix is singular
   */
  bool isSingular() {
    return _getDeterminant() == null;
  }

  /**
   * Inverts the transformation of the matrix. If the matrix is not invertible
   * (in which case {@link #isSingular()} returns true), {@code null } is
   * returned.
   * 
   * @return {Matrix} The inverted matrix, or {@code null }, if the matrix is
   *         singular
   */
  Matrix createInverse() {
    var det = _getDeterminant();
    if(det == null) return null;
    return new Matrix(
        _d / det,
        -_c / det,
        -_b / det,
        _a / det,
        (_b * _ty - _d * _tx) / det,
        (_c * _tx - _a * _ty) / det);
  }

  Matrix createShiftless() {
    return new Matrix(_a, _c, _b, _d, 0, 0);
  }

  /**
   * Sets this transform to a scaling transformation.
   *
   * @param {Number} hor The horizontal scaling factor
   * @param {Number} ver The vertical scaling factor
   * @return {Matrix} This affine transform
   */
  Matrix setToScale(num hor, num ver) {
    return set(hor, 0, 0, ver, 0, 0);
  }

  /**
   * Sets this transform to a translation transformation.
   *
   * @param {Number} dx The distance to translate in the x direction
   * @param {Number} dy The distance to translate in the y direction
   * @return {Matrix} This affine transform
   */
  // TODO what input types to accept?
  Matrix setToTranslation(delta, [num y]) {
    num x;
    if(delta is! num) {
      delta = Point.read(delta);
      x = delta.x;
      y = delta.y;
    } else {
      x = delta;
    }
    return this.set(1, 0, 0, 1, x, y);
  }

  /**
   * Sets this transform to a shearing transformation.
   *
   * @param {Number} hor The horizontal shear factor
   * @param {Number} ver The vertical shear factor
   * @return {Matrix} This affine transform
   */
  Matrix setToShear(num hor, num ver) {
    return set(1, ver, hor, 1, 0, 0);
  }

  /**
   * Sets this transform to a rotation transformation.
   *
   * @param {Number} angle The angle of rotation measured in degrees
   * @param {Number} x The x coordinate of the anchor point
   * @param {Number} y The y coordinate of the anchor point
   * @return {Matrix} This affine transform
   */
  Matrix setToRotation(num angle, /*Point*/ center) {
    center = Point.read(center);
    angle = angle * Math.PI / 180;
    num x = center.x;
    num y = center.y;
    num cos = Math.cos(angle);
    num sin = Math.sin(angle);
    return set(cos, sin, -sin, cos,
        x - x * cos + y * sin,
        y - x * sin - y * cos);
  }

  /**
   * Applies this matrix to the specified Canvas Context.
   *
   * @param {CanvasRenderingContext2D} ctx
   * @param {Boolean} [reset=false]
   */
  // TODO context type?
  Matrix applyToContext(ctx, [bool reset]) {
    ctx[reset ? 'setTransform' : 'transform'](
        _a, _c, _b, _d, _tx, _ty);
    return this;
  }

  /**
   * Creates a transform representing a scaling transformation.
   *
   * @param {Number} hor The horizontal scaling factor
   * @param {Number} ver The vertical scaling factor
   * @return {Matrix} A transform representing a scaling
   *         transformation
   */
  Matrix.getScaleInstance(num hor, num ver) {
    this.setToScale(hor, ver);
  }

  /**
   * Creates a transform representing a translation transformation.
   *
   * @param {Number} dx The distance to translate in the x direction
   * @param {Number} dy The distance to translate in the y direction
   * @return {Matrix} A transform representing a translation
   *         transformation
   */
  Matrix.getTranslateInstance(delta, [num y]) {
    this.setToTranslation(delta, y);
  }

  /**
   * Creates a transform representing a shearing transformation.
   *
   * @param {Number} hor The horizontal shear factor
   * @param {Number} ver The vertical shear factor
   * @return {Matrix} A transform representing a shearing transformation
   */
  Matrix.getShearInstance(num hor, num ver, [Point center]) {
    this.setToShear(hor, ver, center);
  }

  /**
   * Creates a transform representing a rotation transformation.
   *
   * @param {Number} angle The angle of rotation measured in degrees
   * @param {Number} x The x coordinate of the anchor point
   * @param {Number} y The y coordinate of the anchor point
   * @return {Matrix} A transform representing a rotation transformation
   */
  Matrix.getRotateInstance(num angle, [Point center]) {
    this.setToRotation(angle, center);
  }
}