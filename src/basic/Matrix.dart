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
    return new Matrix.create(_a, _c, _b, _d, _tx, _ty);
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
  },

  Matrix setIdentity() {
    _a = _d = 1;
    _c = _b = _tx = _ty = 0;
    return this;
  },

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
  Matrix scale(num hor, num vert, [Vector2 center = null]) {
    // TODO allow only one scaling factor plus a center

    // do translate if center supplied
    if(center != null) {
      this.translate(center);
    }

    _a *= hor;
    _c *= hor;
    _b *= ver;
    _d *= ver;

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
  Matrix translate(Vector2 point) {
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
  Matrix rotate(num angle, [Vector2 center = null]) {
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
  Matrix shear(num hor, [num ver = null, Point center = null]) {
    if(ver == null) ver = hor;

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
  },

  /**
   * @return {String} A string representation of this transform.
   */
  String toString() {
    // TODO formatting numbers
    //var format = Base.formatNumber;
    return '[[ $_a, $_b, $_tx, $_c, $_d, $_ty ]]';
  },

  /**
   * The scaling factor in the x-direction ({@code a}).
   *
   * @name Matrix#scaleX
   * @type Number
   */
  num get a() => _a;

  /**
   * The scaling factor in the y-direction ({@code d}).
   *
   * @name Matrix#scaleY
   * @type Number
   */
  num get d() => _d;

  /**
   * @return {Number} The shear factor in the x-direction ({@code b}).
   *
   * @name Matrix#shearX
   * @type Number
   */
  num get b() => _b;

  /**
   * @return {Number} The shear factor in the y-direction ({@code c}).
   *
   * @name Matrix#shearY
   * @type Number
   */
  num get c() => _c;

  /**
   * The translation in the x-direction ({@code tx}).
   *
   * @name Matrix#translateX
   * @type Number
   */
  num get tx() => _tx;

  /**
   * The translation in the y-direction ({@code ty}).
   *
   * @name Matrix#translateY
   * @type Number
   */
  num get ty() => _ty;

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
  transform: function(/* point | */ src, srcOff, dst, dstOff, numPts) {
    return arguments.length < 5
      // TODO: Check for rectangle and use _tranformBounds?
      ? this._transformPoint(Point.read(arguments))
      : this._transformCoordinates(src, srcOff, dst, dstOff, numPts);
  },

  /**
   * A faster version of transform that only takes one point and does not
   * attempt to convert it.
   */
  _transformPoint: function(point, dest, dontNotify) {
    var x = point.x,
      y = point.y;
    if (!dest)
      dest = new Point(Point.dont);
    return dest.set(
      x * this._a + y * this._b + this._tx,
      x * this._c + y * this._d + this._ty,
      dontNotify
    );
  },

  _transformCoordinates: function(src, srcOff, dst, dstOff, numPts) {
    var i = srcOff, j = dstOff,
      srcEnd = srcOff + 2 * numPts;
    while (i < srcEnd) {
      var x = src[i++];
      var y = src[i++];
      dst[j++] = x * this._a + y * this._b + this._tx;
      dst[j++] = x * this._c + y * this._d + this._ty;
    }
    return dst;
  },

  _transformCorners: function(rect) {
    var x1 = rect.x,
      y1 = rect.y,
      x2 = x1 + rect.width,
      y2 = y1 + rect.height,
      coords = [ x1, y1, x2, y1, x2, y2, x1, y2 ];
    return this._transformCoordinates(coords, 0, coords, 0, 4);
  },

  /**
   * Returns the 'transformed' bounds rectangle by transforming each corner
   * point and finding the new bounding box to these points. This is not
   * really the transformed reactangle!
   */
  _transformBounds: function(bounds, dest, dontNotify) {
    var coords = this._transformCorners(bounds),
      min = coords.slice(0, 2),
      max = coords.slice(0);
    for (var i = 2; i < 8; i++) {
      var val = coords[i],
        j = i & 1;
      if (val < min[j])
        min[j] = val;
      else if (val > max[j])
        max[j] = val;
    }
    if (!dest)
      dest = new Rectangle(Rectangle.dont);
    return dest.set(min[0], min[1], max[0] - min[0], max[1] - min[1],
        dontNotify);
  },

  /**
   * Inverse transforms a point and returns the result.
   *
   * @param {Point} point The point to be transformed
   */
  inverseTransform: function(point) {
    return this._inverseTransform(Point.read(arguments));
  },

  /**
   * Returns the determinant of this transform, but only if the matrix is
   * reversible, null otherwise.
   */
  _getDeterminant: function() {
    var det = this._a * this._d - this._b * this._c;
    return isFinite(det) && Math.abs(det) > Numerical.EPSILON
        && isFinite(this._tx) && isFinite(this._ty)
        ? det : null;
  },

  _inverseTransform: function(point, dest, dontNotify) {
    var det = this._getDeterminant();
    if (!det)
      return null;
    var x = point.x - this._tx,
      y = point.y - this._ty;
    if (!dest)
      dest = new Point(Point.dont);
    return dest.set(
      (x * this._d - y * this._b) / det,
      (y * this._a - x * this._c) / det,
      dontNotify
    );
  },

  getTranslation: function() {
    return Point.create(this._tx, this._ty);
  },

  getScaling: function() {
    var hor = Math.sqrt(this._a * this._a + this._c * this._c),
      ver = Math.sqrt(this._b * this._b + this._d * this._d);
    return Point.create(this._a < 0 ? -hor : hor, this._b < 0 ? -ver : ver);
  },

  /**
   * The rotation angle of the matrix. If a non-uniform rotation is applied as
   * a result of a shear() or scale() command, undefined is returned, as the
   * resulting transformation cannot be expressed in one rotation angle.
   *
   * @type Number
   * @bean
   */
  getRotation: function() {
    var angle1 = -Math.atan2(this._b, this._d),
      angle2 = Math.atan2(this._c, this._a);
    return Math.abs(angle1 - angle2) < Numerical.TOLERANCE
        ? angle1 * 180 / Math.PI : undefined;
  },

  /**
   * Checks whether the two matrices describe the same transformation.
   *
   * @param {Matrix} matrix the matrix to compare this matrix to
   * @return {Boolean} {@true if the matrices are equal}
   */
  equals: function(mx) {
    return this._a == mx._a && this._b == mx._b && this._c == mx._c
        && this._d == mx._d && this._tx == mx._tx && this._ty == mx._ty;
  },

  /**
   * @return {Boolean} Whether this transform is the identity transform
   */
  isIdentity: function() {
    return this._a == 1 && this._c == 0 && this._b == 0 && this._d == 1
        && this._tx == 0 && this._ty == 0;
  },

  /**
   * Returns whether the transform is invertible. A transform is not
   * invertible if the determinant is 0 or any value is non-finite or NaN.
   *
   * @return {Boolean} Whether the transform is invertible
   */
  isInvertible: function() {
    return !!this._getDeterminant();
  },

  /**
   * Checks whether the matrix is singular or not. Singular matrices cannot be
   * inverted.
   *
   * @return {Boolean} Whether the matrix is singular
   */
  isSingular: function() {
    return !this._getDeterminant();
  },

  /**
   * Inverts the transformation of the matrix. If the matrix is not invertible
   * (in which case {@link #isSingular()} returns true), {@code null } is
   * returned.
   * 
   * @return {Matrix} The inverted matrix, or {@code null }, if the matrix is
   *         singular
   */
  createInverse: function() {
    var det = this._getDeterminant();
    return det && Matrix.create(
        this._d / det,
        -this._c / det,
        -this._b / det,
        this._a / det,
        (this._b * this._ty - this._d * this._tx) / det,
        (this._c * this._tx - this._a * this._ty) / det);
  },

  createShiftless: function() {
    return Matrix.create(this._a, this._c, this._b, this._d, 0, 0);
  },

  /**
   * Sets this transform to a scaling transformation.
   *
   * @param {Number} hor The horizontal scaling factor
   * @param {Number} ver The vertical scaling factor
   * @return {Matrix} This affine transform
   */
  setToScale: function(hor, ver) {
    return this.set(hor, 0, 0, ver, 0, 0);
  },

  /**
   * Sets this transform to a translation transformation.
   *
   * @param {Number} dx The distance to translate in the x direction
   * @param {Number} dy The distance to translate in the y direction
   * @return {Matrix} This affine transform
   */
  setToTranslation: function(delta) {
    delta = Point.read(arguments);
    return this.set(1, 0, 0, 1, delta.x, delta.y);
  },

  /**
   * Sets this transform to a shearing transformation.
   *
   * @param {Number} hor The horizontal shear factor
   * @param {Number} ver The vertical shear factor
   * @return {Matrix} This affine transform
   */
  setToShear: function(hor, ver) {
    return this.set(1, ver, hor, 1, 0, 0);
  },

  /**
   * Sets this transform to a rotation transformation.
   *
   * @param {Number} angle The angle of rotation measured in degrees
   * @param {Number} x The x coordinate of the anchor point
   * @param {Number} y The y coordinate of the anchor point
   * @return {Matrix} This affine transform
   */
  setToRotation: function(angle, center) {
    center = Point.read(arguments, 1);
    angle = angle * Math.PI / 180;
    var x = center.x,
      y = center.y,
      cos = Math.cos(angle),
      sin = Math.sin(angle);
    return this.set(cos, sin, -sin, cos,
        x - x * cos + y * sin,
        y - x * sin - y * cos);
  },

  /**
   * Applies this matrix to the specified Canvas Context.
   *
   * @param {CanvasRenderingContext2D} ctx
   * @param {Boolean} [reset=false]
   */
  applyToContext: function(ctx, reset) {
    ctx[reset ? 'setTransform' : 'transform'](
        this._a, this._c, this._b, this._d, this._tx, this._ty);
    return this;
  },

  statics: /** @lends Matrix */{
    // See Point.create()
    create: function(a, c, b, d, tx, ty) {
      return new Matrix(Matrix.dont).set(a, c, b, d, tx, ty);
    },

    /**
     * Creates a transform representing a scaling transformation.
     *
     * @param {Number} hor The horizontal scaling factor
     * @param {Number} ver The vertical scaling factor
     * @return {Matrix} A transform representing a scaling
     *         transformation
     */
    getScaleInstance: function(hor, ver) {
      var mx = new Matrix();
      return mx.setToScale.apply(mx, arguments);
    },

    /**
     * Creates a transform representing a translation transformation.
     *
     * @param {Number} dx The distance to translate in the x direction
     * @param {Number} dy The distance to translate in the y direction
     * @return {Matrix} A transform representing a translation
     *         transformation
     */
    getTranslateInstance: function(delta) {
      var mx = new Matrix();
      return mx.setToTranslation.apply(mx, arguments);
    },

    /**
     * Creates a transform representing a shearing transformation.
     *
     * @param {Number} hor The horizontal shear factor
     * @param {Number} ver The vertical shear factor
     * @return {Matrix} A transform representing a shearing transformation
     */
    getShearInstance: function(hor, ver, center) {
      var mx = new Matrix();
      return mx.setToShear.apply(mx, arguments);
    },

    /**
     * Creates a transform representing a rotation transformation.
     *
     * @param {Number} angle The angle of rotation measured in degrees
     * @param {Number} x The x coordinate of the anchor point
     * @param {Number} y The y coordinate of the anchor point
     * @return {Matrix} A transform representing a rotation transformation
     */
    getRotateInstance: function(angle, center) {
      var mx = new Matrix();
      return mx.setToRotation.apply(mx, arguments);
    }
  }
}, new function() {
  return Base.each({
    scaleX: '_a',
    scaleY: '_d',
    translateX: '_tx',
    translateY: '_ty',
    shearX: '_b',
    shearY: '_c'
  }, function(prop, name) {
    name = Base.capitalize(name);
    this['get' + name] = function() {
      return this[prop];
    };
    this['set' + name] = function(value) {
      this[prop] = value;
    };
  }, {});
});
