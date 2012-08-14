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
#library("Segment.dart");
#import("../basic/Basic.dart");
#source("SegmentPoint.dart");
#source("SelectionState.dart");

/**
 * @name Segment
 *
 * @class The Segment object represents the points of a path through which its
 * {@link Curve} objects pass. The segments of a path can be accessed through
 * its {@link Path#segments} array.
 *
 * Each segment consists of an anchor point ({@link Segment#point}) and
 * optionaly an incoming and an outgoing handle ({@link Segment#handleIn} and
 * {@link Segment#handleOut}), describing the tangents of the two {@link Curve}
 * objects that are connected by this segment.
 */
class Segment {
  Path _path;
  /**
   * Creates a new Segment object.
   *
   * @param {Point} [point={x: 0, y: 0}] the anchor point of the segment
   * @param {Point} [handleIn={x: 0, y: 0}] the handle point relative to the
   *        anchor point of the segment that describes the in tangent of the
   *        segment.
   * @param {Point} [handleOut={x: 0, y: 0}] the handle point relative to the
   *        anchor point of the segment that describes the out tangent of the
   *        segment.
   *
   * @example {@paperscript}
   * var handleIn = new Point(-80, -100);
   * var handleOut = new Point(80, 100);
   *
   * var firstPoint = new Point(100, 50);
   * var firstSegment = new Segment(firstPoint, null, handleOut);
   *
   * var secondPoint = new Point(300, 50);
   * var secondSegment = new Segment(secondPoint, handleIn, null);
   *
   * var path = new Path(firstSegment, secondSegment);
   * path.strokeColor = 'black';
   */
  Segment([arg0, arg1, arg2, arg3, arg4, arg5]) {
    var point, handleIn, handleOut;
    if(arg0 != null) {
      if(arg1 == null) {
        if(arg0 is Map && arg0.containsKey("point")) {
          point = arg0["point"];
          handleIn = arg0["handleIn"];
          handleOut = arg0["handleOut"];
        } else {
          point = arg0;
        }
      } else if(arg5 == null) {
        // TODO arg2 below was arg3 in paper.js, I'm pretty sure that's incorrect
        // TODO fix and submit a pull request to paper.js
        if(arg2 == null) { 
          point = new Point(arg0, arg1);
        } else {
          point = arg0;
          handleIn = arg1;
          handleOut = arg2;
        }
      } else {
        point = new Point(arg0, arg1);
        handleIn = new Point(arg2, arg3);
        handleOut = new Point(arg4, arg5);
      }
    }
    new SegmentPoint.create(this, "point", point);
    new SegmentPoint.create(this, "handleIn", handleIn);
    new SegmentPoint.create(this, "handleOut", handleOut);
  }

  // TODO I have no idea what is going on in this function
  _changed(Point point) {
    if (!this._path)
      return;
    // Delegate changes to affected curves if they exist
    var curve = this._path._curves && this.getCurve(), other;
    if (curve) {
      curve._changed();
      // Get the other affected curve, which is the previous one for
      // _point or _handleIn changing when this segment is _segment1 of
      // the curve, for all other cases it's the next (e.g. _handleOut
      // when this segment is _segment2)
      if (other = (curve[point === this._point
          || point === this._handleIn && curve._segment1 === this
          ? 'getPrevious' : 'getNext']())) {
        other._changed();
      }
    }
    this._path._changed(Change.GEOMETRY);
  }

  /**
   * The anchor point of the segment.
   *
   * @type Point
   * @bean
   */
  SegmentPoint _point;
  SegmentPoint getPoint() {
    return _point;
  }
  // property
  SegmentPoint get point() => getPoint();

  setPoint(/*Point*/ point) {
    point = Point.read(point);
    // Do not replace the internal object but update it instead, so
    // references to it are kept alive.
    _point.set(point.x, point.y);
  }
  // property
  set point(Point value) => setPoint(value);

  /**
   * The handle point relative to the anchor point of the segment that
   * describes the in tangent of the segment.
   *
   * @type Point
   * @bean
   */
  SegmentPoint _handleIn;
  SegmentPoint getHandleIn() {
    return _handleIn;
  }
  // property
  SegmentPoint get handleIn() => getHandleIn();

  setHandleIn(/*Point*/ point) {
    point = Point.read(point);
    // See #setPoint:
    _handleIn.set(point.x, point.y);
    // Update corner accordingly
    // this.corner = !this._handleIn.isColinear(this._handleOut);
    // TODO I didn't comment the above line out, paper.js did
  }
  // property
  set handleIn(Point value) => setHandleIn(value);

