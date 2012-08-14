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
 * @name Gradient
 *
 * @class The Gradient object.
 */
class Gradient {
  // TODO: Should type here be called 'radial' and have it receive a
  // boolean value?
  /**
   * Creates a gradient object
   *
   * @param {GradientStop[]} stops
   * @param {String} [type='linear'] 'linear' or 'radial'
   */
  Gradient([List stops, type]) {
    _owners = [];
    setStops(stops == null ? ['white', 'black'] : stops);
    _type = type == null ? 'linear' : type;
  }
  
  String _type;
  // property
  String get type() => _type;
  set type(String value) => _type = value;

  /**
   * Called by various setters whenever a gradient value changes
   */
  void _changed() {
    // Loop through the gradient-colors that use this gradient and notify
    // them, so they can notify the items they belong to.
    for(var owner in _owners)
      owner._changed();
  }

  List _owners;
  /**
   * Called by GradientColor#initialize
   * This is required to pass on _changed() notifications to the _owners.
   */
  void _addOwner(color) {
    _owners.add(color);
  }

  // TODO: Where and when should this be called:
  /**
   * Called by GradientColor whenever this gradient stops being used.
   */
  void _removeOwner(color) {
    var index = _owners.indexOf(color);
    if (index != -1) {
      _owners.removeRange(index, 1);
    }
  }

  /**
   * @return {Gradient} a copy of the gradient
   */
  Gradient clone() {
    var stops = [];
    for(var stop in _stops) {
      stops.add(stop.clone());
    }
    return new Gradient(stops, _type);
  }

  List<GradientStop> _stops;
  /**
   * The gradient stops on the gradient ramp.
   *
   * @type GradientStop[]
   * @bean
   */
  List<GradientStop> getStops() {
    return _stops;
  }

  void setStops(List stops) {
    // If this gradient already contains stops, first remove
    // this gradient as their owner.
    if (_stops != null) {
      for(var stop in _stops) {
        stop._removeOwner(this);
      }
    }
    if (stops.length < 2)
      throw new Exception(
          'Gradient stop list needs to contain at least two stops.');
    _stops = GradientStop.readAll(stops);
    // Now reassign ramp points if they were not specified.
    for (var i = 0, l = _stops.length; i < l; i++) {
      var stop = _stops[i];
      stop._addOwner(this);
      if (stop.defaultRamp)
        stop.setRampPoint(i / (l - 1));
    }
    _changed();
  }

  /**
   * Checks whether the gradient is equal to the supplied gradient.
   *
   * @param {Gradient} gradient
   * @return {Boolean} {@true they are equal}
   */
  bool equals(Gradient gradient) {
    if (gradient._type != _type)
      return false;
    if (_stops.length == gradient._stops.length) {
      for (var i = 0, l = _stops.length; i < l; i++) {
        if (!_stops[i].equals(gradient._stops[i]))
          return false;
      }
      return true;
    }
    return false;
  }
}