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
 * @name GradientColor
 *
 * @class The GradientColor object.
 */
class GradientColor extends Color {

  /**
   * Creates a gradient color object.
   *
   * @param {Gradient} gradient
   * @param {Point} origin
   * @param {Point} destination
   * @param {Point} [hilite]
   *
   * @example {@paperscript height=200}
   * // Applying a linear gradient color containing evenly distributed
   * // color stops:
   *
   * // Define two points which we will be using to construct
   * // the path and to position the gradient color:
   * var topLeft = view.center - [80, 80];
   * var bottomRight = view.center + [80, 80];
   *
   * // Create a rectangle shaped path between
   * // the topLeft and bottomRight points:
   * var path = new Path.Rectangle(topLeft, bottomRight);
   *
   * // Create the gradient, passing it an array of colors to be converted
   * // to evenly distributed color stops:
   * var gradient = new Gradient(['yellow', 'red', 'blue']);
   *
   * // Have the gradient color run between the topLeft and
   * // bottomRight points we defined earlier:
   * var gradientColor = new GradientColor(gradient, topLeft, bottomRight);
   *
   * // Set the fill color of the path to the gradient color:
   * path.fillColor = gradientColor;
   *
   * @example {@paperscript height=200}
   * // Applying a radial gradient color containing unevenly distributed
   * // color stops:
   *
   * // Create a circle shaped path at the center of the view
   * // with a radius of 80:
   * var path = new Path.Circle(view.center, 80);
   *
   * // The stops array: yellow mixes with red between 0 and 15%,
   * // 15% to 30% is pure red, red mixes with black between 30% to 100%:
   * var stops = [['yellow', 0], ['red', 0.15], ['red', 0.3], ['black', 0.9]];
   *
   * // Create a radial gradient using the color stops array:
   * var gradient = new Gradient(stops, 'radial');
   *
   * // We will use the center point of the circle shaped path as
   * // the origin point for our gradient color
   * var from = path.position;
   *
   * // The destination point of the gradient color will be the
   * // center point of the path + 80pt in horizontal direction:
   * var to = path.position + [80, 0];
   *
   * // Create the gradient color:
   * var gradientColor = new GradientColor(gradient, from, to);
   *
   * // Set the fill color of the path to the gradient color:
   * path.fillColor = gradientColor;
   */
  GradientColor(Gradient gradient, origin, destination, hilite) {
    gradient = gradient == null ? new Gradient() : gradient;
    gradient._addOwner(this);
    setOrigin(origin);
    setDestination(destination);
    if (hilite)
      setHilite(hilite);
  }

  Gradient _gradient;

  /**
   * @return {GradientColor} a copy of the gradient color
   */
  GradientColor clone() {
    return new GradientColor(_gradient, _origin, _destination,
        _hilite);
  }

  /**
   * The origin point of the gradient.
   *
   * @type Point
   * @bean
   *
   * @example {@paperscript height=200}
   * // Move the origin point of the gradient, by moving your mouse over
   * // the view below:
   *
   * // Create a rectangle shaped path with the same dimensions as
   * // that of the view and fill it with a gradient color:
   * var path = new Path.Rectangle(view.bounds);
   * var gradient = new Gradient(['yellow', 'red', 'blue']);
   *
   * // Have the gradient color run from the top left point of the view,
   * // to the bottom right point of the view:
   * var from = view.bounds.topLeft;
   * var to = view.bounds.bottomRight;
   * var gradientColor = new GradientColor(gradient, from, to);
   * path.fillColor = gradientColor;
   *
   * function onMouseMove(event) {
   *   // Set the origin point of the path's gradient color
   *   // to the position of the mouse:
   *   path.fillColor.origin = event.point;
   * }
   *
   */
  Point _origin;
  Point getOrigin() {
    return _origin;
  }

  GradientColor setOrigin(/*Point*/ origin) {
    // PORT: Add clone to Scriptographer
    origin = Point.read(origin).clone();
    _origin = origin;
    if (_destination != null)
      _radius = _destination.getDistance(this._origin);
    _changed();
    return this;
  }

