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
 * @name SegmentPoint
 * @class An internal version of Point that notifies its segment of each change
 * Note: This prototype is not exported.
 *
 * @private
 */
class SegmentPoint extends Point {
  Object _owner;

  SegmentPoint set(num x, num y) {
    this._x = x;
    this._y = y;
    _changed(this);
    //this._owner._changed(this);
    return this;
  }

  // TODO Point should have this already
//  getX: function() {
//    return this._x;
//  }

  setX(num x) {
    _x = x;
    //this._owner._changed(this);
    _changed(this);
  }

  // TODO Point should already have this
//  getY: function() {
//    return this._y;
//  }

  setY(num y) {
    _y = y;
    //this._owner._changed(this);
    _changed(this);
  }

  bool isZero() {
    // Provide our own version of Point#isZero() that does not use the x / y
    // accessors but the internal properties directly, for performance
    // reasons, since it is used a lot internally.

    // TODO why not just make normal implementation work this way?
    return _x == 0 && _y == 0;
  }

  setSelected(bool selected) {
    // TODO I don't think we can access _setSelected on the owner from here
    _owner._setSelected(this, selected);
  }

  bool isSelected() {
    // TODO I don't think we can access _isSelected on the owner from here
    return _owner._isSelected(this);
  }

  SegmentPoint.create(Segment segment, key, [/*Point*/ point]) {
    var x, y, selected;
    if(point == null) {
      x = y = 0;
    } else if(point is List) {
      x = point[0];
      y = point[1];
    } else {
      // TODO read point from other arguments
      // If not Point-link already, read Point from pt = 3rd argument
      point = Point.read(point);
      x = point.x;
      y = point.y;
      selected = point.selected;
    }
    _x = x;
    _y = y;
    _owner = segment;
    // We need to set the point on the segment before copying over the
    // selected state, as otherwise this won't actually select it.
    segment[key] = this;
    if(selected) setSelected(true);
  }
}
