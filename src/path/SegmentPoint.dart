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
  Segment _owner;

  SegmentPoint setFromPoint(Point point) {
    super.setX(point.x);
    super.setY(point.y);
    _owner._changed(this);
    return this;
  }
  SegmentPoint set(num x, num y) {
    super.setX(x);
    super.setY(y);
    _owner._changed(this);
    return this;
  }

  setX(num x) {
    super.setX(x);
    _owner._changed(this);
  }
  set x(num value) => setX(value);

  setY(num y) {
    super.setY(y);
    _owner._changed(this);
  }

  setSelected(bool selected) {
    // TODO I don't think we can access _setSelected on the owner from here
    _owner._setSelected(this, selected);
  }
  // property
  set selected(bool value) => setSelected(value);

  bool isSelected() {
    // TODO I don't think we can access _isSelected on the owner from here
    return _owner._isSelected(this);
  }
  // property
  bool get selected => isSelected();

  SegmentPoint.create(Segment segment, key, [/*Point*/ point]) {
    num x, y;
    bool selected = false;
    if(point == null) {
      x = y = 0;
    } else if(point is List) {
      x = point[0];
      y = point[1];
    } else {
      // TODO read point from other arguments
      // If not Point-like already, read Point from pt = 3rd argument
      point = Point.read(point);
      x = point.x;
      y = point.y;
      // only get selected if it is a SegmentPoint
      if(point is SegmentPoint) {
        selected = point.selected;
      } else {
        selected = false;
      }
    }
    super.setX(x);
    super.setY(y);
    _owner = segment;
    // We need to set the point on the segment before copying over the
    // selected state, as otherwise this won't actually select it.
    segment[key] = this;
    if(selected) setSelected(true);
  }
}