  /**
   * The handle point relative to the anchor point of the segment that
   * describes the out tangent of the segment.
   *
   * @type Point
   * @bean
   */
  SegmentPoint _handleOut;
  SegmentPoint getHandleOut() {
    return _handleOut;
  }
  // property
  SegmentPoint get handleOut() => getHandleOut();

  setHandleOut(/*Point*/ point) {
    point = Point.read(point);
    // See #setPoint:
    _handleOut.set(point.x, point.y);
    // Update corner accordingly
    // this.corner = !this._handleIn.isColinear(this._handleOut);
    // TODO I didn't comment the above line out, paper.js did
  }
  // property
  set handleOut(Point value) => setHandleOut(value);

  int _selectionState;
  bool _isSelected(SegmentPoint point) {
    var state = this._selectionState;
    // TODO check operator precedence
    return point === _point ? (state & SelectionState.POINT) != 0
      : point === _handleIn ? (state & SelectionState.HANDLE_IN) != 0
      : point === _handleOut ? (state & SelectionState.HANDLE_OUT) != 0
      : false;
  }

  _setSelected(SegmentPoint point, bool selected) {
    var path = this._path;
    // TODO does anything call this with a non-bool?
    //selected = !!selected, // convert to boolean
    int state = _selectionState;
    // For performance reasons use array indices to access the various
    // selection states: 0 = point, 1 = handleIn, 2 = handleOut
    // TODO fix missing var declaration and submit pull request on paper.js
    var selection = [
      (state & SelectionState.POINT) != 0,
      (state & SelectionState.HANDLE_IN) != 0,
      (state & SelectionState.HANDLE_OUT) != 0
    ];
    if (point === this._point) {
      if (selected) {
        // We're selecting point, deselect the handles
        selection[1] = selection[2] = false;
      } else {
        var previous = getPrevious();
        var next = getNext();
        // When deselecting a point, the handles get selected instead
        // depending on the selection state of their neighbors.
        selection[1] = previous && (previous._point.isSelected()
            || previous._handleOut.isSelected());
        selection[2] = next && (next._point.isSelected()
            || next._handleIn.isSelected());
      }
      selection[0] = selected;
    } else {
      var index = point === this._handleIn ? 1 : 2;
      if (selection[index] != selected) {
        // When selecting handles, the point get deselected.
        if (selected)
          selection[0] = false;
        selection[index] = selected;
        // Let path know that we changed something and the view
        // should be redrawn
        path._changed(Change.ATTRIBUTE);
      }
    }
    this._selectionState = (selection[0] ? SelectionState.POINT : 0)
        | (selection[1] ? SelectionState.HANDLE_IN : 0)
        | (selection[2] ? SelectionState.HANDLE_OUT : 0);
    // If the selection state of the segment has changed, we need to let
    // it's path know and possibly add or remove it from
    // project._selectedItems
    if (path != null && state != this._selectionState)
      path._updateSelection(this, state, this._selectionState);
  }



  /**
   * Specifies whether the {@link #point} of the segment is selected.
   * @type Boolean
   * @bean
   */
  bool isSelected() {
    return _isSelected(_point);
  }
  // property
  bool get selected() => isSelected();

  setSelected(bool selected) {
    _setSelected(_point, selected);
  }
  // property
  set selected(bool value) => setSelected(value);

  /**
   * {@grouptitle Hierarchy}
   *
   * The index of the segment in the {@link Path#segments} array that the
   * segment belongs to.
   *
   * @type Number
   * @bean
   */
  int _index;
  int getIndex() {
    return _index;
  }
  // property
  int get index() => getIndex();

  /**
   * The path that the segment belongs to.
   *
   * @type Path
   * @bean
   */
  Path getPath() {
    return this._path;
  }
  // property
  Path get path() => getPath();

  /**
   * The curve that the segment belongs to.
   *
   * @type Curve
   * @bean
   */
  Curve getCurve() {
    if (_path != null) {
      var index = _index;
      // The last segment of an open path belongs to the last curve
      if (!this._path._closed && index == this._path._segments.length - 1)
        index--;
      // TODO check list length?
      return _path.getCurves()[index];
    }
    return null;
  }
  // property
  Curve get curve() => getCurve();

  /**
   * {@grouptitle Sibling Segments}
   *
   * The next segment in the {@link Path#segments} array that the segment
   * belongs to. If the segments belongs to a closed path, the first segment
   * is returned for the last segment of the path.
   *
   * @type Segment
   * @bean
   */
  Segment getNext() {
    if(_path != null) {
      var segments = _path._segments;
      if(segments != null) {
        if(segments.length > _index + 1) {
          return segments[_index + 1];
        } else {
          if(_path.closed) {
            return segments[0];
          }
        }
      }
    }
    return null;
  }