  /**
   * The destination point of the gradient.
   *
   * @type Point
   * @bean
   *
   * @example {@paperscript height=300}
   * // Move the destination point of the gradient, by moving your mouse over
   * // the view below:
   *
   * // Create a circle shaped path at the center of the view,
   * // using 40% of the height of the view as its radius
   * // and fill it with a radial gradient color:
   * var path = new Path.Circle(view.center, view.bounds.height * 0.4);
   *
   * var gradient = new Gradient(['yellow', 'red', 'black'], 'radial');
   * var from = view.center;
   * var to = view.bounds.bottomRight;
   * var gradientColor = new GradientColor(gradient, from, to);
   * path.fillColor = gradientColor;
   *
   * function onMouseMove(event) {
   *   // Set the origin point of the path's gradient color
   *   // to the position of the mouse:
   *   path.fillColor.destination = event.point;
   * }
   */
  Point _destination;
  Point getDestination() {
    return _destination;
  }

  GradientColor setDestination(/*Point*/ destination) {
    // PORT: Add clone to Scriptographer
    destination = Point.read(destination).clone();
    _destination = destination;
    _radius = _destination.getDistance(_origin);
    _changed();
    return this;
  }
  
  num _radius;

  /**
   * The hilite point of the gradient.
   *
   * @type Point
   * @bean
   *
   * @example {@paperscript height=300}
   * // Move the hilite point of the gradient, by moving your mouse over
   * // the view below:
   *
   * // Create a circle shaped path at the center of the view,
   * // using 40% of the height of the view as its radius
   * // and fill it with a radial gradient color:
   * var path = new Path.Circle(view.center, view.bounds.height * 0.4);
   * var gradient = new Gradient(['yellow', 'red', 'black'], 'radial');
   * var from = path.position;
   * var to = path.bounds.rightCenter;
   * var gradientColor = new GradientColor(gradient, from, to);
   * path.fillColor = gradientColor;
   *
   * function onMouseMove(event) {
   *   // Set the origin hilite of the path's gradient color
   *   // to the position of the mouse:
   *   path.fillColor.hilite = event.point;
   * }
   */
  
  Point _hilite;
  
  Point getHilite() {
    return _hilite;
  }

  GradientColor setHilite(/*Point*/ hilite) {
    // PORT: Add clone to Scriptographer
    hilite = Point.read(hilite).clone();
    var vector = hilite.subtract(_origin);
    if (vector.getLength() > _radius) {
      _hilite = _origin.add(
          vector.normalize(_radius - 0.1));
    } else {
      _hilite = hilite;
    }
    _changed();
    return this;
  }

  getCanvasStyle([ctx]) {
    // TODO made ctx optional so we can override Color.getCanvasStyle,
    // but it is really required
    if(ctx == null) return null;
    var gradient;
    if (_gradient.type === 'linear') {
      gradient = ctx.createLinearGradient(_origin.x, _origin.y,
          _destination.x, _destination.y);
    } else {
      var origin = _hilite == null ? _origin : _hilite;
      gradient = ctx.createRadialGradient(origin.x, origin.y,
          0, _origin.x, _origin.y, _radius);
    }
    for (var i = 0, l = _gradient._stops.length; i < l; i++) {
      var stop = _gradient._stops[i];
      gradient.addColorStop(stop._rampPoint, stop._color.toCssString());
    }
    return gradient;
  }

  /**
   * Checks if the gradient color has the same properties as that of the
   * supplied one.
   *
   * @param {GradientColor} color
   * @return {@true the GradientColor is the same}
   */
  bool equals(color) {
    return color === this || color && color._type === _type
        && _gradient.equals(color.gradient)
        && _origin.equals(color._origin)
        && _destination.equals(color._destination);
  }

  /**
   * Transform the gradient color by the specified matrix.
   *
   * @param {Matrix} matrix the matrix to transform the gradient color by
   */
  void transform(matrix) {
    matrix._transformPoint(_origin, _origin, true);
    matrix._transformPoint(_destination, _destination, true);
    if (_hilite != null)
      matrix._transformPoint(_hilite, _hilite, true);
    _radius = _destination.getDistance(_origin);
  }
}

