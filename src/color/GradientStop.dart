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

// TODO: Support midPoint? (initial tests didn't look nice)
/**
 * @name GradientStop
 *
 * @class The GradientStop object.
 */
class GradientStop {
  /**
   * Creates a GradientStop object.
   *
   * @param {Color} [color=new RgbColor(0, 0, 0)] the color of the stop
   * @param {Number} [rampPoint=0] the position of the stop on the gradient
   *                               ramp {@default 0}
   */
  GradientStop(arg0, arg1) {
    _owners = [];
    if (arg1 == null && arg0 is List) {
      // [color, rampPoint]
      setColor(arg0[0]);
      setRampPoint(arg0[1]);
    } else if (arg0.color != null) {
      // stop
      setColor(arg0.color);
      setRampPoint(arg0.rampPoint);
    } else {
      // color [, rampPoint]
      setColor(arg0);
      setRampPoint(arg1);
    }
  }

  // TODO: Do we really need to also clone the color here?
  /**
   * @return {GradientColor} a copy of the gradient-stop
   */
  GradientStop clone() {
    return new GradientStop(_color.clone(), _rampPoint);
  }

  /**
   * Called by various setters whenever a value changes
   */
  void _changed() {
    // Loop through the gradients that use this stop and notify them about
    // the change, so they can notify their gradient colors, which in turn
    // will notify the items they are used in:
    //for (var i = 0, l = _owners && _owners.length; i < l; i++)
    for(var owner in _owners) {
      //_owners[i]._changed(Change.STYLE);
      owner._changed(Change.STYLE);
    }
  }

  List _owners;
  /**
   * Called by Gradient whenever this stop is used. This is required to pass 
   * on _changed() notifications to the _owners.
   */
  void _addOwner(gradient) {
    //if (_owners == null)
      //_owners = [];
    _owners.add(gradient);
  }

  /**
   * Called by Gradient whenever this GradientStop is no longer used by it.
   */
  void _removeOwner(gradient) {
    var index = _owners != null ? _owners.indexOf(gradient) : -1;
    if (index != -1) {
      _owners.removeRange(index, 1);
      // TODO why set this to null?
      //if (_owners.length == 0)
      //  _owners = null;
    }
  }


  /**
   * The ramp-point of the gradient stop as a value between {@code 0} and
   * {@code 1}.
   *
   * @type Number
   * @bean
   *
   * @example {@paperscript height=300}
   * // Animating a gradient's ramp points:
   *
   * // Create a circle shaped path at the center of the view,
   * // using 40% of the height of the view as its radius
   * // and fill it with a radial gradient color:
   * var path = new Path.Circle(view.center, view.bounds.height * 0.4);
   *
   * // Prepare the gradient color and apply it to the path:
   * var colors = [['yellow', 0.05], ['red', 0.2], ['black', 1]];
   * var gradient = new Gradient(colors, 'radial');
   * var from = path.position;
   * var to = path.bounds.rightCenter;
   * var gradientColor = new GradientColor(gradient, from, to);
   * path.fillColor = gradientColor;
   *
   * // This function is called each frame of the animation:
   * function onFrame(event) {
   *   var blackStop = gradient.stops[2];
   *   // Animate the rampPoint between 0.7 and 0.9:
   *   blackStop.rampPoint = Math.sin(event.time * 5) * 0.1 + 0.8;
   *
   *   // Animate the rampPoint between 0.2 and 0.4
   *   var redStop = gradient.stops[1];
   *   redStop.rampPoint = Math.sin(event.time * 3) * 0.1 + 0.3;
   * }
   */
  num _rampPoint;
  num getRampPoint() {
    return _rampPoint;
  }
  // property
  num get rampPoint() => _rampPoint;

  void setRampPoint([num rampPoint]) {
    // TODO this is unused in the paper.js version
    // TODO fix and submit a pull request
    _rampPoint = rampPoint == null ? 0 : rampPoint;
    _changed();
  }
  // property
  set rampPoint(num value) => setRampPoint(value);

  /**
   * The color of the gradient stop.
   *
   * @type Color
   * @bean
   *
   * @example {@paperscript height=300}
   * // Animating a gradient's ramp points:
   *
   * // Create a circle shaped path at the center of the view,
   * // using 40% of the height of the view as its radius
   * // and fill it with a radial gradient color:
   * var path = new Path.Circle(view.center, view.bounds.height * 0.4);
   *
   * // Create a radial gradient that mixes red and black evenly:
   * var gradient = new Gradient(['red', 'black'], 'radial');
   *
   * // Fill the path with a gradient color that runs from its center,
   * // to the right center of its bounding rectangle:
   * var from = path.position;
   * var to = path.bounds.rightCenter;
   * var gradientColor = new GradientColor(gradient, from, to);
   * path.fillColor = gradientColor;
   *
   * // This function is called each frame of the animation:
   * function onFrame(event) {
   *   // Change the hue of the first stop's color:
   *   gradient.stops[0].color.hue += 1;
   * }
   */
  Color _color;
  Color getColor() {
    return _color;
  }

  void setColor(Color color) {
    // If the stop already contained a color,
    // remove it as an owner:
    if (_color != null)
      _color._removeOwner(this);
    _color = Color.read(color);
    _color._addOwner(this);
    _changed();
  }

  bool equals(GradientStop stop) {
    return stop === this || stop is GradientStop
        && _color.equals(stop._color)
        && _rampPoint == stop._rampPoint;
  }
}