  /**
   * The previous segment in the {@link Path#segments} array that the
   * segment belongs to. If the segments belongs to a closed path, the last
   * segment is returned for the first segment of the path.
   *
   * @type Segment
   * @bean
   */
  getPrevious() {
    if(_path != null) {
      var segments = _path._segments;
      if(segments != null) {
        if(_index - 1 >= 0) {
          return segments[_index - 1];
        } else if(_path.closed) {
          // TODO fix segements typo and submit pull request on paper.js
          return segments[segments.length - 1];
        }
      }
    }
    return null;
  }

  /**
   * Returns the reversed the segment, without modifying the segment itself.
   * @return {Segment} the reversed segment
   */
  Segment reverse() {
    return new Segment(this._point, this._handleOut, this._handleIn);
  }

  /**
   * Removes the segment from the path that it belongs to.
   */
  bool remove() {
    // TODO does Path.removeSegment return a bool?
    return _path != null ? _path.removeSegment(_index) : false;
  }

  Segment clone() {
    return new Segment(_point, _handleIn, _handleOut);
  }

  bool equals(Segment segment) {
    return _point.equals(segment._point)
        && _handleIn.equals(segment._handleIn)
        && _handleOut.equals(segment._handleOut);
  }
  // operator
  bool operator == (Segment segment) => equals(segment);
  
  // access the properties by key
  Point operator[] (String key) {
    if(key == "point") return _point;
    if(key == "handleIn") return _handleIn;
    if(key == "handleOut") return _handleOut;
    return null;
  }
  // TODO this requires a SegmentPoint now
  // we should allow a Point (or Point-like) and build a SegmentPoint if we need to
  void operator[]= (String key, SegmentPoint point) {
    if(key == "point") _point = point;
    if(key == "handleIn") _handleIn = point;
    if(key == "handleOut") _handleOut = point;
  }
  

  /**
   * @return {String} A string representation of the segment.
   */
  String toString() {
    var sb = new StringBuffer();
    sb.add("{ point: ${_point}");
    if(_handleIn != null && !_handleIn.isZero()) {
      sb.add(", handleIn: ${_handleIn}");
    }
    if(_handleOut != null && !_handleOut.isZero()) {
      sb.add(", handleOut: ${_handleOut}");
    }
    sb.add(" }");
    return sb.toString();
  }

  _transformCoordinates(Matrix matrix, coords, bool change) {
    // Use matrix.transform version() that takes arrays of multiple
    // points for largely improved performance, as no calls to
    // Point.read() and Point constructors are necessary.
    Point point = this._point;
    // If change is true, only transform handles if they are set, as
    // _transformCoordinates is called only to change the segment, no
    // to receive the coords.
    // This saves some computation time. If change is false, always
    // use the real handles, as we just want to receive a filled
    // coords array for getBounds().
    Point handleIn =  !change || !this._handleIn.isZero()
        ? this._handleIn : null;
    Point handleOut = !change || !this._handleOut.isZero()
        ? this._handleOut : null;
    num x = point._x;
    num y = point._y;
    num i = 2;
    coords[0] = x;
    coords[1] = y;
    // We need to convert handles to absolute coordinates in order
    // to transform them.
    if (handleIn != null) {
      coords[i++] = handleIn._x + x;
      coords[i++] = handleIn._y + y;
    }
    if (handleOut != null) {
      coords[i++] = handleOut._x + x;
      coords[i++] = handleOut._y + y;
    }
    // TODO submit typod "previded" fix to paper.js
    // If no matrix was previded, this was just called to get the coords and
    // we are done now.
    if (matrix == null)
      return;
    matrix.transformCoordinates(coords, 0, coords, 0, (i / 2).toInt());
    x = coords[0];
    y = coords[1];
    if (change) {
      // If change is true, we need to set the new values back
      point._x = x;
      point._y = y;
      // TODO submit fix for extra space to paper.js
      i = 2;
      if (handleIn != null) {
        handleIn._x = coords[i++] - x;
        handleIn._y = coords[i++] - y;
      }
      if (handleOut != null) {
        handleOut._x = coords[i++] - x;
        handleOut._y = coords[i++] - y;
      }
    } else {
      // We want to receive the results in coords, so make sure
      // handleIn and out are defined too, even if they're 0
      if (handleIn == null) {
        coords[i++] = x;
        coords[i++] = y;
      }
      if (handleOut == null) {
        coords[i++] = x;
        coords[i++] = y;
      }
    }
  }
}
