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
library Path;
import "../basic/Basic.dart";
import "../item/Item.dart";
import "../util/Numerical.dart";
import "../item/ChangeFlag.dart";
import "dart:math";
part "Segment.dart";
part "SegmentPoint.dart";
part "SelectionState.dart";
part "CurveLocation.dart";
part "Curve.dart";
part "PathItem.dart";
part "PathFitter.dart";
part "PathFlattener.dart";

/**
 * @name Path
 *
 * @class The Path item represents a path in a Paper.js project.
 *
 * @extends PathItem
 */
// DOCS: Explain that path matrix is always applied with each transformation.
class Path extends PathItem {
  /**
   * Creates a new Path item and places it at the top of the active layer.
   *
   * @param {Segment[]} [segments] An array of segments (or points to be
   * converted to segments) that will be added to the path.
   *
   * @example
   * // Create an empty path and add segments to it:
   * var path = new Path();
   * path.strokeColor = 'black';
   * path.add(new Point(30, 30));
   * path.add(new Point(100, 100));
   *
   * @example
   * // Create a path with two segments:
   * var segments = [new Point(30, 30), new Point(100, 100)];
   * var path = new Path(segments);
   * path.strokeColor = 'black';
   */
  int _selectedSegmentState = 0;
  Path(List segments) : super() {
    _closed = false;
    //_selectedSegmentState = 0;
    // Support both passing of segments as array or arguments
    // If it is an array, it can also be a description of a point, so
    // check its first entry for object as well
    //this.setSegments(!segments || !Array.isArray(segments)
    //    || typeof segments[0] !== 'object' ? arguments : segments);
    // TODO support for segments as arguments instead of a list
    setSegments(segments);
  }

  Path clone() {
    Path copy = cloneTo(new Path(_segments));
    copy._closed = _closed;
    if (_clockwise != null)
      copy._clockwise = _clockwise;
    return copy;
  }

  _changed(int flags) {
    // Don't use base() for reasons of performance.
    //Item.prototype._changed.call(this, flags);
    // TODO will this get Item._changed if PathItem is between us?
    super.changed(flags);
    if ((flags & ChangeFlag.GEOMETRY) != 0) {
      _length = null;
      // Clockwise state becomes undefined as soon as geometry changes.
      _clockwise = null;
      // Curves are no longer valid
      if (this._curves != null) {
        for (var i = 0, l = _curves.length; i < l; i++) {
          // TODO argument to Curve._changed is unused in paper.js
          //_curves[i]._changed(Change.GEOMETRY);
          _curves[i]._changed();
        }
      }
    } else if ((flags & ChangeFlag.STROKE) != 0) {
      // TODO: We could preserve the purely geometric bounds that are not
      // affected by stroke: _bounds.bounds and _bounds.handleBounds
      bounds = null;
    }
  }

  /**
   * The segments contained within the path.
   *
   * @type Segment[]
   * @bean
   */
  List<Segment> _segments;
  List<Segment> getSegments() {
    return _segments;
  }
  List<Segment> get segments => getSegments();

  setSegments(segments) {
    if (_segments == null) {
      _segments = [];
    } else {
      _selectedSegmentState = 0;
      // TODO does this acutally clear the list?
      _segments.length = 0;
      // Make sure new curves are calculated next time we call getCurves()
      if (_curves != null)
        _curves = null;
    }
    // TODO do we lose anything just passing segments
    //_add(Segment.readAll(segments));
    _add(segments);
  }
  set segments(segments) => setSegments(segments);

  /**
   * The first Segment contained within the path.
   *
   * @type Segment
   * @bean
   */
  Segment getFirstSegment() {
    return _segments[0];
  }
  Segment get firstSegment => getFirstSegment();

  /**
   * The last Segment contained within the path.
   *
   * @type Segment
   * @bean
   */
  Segment getLastSegment() {
    return _segments[_segments.length - 1];
  }
  Segment get lastSegment => getLastSegment();

  /**
   * The curves contained within the path.
   *
   * @type Curve[]
   * @bean
   */
  List<Curve> _curves;
  List<Curve> getCurves() {
    if (_curves == null) {
      var segments = _segments,
        length = segments.length;
      // Reduce length by one if it's an open path:
      if (!_closed && length > 0)
        length--;
      // TODO is this list initialization correct?
      _curves = new List(length);
      for (var i = 0; i < length; i++)
        _curves[i] = new Curve.create(this, segments[i],
          // Use first segment for segment2 of closing curve
          segments[i + 1] != null ? segments[i + 1] : segments[0]);
    }
    return _curves;
  }
  List<Curve> get curves => getCurves();

  /**
   * The first Curve contained within the path.
   *
   * @type Curve
   * @bean
   */
  Curve getFirstCurve() {
    return getCurves()[0];
  }
  Curve get firstCurve => getFirstCurve();

  /**
   * The last Curve contained within the path.
   *
   * @type Curve
   * @bean
   */
  Curve getLastCurve() {
    var curves = getCurves();
    return curves[curves.length - 1];
  }
  Curve get lastCurve => getLastCurve();

  /**
   * Specifies whether the path is closed. If it is closed, Paper.js connects
   * the first and last segments.
   *
   * @type Boolean
   * @bean
   *
   * @example {@paperscript}
   * var myPath = new Path();
   * myPath.strokeColor = 'black';
   * myPath.add(new Point(50, 75));
   * myPath.add(new Point(100, 25));
   * myPath.add(new Point(150, 75));
   *
   * // Close the path:
   * myPath.closed = true;
   */
  bool _closed;
  bool getClosed() {
    // TODO check for null?
    return _closed;
  }
  bool get closed => getClosed();

  setClosed([closed = true]) {
    if(_closed != closed) {
      _closed = closed;
      // Update _curves length
      if (_curves != null) {
        int length = _segments.length,
          i;
        // Reduce length by one if it's an open path:
        if (!closed && length > 0)
          length--;
        _curves.length = length;
        // If we were closing this path, we need to add a new curve now
        if (closed)
          _curves[i = length - 1] = new Curve.create(this,
            _segments[i], _segments[0]);
      }
      _changed(Change.GEOMETRY);
    }
  }
  set closed(bool closed) => setClosed(closed);

  // TODO: Consider adding getSubPath(a, b), returning a part of the current
  // path, with the added benefit that b can be < a, and closed looping is
  // taken into account.

  // DOCS: Explain that path matrix is always applied with each transformation.
  Path transform(Matrix matrix, [bool apply = false]) {
    // TODO does this go up to Item?
    return super.transform(matrix, true);
  }

  Matrix getMatrix() {
    // Override matrix getter to always return null, since Paths act as if
    // they do not have a matrix, and always directly apply transformations
    // to their segment points.
    return null;
  }
  Matrix get matrix() => getMatrix();

  setMatrix(matrix) {
    // Do nothing for the same reason as above.
  }
  set matrix(Matrix matrix) => setMatrix(matrix);

  bool _apply(matrix) {
    // TODO is this correct initialization of List?
    var coords = new List(6);
    for (var i = 0, l = _segments.length; i < l; i++) {
      _segments[i]._transformCoordinates(matrix, coords, true);
    }
    // See #draw() for an explanation of why we can access _style properties
    // directly here:
    // TODO editor can't resolve _style. shouldn't it at least see Item._style?
    var style = style,
      fillColor = style._fillColor,
      strokeColor = style._strokeColor;
    // Try calling transform on colors in case they are GradientColors.
    if (fillColor && fillColor.transform)
      fillColor.transform(matrix);
    if (strokeColor && strokeColor.transform)
      strokeColor.transform(matrix);
    return true;
  }

  /**
   * Private method that adds a segment to the segment list. It assumes that
   * the passed object is a segment already and does not perform any checks.
   * If a curves list was requested, it will kept in sync with the segments
   * list automatically.
   */
  List<Segment> _add(List<Segment> segs, [int index]) {
    // Local short-cuts:
    var segments = _segments,
      curves = _curves,
      amount = segs.length,
      append = (index == null);
    index = append ? segments.length : index;
    bool fullySelected = isFullySelected();
    // Scan through segments to add first, convert if necessary and set
    // _path and _index references on them.
    for (var i = 0; i < amount; i++) {
      var segment = segs[i];
      // If the segments belong to another path already, clone them before
      // adding:
      if (segment._path != null) {
        segment = segs[i] = new Segment(segment);
      }
      segment._path = this;
      segment._index = index + i;
      // Select newly added segments if path was fully selected before
      if (fullySelected)
        segment._selectionState = SelectionState.POINT;
      // If parts of this segment are selected, adjust the internal
      // _selectedSegmentState now
      if (segment._selectionState != 0)
        _updateSelection(segment, 0, segment._selectionState);
    }
    if (append) {
      // Append them all at the end by using addAll
      segments.addAll(segs);
    } else {
      // Insert somewhere else
      // TODO dart doesn't have a reasonable insertRange.
      // we have to insert then set
      segments.insertRange(index, segs.length, null);
      segments.setRange(index, segs.length, segs);
      // Adjust the indices of the segments above.
      for (var i = index + amount, l = segments.length; i < l; i++) {
        segments[i]._index = i;
      }
    }
    // Keep the curves list in sync all the time in case it as requested
    // already. We need to step one index down from the inserted segment to
    // get its curve:
    if (curves != null && --index >= 0) {
      // Insert a new curve as well and update the curves above
      curves.insertRange(index, 1, new Curve.create(this, segments[index], segments[index + 1]));
      // Adjust segment1 now for the curves above the inserted one
      var curve = curves[index + amount];
      if (curve != null) {
        curve._segment1 = segments[index + amount];
      }
    }
    _changed(Change.GEOMETRY);
    return segs;
  }

  // PORT: Add support for adding multiple segments at once to Scriptographer
  // DOCS: find a way to document the variable segment parameters of Path#add
  /**
   * Adds one or more segments to the end of the {@link #segments} array of
   * this path.
   *
   * @param {Segment|Point} segment the segment or point to be added.
   * @return {Segment} the added segment. This is not necessarily the same
   * object, e.g. if the segment to be added already belongs to another path.
   * @operator none
   *
   * @example {@paperscript}
   * // Adding segments to a path using point objects:
   * var path = new Path();
   * path.strokeColor = 'black';
   *
   * // Add a segment at {x: 30, y: 75}
   * path.add(new Point(30, 75));
   *
   * // Add two segments in one go at {x: 100, y: 20}
   * // and {x: 170, y: 75}:
   * path.add(new Point(100, 20), new Point(170, 75));
   *
   * @example {@paperscript}
   * // Adding segments to a path using arrays containing number pairs:
   * var path = new Path();
   * path.strokeColor = 'black';
   *
   * // Add a segment at {x: 30, y: 75}
   * path.add([30, 75]);
   *
   * // Add two segments in one go at {x: 100, y: 20}
   * // and {x: 170, y: 75}:
   * path.add([100, 20], [170, 75]);
   *
   * @example {@paperscript}
   * // Adding segments to a path using objects:
   * var path = new Path();
   * path.strokeColor = 'black';
   *
   * // Add a segment at {x: 30, y: 75}
   * path.add({x: 30, y: 75});
   *
   * // Add two segments in one go at {x: 100, y: 20}
   * // and {x: 170, y: 75}:
   * path.add({x: 100, y: 20}, {x: 170, y: 75});
   *
   * @example {@paperscript}
   * // Adding a segment with handles to a path:
   * var path = new Path();
   * path.strokeColor = 'black';
   *
   * path.add(new Point(30, 75));
   *
   * // Add a segment with handles:
   * var point = new Point(100, 20);
   * var handleIn = new Point(-50, 0);
   * var handleOut = new Point(50, 0);
   * var added = path.add(new Segment(point, handleIn, handleOut));
   *
   * // Select the added segment, so we can see its handles:
   * added.selected = true;
   *
   * path.add(new Point(170, 75));
   */
  add(segment1 /*, segment2, ... */) {
    // TODO add support for other kinds of params
    // add a single segment
    if(segment1 is Segment) {
      return _add([segment1]);
    } else if(segment1 is List) {
      // add list of segments
      if(segment1[0] is Segment) {
        return _add(segment1);
      } else {
        // add list of segment type things
        // TODO do we lose anything by passing the list directly?
        //return _add(segment1.map((seg_type) => Segment.read(seg_type)));
        return _add(segment1);
      }
    }
    // TODO leaving in for reference because this will definitely change
    /*return arguments.length > 1 && typeof segment1 !== 'number'
      // addSegments
      ? this._add(Segment.readAll(arguments))
      // addSegment
      : this._add([ Segment.read(arguments) ])[0];*/
  }

  // PORT: Add support for adding multiple segments at once to Scriptographer
  /**
   * Inserts one or more segments at a given index in the list of this path's
   * segments.
   *
   * @param {Number} index the index at which to insert the segment.
   * @param {Segment|Point} segment the segment or point to be inserted.
   * @return {Segment} the added segment. This is not necessarily the same
   * object, e.g. if the segment to be added already belongs to another path.
   *
   * @example {@paperscript}
   * // Inserting a segment:
   * var myPath = new Path();
   * myPath.strokeColor = 'black';
   * myPath.add(new Point(50, 75));
   * myPath.add(new Point(150, 75));
   *
   * // Insert a new segment into myPath at index 1:
   * myPath.insert(1, new Point(100, 25));
   *
   * // Select the segment which we just inserted:
   * myPath.segments[1].selected = true;
   *
   * @example {@paperscript}
   * // Inserting multiple segments:
   * var myPath = new Path();
   * myPath.strokeColor = 'black';
   * myPath.add(new Point(50, 75));
   * myPath.add(new Point(150, 75));
   *
   * // Insert two segments into myPath at index 1:
   * myPath.insert(1, [80, 25], [120, 25]);
   *
   * // Select the segments which we just inserted:
   * myPath.segments[1].selected = true;
   * myPath.segments[2].selected = true;
   */
  insert(int index, segment1 /*, segment2, ... */) {
    // add a single segment
    if(segment1 is Segment) {
      return _add([segment1], index);
    } else if(segment1 is List) {
      // add list of segments
      if(segment1[0] is Segment) {
        return _add(segment1, index);
      } else {
        // add list of segment type things
        // TODO do we lose anything by passing the list directly?
        //return _add(segment1.map((seg_type) => Segment.read(seg_type)), index);
        return _add(segment1, index);
      }
    }

    /*return arguments.length > 2 && typeof segment1 !== 'number'
      // insertSegments
      ? this._add(Segment.readAll(arguments, 1), index)
      // insertSegment
      : this._add([ Segment.read(arguments, 1) ], index)[0];*/
  }

  // PORT: Add to Scriptographer
  // TODO add a Segment.create for these things
  addSegment(segment) {
    //return _add([ Segment.read(segment) ])[0];
    return _add([segment])[0];
  }

  // PORT: Add to Scriptographer
  insertSegment(int index, segment) {
    //return _add([ Segment.read(segment) ], index)[0];
    return _add([segment], index)[0];
  }

  // PORT: Add to Scriptographer
  /**
   * Adds an array of segments (or types that can be converted to segments)
   * to the end of the {@link #segments} array.
   *
   * @param {Segment[]} segments
   * @return {Segment[]} an array of the added segments. These segments are
   * not necessarily the same objects, e.g. if the segment to be added already
   * belongs to another path.
   *
   * @example {@paperscript}
   * // Adding an array of Point objects:
   * var path = new Path();
   * path.strokeColor = 'black';
   * var points = [new Point(30, 50), new Point(170, 50)];
   * path.addSegments(points);
   *
   * @example {@paperscript}
   * // Adding an array of [x, y] arrays:
   * var path = new Path();
   * path.strokeColor = 'black';
   * var array = [[30, 75], [100, 20], [170, 75]];
   * path.addSegments(array);
   *
   * @example {@paperscript}
   * // Adding segments from one path to another:
   *
   * var path = new Path();
   * path.strokeColor = 'black';
   * path.addSegments([[30, 75], [100, 20], [170, 75]]);
   *
   * var path2 = new Path();
   * path2.strokeColor = 'red';
   *
   * // Add the second and third segments of path to path2:
   * path2.add(path.segments[1], path.segments[2]);
   *
   * // Move path2 30pt to the right:
   * path2.position.x += 30;
   */
  addSegments(segments) {
    // TODO do we lose anything passing the list directly?
    //return _add(Segment.readAll(segments));
    return _add(segments);
  }

  // PORT: Add to Scriptographer
  /**
   * Inserts an array of segments at a given index in the path's
   * {@link #segments} array.
   *
   * @param {Number} index the index at which to insert the segments.
   * @param {Segment[]} segments the segments to be inserted.
   * @return {Segment[]} an array of the added segments. These segments are
   * not necessarily the same objects, e.g. if the segment to be added already
   * belongs to another path.
   */
  insertSegments(index, segments) {
    // TODO do we lose anything passing the list directly?
    //return _add(Segment.readAll(segments), index);
    return _add(segments, index);
  }

  // PORT: Add to Scriptographer
  /**
   * Removes the segment at the specified index of the path's
   * {@link #segments} array.
   *
   * @param {Number} index the index of the segment to be removed
   * @return {Segment} the removed segment
   *
   * @example {@paperscript}
   * // Removing a segment from a path:
   *
   * // Create a circle shaped path at { x: 80, y: 50 }
   * // with a radius of 35:
   * var path = new Path.Circle(new Point(80, 50), 35);
   * path.strokeColor = 'black';
   *
   * // Remove its second segment:
   * path.removeSegment(1);
   *
   * // Select the path, so we can see its segments:
   * path.selected = true;
   */
  Segment removeSegment(int index) {
    var segments = removeSegments(index, index + 1);
    return segments[0];
  }

  // PORT: Add to Scriptographer
  /**
   * Removes all segments from the path's {@link #segments} array.
   *
   * @name Path#removeSegments
   * @function
   * @return {Segment[]} an array containing the removed segments
   */
  /**
   * Removes the segments from the specified {@code from} index to the
   * {@code to} index from the path's {@link #segments} array.
   *
   * @param {Number} from the beginning index, inclusive
   * @param {Number} [to=segments.length] the ending index, exclusive
   * @return {Segment[]} an array containing the removed segments
   *
   * @example {@paperscript}
   * // Removing segments from a path:
   *
   * // Create a circle shaped path at { x: 80, y: 50 }
   * // with a radius of 35:
   * var path = new Path.Circle(new Point(80, 50), 35);
   * path.strokeColor = 'black';
   *
   * // Remove the segments from index 1 till index 2:
   * path.removeSegments(1, 2);
   *
   * // Select the path, so we can see its segments:
   * path.selected = true;
   */
  removeSegments([int from = 0, int to]) {
    to = ?to ? to : _segments.length;
    var segments = _segments,
      curves = _curves,
      last = to >= segments.length,
      removed = segments.getRange(from, to - from),
      amount = removed.length;
    segments.removeRange(from, to - from);
    if (amount == 0)
      return removed;
    // Update selection state accordingly
    for (var i = 0; i < amount; i++) {
      var segment = removed[i];
      if (segment._selectionState != 0)
        _updateSelection(segment, segment._selectionState, 0);
      // Clear the indices and path references of the removed segments
      // TODO this looks like a paper.js bug
      removed._index = removed._path = null;
    }
    // Adjust the indices of the segments above.
    for (var i = from, l = segments.length; i < l; i++)
      segments[i]._index = i;
    // Keep curves in sync
    if (curves != null) {
      curves.removeRange(from, amount);
      // Adjust segments for the curves before and after the removed ones
      var curve;
      if ((curve = curves[from - 1]) != null)
        curve._segment2 = segments[from];
      if ((curve = curves[from]) != null)
        curve._segment1 = segments[from];
      // If the last segment of a closing path was removed, we need to
      // readjust the last curve of the list now.
      if (last && _closed && ((curve = curves[curves.length - 1]) != null))
        curve._segment2 = segments[0];
    }
    _changed(Change.GEOMETRY);
    return removed;
  }

  /**
   * Specifies whether an path is selected and will also return {@code true}
   * if the path is partially selected, i.e. one or more of its segments is
   * selected.
   *
   * Paper.js draws the visual outlines of selected items on top of your
   * project. This can be useful for debugging, as it allows you to see the
   * construction of paths, position of path curves, individual segment points
   * and bounding boxes of symbol and raster items.
   *
   * @type Boolean
   * @bean
   * @see Project#selectedItems
   * @see Segment#selected
   * @see Point#selected
   *
   * @example {@paperscript}
   * // Selecting an item:
   * var path = new Path.Circle(new Size(80, 50), 35);
   * path.selected = true; // Select the path
   *
   * @example {@paperscript}
   * // A path is selected, if one or more of its segments is selected:
   * var path = new Path.Circle(new Size(80, 50), 35);
   *
   * // Select the second segment of the path:
   * path.segments[1].selected = true;
   *
   * // If the path is selected (which it is), set its fill color to red:
   * if (path.selected) {
   *   path.fillColor = 'red';
   * }
   *
   */
  // TODO do we have to do anything for this?
  /**
   * Specifies whether the path and all its segments are selected.
   *
   * @type Boolean
   * @bean
   *
   * @example {@paperscript}
   * // A path is fully selected, if all of its segments are selected:
   * var path = new Path.Circle(new Size(80, 50), 35);
   * path.fullySelected = true;
   *
   * var path2 = new Path.Circle(new Size(180, 50), 35);
   * path2.fullySelected = true;
   *
   * // Deselect the second segment of the second path:
   * path2.segments[1].selected = false;
   *
   * // If the path is fully selected (which it is),
   * // set its fill color to red:
   * if (path.fullySelected) {
   *   path.fillColor = 'red';
   * }
   *
   * // If the second path is fully selected (which it isn't, since we just
   * // deselected its second segment),
   * // set its fill color to red:
   * if (path2.fullySelected) {
   *   path2.fillColor = 'red';
   * }
   */
  bool isFullySelected() {
    return selected && _selectedSegmentState
        == _segments.length * SelectionState.POINT;
  }
  bool get fullySelected => isFullySelected();

  void setFullySelected(bool selected) {
    var length = _segments.length;
    _selectedSegmentState = selected
        ? length * SelectionState.POINT : 0;
    for (var i = 0; i < length; i++)
      _segments[i]._selectionState = selected
          ? SelectionState.POINT : 0;
    // No need to pass true for noChildren since Path has none anyway.
    setSelected(selected);
  }
  set fullySelected(bool selected) => setFullySelected(selected);

  _updateSelection(segment, oldState, newState) {
    segment._selectionState = newState;
    var total = _selectedSegmentState += newState - oldState;
    // Set this path as selected in case we have selected segments. Do not
    // unselect if we're down to 0, as the path itself can still remain
    // selected even when empty.
    if (total > 0)
      setSelected(true);
  }

  /**
   * Converts the curves in a path to straight lines with an even distribution
   * of points. The distance between the produced segments is as close as
   * possible to the value specified by the {@code maxDistance} parameter.
   *
   * @param {Number} maxDistance the maximum distance between the points
   *
   * @example {@paperscript}
   * // Flattening a circle shaped path:
   *
   * // Create a circle shaped path at { x: 80, y: 50 }
   * // with a radius of 35:
   * var path = new Path.Circle(new Size(80, 50), 35);
   *
   * // Select the path, so we can inspect its segments:
   * path.selected = true;
   *
   * // Create a copy of the path and move it 150 points to the right:
   * var copy = path.clone();
   * copy.position.x += 150;
   *
   * // Convert its curves to points, with a max distance of 20:
   * copy.flatten(20);
   *
   * // Select the copy, so we can inspect its segments:
   * copy.selected = true;
   */
  flatten(num maxDistance) {
    var flattener = new PathFlattener(this),
      pos = 0,
      // Adapt step = maxDistance so the points distribute evenly.
      step = flattener.length / (flattener.length / maxDistance).ceil(),
      // Add/remove half of step to end, so imprecisions are ok too.
      // For closed paths, remove it, because we don't want to add last
      // segment again
      end = flattener.length + (_closed ? -step : step) / 2;
    // Iterate over path and evaluate and add points at given offsets
    var segments = [];
    while (pos <= end) {
      segments.add(new Segment(flattener.evaluate(pos, 0)));
      pos += step;
    }
    setSegments(segments);
  }

  /**
   * Smooths a path by simplifying it. The {@link Path#segments} array is
   * analyzed and replaced by a more optimal set of segments, reducing memory
   * usage and speeding up drawing.
   *
   * @param {Number} [tolerance=2.5]
   *
   * @example {@paperscript height=300}
   * // Click and drag below to draw to draw a line, when you release the
   * // mouse, the is made smooth using path.simplify():
   *
   * var path;
   * function onMouseDown(event) {
   *   // If we already made a path before, deselect it:
   *   if (path) {
   *     path.selected = false;
   *   }
   *
   *   // Create a new path and add the position of the mouse
   *   // as its first segment. Select it, so we can see the
   *   // segment points:
   *   path = new Path();
   *   path.strokeColor = 'black';
   *   path.add(event.point);
   *   path.selected = true;
   * }
   *
   * function onMouseDrag(event) {
   *   // On every drag event, add a segment to the path
   *   // at the position of the mouse:
   *   path.add(event.point);
   * }
   *
   * function onMouseUp(event) {
   *   // When the mouse is released, simplify the path:
   *   path.simplify();
   *   path.selected = true;
   * }
   */
  simplify([num tolerance = 2.5]) {
    if (_segments.length > 2) {
      var fitter = new PathFitter(this, tolerance);
      setSegments(fitter.fit());
    }
  }

  // TODO: reduceSegments([flatness])
  // TODO: split(offset) / split(location) / split(index[, parameter])

  /**
   * Specifies whether the path is oriented clock-wise.
   *
   * @type Boolean
   * @bean
   */
  bool _clockwise;
  bool isClockwise() {
    if (_clockwise != null)
      return _clockwise;
    var sum = 0,
      xPre, yPre;
    var edge = (x, y) {
      if (xPre != null)
        sum += (xPre - x) * (y + yPre);
      xPre = x;
      yPre = y;
    };
    // Method derived from:
    // http://stackoverflow.com/questions/1165647
    // We treat the curve points and handles as the outline of a polygon of
    // which we determine the orientation using the method of calculating
    // the sum over the edges. This will work even with non-convex polygons,
    // telling you whether it's mostly clockwise
    for (var i = 0, l = _segments.length; i < l; i++) {
      var seg1 = _segments[i],
        seg2 = _segments[i + 1 < l ? i + 1 : 0],
        point1 = seg1._point,
        handle1 = seg1._handleOut,
        handle2 = seg2._handleIn,
        point2 = seg2._point;
      edge(point1._x, point1._y);
      edge(point1._x + handle1._x, point1._y + handle1._y);
      edge(point2._x + handle2._x, point2._y + handle2._y);
      edge(point2._x, point2._y);
    }
    return sum > 0;
  }
  bool get clockwise => isClockwise();

  setClockwise([bool clockwise = true]) {
    // On-the-fly conversion to boolean:
    if(isClockwise() != clockwise) {
      // Only reverse the path if its clockwise orientation is not the same
      // as what it is now demanded to be.
      reverse();
      _clockwise = clockwise;
    }
  }
  set clockwise(bool clockwise) => setClockwise(clockwise);

  /**
   * Reverses the segments of the path.
   */
  reverse() {
    _segments.reverse();
    // Reverse the handles:
    for (var i = 0, l = _segments.length; i < l; i++) {
      var segment = _segments[i];
      var handleIn = segment._handleIn;
      segment._handleIn = segment._handleOut;
      segment._handleOut = handleIn;
      segment._index = i;
    }
    // Flip clockwise state if it's defined
    if (_clockwise != null)
      _clockwise = !_clockwise;
  }

  // DOCS: document Path#join in more detail.
  /**
   * Joins the path with the specified path, which will be removed in the
   * process.
   *
   * @param {Path} path
   *
   * @example {@paperscript}
   * // Joining two paths:
   * var path = new Path([30, 25], [30, 75]);
   * path.strokeColor = 'black';
   *
   * var path2 = new Path([200, 25], [200, 75]);
   * path2.strokeColor = 'black';
   *
   * // Join the paths:
   * path.join(path2);
   *
   * @example {@paperscript}
   * // Joining two paths that share a point at the start or end of their
   * // segments array:
   * var path = new Path([30, 25], [30, 75]);
   * path.strokeColor = 'black';
   *
   * var path2 = new Path([30, 25], [80, 25]);
   * path2.strokeColor = 'black';
   *
   * // Join the paths:
   * path.join(path2);
   *
   * // After joining, path with have 3 segments, since it
   * // shared its first segment point with the first
   * // segment point of path2.
   *
   * // Select the path to show that they have joined:
   * path.selected = true;
   *
   * @example {@paperscript}
   * // Joining two paths that connect at two points:
   * var path = new Path([30, 25], [80, 25], [80, 75]);
   * path.strokeColor = 'black';
   *
   * var path2 = new Path([30, 25], [30, 75], [80, 75]);
   * path2.strokeColor = 'black';
   *
   * // Join the paths:
   * path.join(path2);
   *
   * // Because the paths were joined at two points, the path is closed
   * // and has 4 segments.
   *
   * // Select the path to show that they have joined:
   * path.selected = true;
   */
  bool join(Path path) {
    if (path != null) {
      var segments = path._segments,
        last1 = getLastSegment(),
        last2 = path.getLastSegment();
      if (last1._point.equals(last2._point))
        path.reverse();
      var first2 = path.getFirstSegment();
      if (last1._point.equals(first2._point)) {
        last1.setHandleOut(first2._handleOut);
        _add(segments.getRange(1, segments.length));
      } else {
        var first1 = getFirstSegment();
        if (first1._point.equals(first2._point))
          path.reverse();
        last2 = path.getLastSegment();
        if (first1._point.equals(last2._point)) {
          first1.setHandleIn(last2._handleIn);
          // Prepend all segments from path except the last one
          _add(segments.getRange(0, segments.length - 1), 0);
        } else {
          // TODO slice(0) is just the whole thing right?
          _add(segments);
          //_add(segments.slice(0));
        }
      }
      path.remove();
      // Close if they touch in both places
      var first1 = getFirstSegment();
      last1 = getLastSegment();
      if (last1._point.equals(first1._point)) {
        first1.setHandleIn(last1._handleIn);
        last1.remove();
        setClosed(true);
      }
      _changed(Change.GEOMETRY);
      return true;
    }
    return false;
  }

  /**
   * The length of the perimeter of the path.
   *
   * @type Number
   * @bean
   */
  num _length;
  num getLength() {
    if (_length == null) {
      var curves = getCurves();
      _length = 0;
      for (var i = 0, l = curves.length; i < l; i++)
        _length += curves[i].getLength();
    }
    return _length;
  }
  num get length => getLength();

  num _getOffset(CurveLocation location) {
    var index = location != null ? location.getIndex() : null;
    if (index != null) {
      var curves = getCurves(),
        offset = 0;
      for (var i = 0; i < index; i++)
        offset += curves[i].getLength();
      var curve = curves[index];
      return offset + curve.getLength(0, location.getParameter());
    }
    return null;
  }

  CurveLocation getLocation(point) {
    var curves = getCurves();
    for (var i = 0, l = curves.length; i < l; i++) {
      var curve = curves[i];
      var t = curve.getParameter(point);
      if (t != null)
        return new CurveLocation(curve, t);
    }
    return null;
  }

  // PORT: Rename functions and add new isParameter argument in Scriptographer
  // DOCS: document Path#getLocationAt
  /**
   * {@grouptitle Positions on Paths and Curves}
   *
   * @param {Number} offset
   * @param {Boolean} [isParameter=false]
   * @return {CurveLocation}
   */
  CurveLocation getLocationAt(num offset, [bool isParameter = false]) {
    var curves = getCurves(),
      length = 0;
    if (isParameter) {
      // offset consists of curve index and curve parameter, before and
      // after the fractional digit.
      int index = offset.floor();
      return new CurveLocation(curves[index], offset - index);
    }
    for (var i = 0, l = curves.length; i < l; i++) {
      var start = length,
        curve = curves[i];
      length += curve.getLength();
      if (length >= offset) {
        // Found the segment within which the length lies
        return new CurveLocation(curve,
            curve.getParameterAt(offset - start));
      }
    }
    // It may be that through impreciseness of getLength, that the end
    // of the curves was missed:
    if (offset <= this.getLength())
      return new CurveLocation(curves[curves.length - 1], 1);
    return null;
  }

  /**
   * Get the point on the path at the given offset.
   *
   * @param {Number} offset
   * @param {Boolean} [isParameter=false]
   * @return {Point} the point at the given offset
   *
   * @example {@paperscript height=150}
   * // Finding the point on a path at a given offset:
   *
   * // Create an arc shaped path:
   * var path = new Path();
   * path.strokeColor = 'black';
   * path.add(new Point(40, 100));
   * path.arcTo(new Point(150, 100));
   *
   * // We're going to be working with a third of the length
   * // of the path as the offset:
   * var offset = path.length / 3;
   *
   * // Find the point on the path:
   * var point = path.getPointAt(offset);
   *
   * // Create a small circle shaped path at the point:
   * var circle = new Path.Circle(point, 3);
   * circle.fillColor = 'red';
   *
   * @example {@paperscript height=150}
   * // Iterating over the length of a path:
   *
   * // Create an arc shaped path:
   * var path = new Path();
   * path.strokeColor = 'black';
   * path.add(new Point(40, 100));
   * path.arcTo(new Point(150, 100));
   *
   * var amount = 5;
   * var length = path.length;
   * for (var i = 0; i < amount + 1; i++) {
   *   var offset = i / amount * length;
   *
   *   // Find the point on the path at the given offset:
   *   var point = path.getPointAt(offset);
   *
   *   // Create a small circle shaped path at the point:
   *   var circle = new Path.Circle(point, 3);
   *   circle.fillColor = 'red';
   * }
   */
  Point getPointAt(num offset, [bool isParameter = false]) {
    var loc = getLocationAt(offset, isParameter);
    return loc != null ? loc.getPoint() : null;
  }

  /**
   * Get the tangent to the path at the given offset as a vector
   * point.
   *
   * @param {Number} offset
   * @param {Boolean} [isParameter=false]
   * @return {Point} the tangent vector at the given offset
   *
   * @example {@paperscript height=150}
   * // Working with the tangent vector at a given offset:
   *
   * // Create an arc shaped path:
   * var path = new Path();
   * path.strokeColor = 'black';
   * path.add(new Point(40, 100));
   * path.arcTo(new Point(150, 100));
   *
   * // We're going to be working with a third of the length
   * // of the path as the offset:
   * var offset = path.length / 3;
   *
   * // Find the point on the path:
   * var point = path.getPointAt(offset);
   *
   * // Find the tangent vector at the given offset:
   * var tangent = path.getTangentAt(offset);
   *
   * // Make the tangent vector 60pt long:
   * tangent.length = 60;
   *
   * var path = new Path();
   * path.strokeColor = 'red';
   * path.add(point);
   * path.add(point + tangent);
   *
   * @example {@paperscript height=200}
   * // Iterating over the length of a path:
   *
   * // Create an arc shaped path:
   * var path = new Path();
   * path.strokeColor = 'black';
   * path.add(new Point(40, 100));
   * path.arcTo(new Point(150, 100));
   *
   * var amount = 6;
   * var length = path.length;
   * for (var i = 0; i < amount + 1; i++) {
   *   var offset = i / amount * length;
   *
   *   // Find the point on the path at the given offset:
   *   var point = path.getPointAt(offset);
   *
   *   // Find the normal vector on the path at the given offset:
   *   var tangent = path.getTangentAt(offset);
   *
   *   // Make the tangent vector 60pt long:
   *   tangent.length = 60;
   *
   *   var line = new Path();
   *   line.strokeColor = 'red';
   *   line.add(point);
   *   line.add(point + tangent);
   * }
   */
  Point getTangentAt(num offset, [bool isParameter = false]) {
    var loc = getLocationAt(offset, isParameter);
    return loc != null ? loc.getTangent() : null;
  }

  /**
   * Get the normal to the path at the given offset as a vector point.
   *
   * @param {Number} offset
   * @param {Boolean} [isParameter=false]
   * @return {Point} the normal vector at the given offset
   *
   * @example {@paperscript height=150}
   * // Working with the normal vector at a given offset:
   *
   * // Create an arc shaped path:
   * var path = new Path();
   * path.strokeColor = 'black';
   * path.add(new Point(40, 100));
   * path.arcTo(new Point(150, 100));
   *
   * // We're going to be working with a third of the length
   * // of the path as the offset:
   * var offset = path.length / 3;
   *
   * // Find the point on the path:
   * var point = path.getPointAt(offset);
   *
   * // Find the normal vector at the given offset:
   * var normal = path.getNormalAt(offset);
   *
   * // Make the normal vector 30pt long:
   * normal.length = 30;
   *
   * var path = new Path();
   * path.strokeColor = 'red';
   * path.add(point);
   * path.add(point + normal);
   *
   * @example {@paperscript height=200}
   * // Iterating over the length of a path:
   *
   * // Create an arc shaped path:
   * var path = new Path();
   * path.strokeColor = 'black';
   * path.add(new Point(40, 100));
   * path.arcTo(new Point(150, 100));
   *
   * var amount = 10;
   * var length = path.length;
   * for (var i = 0; i < amount + 1; i++) {
   *   var offset = i / amount * length;
   *
   *   // Find the point on the path at the given offset:
   *   var point = path.getPointAt(offset);
   *
   *   // Find the normal vector on the path at the given offset:
   *   var normal = path.getNormalAt(offset);
   *
   *   // Make the normal vector 30pt long:
   *   normal.length = 30;
   *
   *   var line = new Path();
   *   line.strokeColor = 'red';
   *   line.add(point);
   *   line.add(point + normal);
   * }
   */
  Point getNormalAt(num offset, [bool isParameter = false]) {
    var loc = getLocationAt(offset, isParameter);
    return loc != null ? loc.getNormal() : null;
  }

  /**
   * Returns the nearest location on the path to the specified point.
   *
   * @name Path#getNearestLocation
   * @function
   * @param point {Point} The point for which we search the nearest location
   * @return {CurveLocation} The location on the path that's the closest to
   * the specified point
   */
  CurveLocation getNearestLocation(point) {
    var curves = getCurves(),
      minDist = double.INFINITY,
      minLoc = null;
    for (var i = 0, l = curves.length; i < l; i++) {
      var loc = curves[i].getNearestLocation(point);
      if (loc._distance < minDist) {
        minDist = loc._distance;
        minLoc = loc;
      }
    }
    return minLoc;
  }

  /**
   * Returns the nearest point on the path to the specified point.
   *
   * @name Path#getNearestPoint
   * @function
   * @param point {Point} The point for which we search the nearest point
   * @return {Point} The point on the path that's the closest to the specified
   * point
   */
  Point getNearestPoint(point) {
    return getNearestLocation(point).getPoint();
  }

  bool contains(point) {
    point = Point.read(point);
    // Note: This only works correctly with even-odd fill rule, or paths
    // that do not overlap with themselves.
    // TODO: Find out how to implement the "Point In Polygon" problem for
    // non-zero fill rule.
    if (!_closed || !getRoughBounds().containsPoint(point))
      return false;
    // Use the crossing number algorithm, by counting the crossings of the
    // beam in right y-direction with the shape, and see if it's an odd
    // number, meaning the starting point is inside the shape.
    // http://en.wikipedia.org/wiki/Point_in_polygon
    var curves = getCurves(),
      crossings = 0,
      // Reuse one array for root-finding, give garbage collector a break
      roots = [];
    for (var i = 0, l = curves.length; i < l; i++)
      crossings += curves[i].getCrossings(point, roots);
    return (crossings & 1) == 1;
  }

  HitResult _hitTest(point, options) {
    // See #draw() for an explanation of why we can access _style properties
    // directly here:
    var style = style,
      tolerance = options.containsKey("tolerance") ? options["tolerance"] : 0,
      radius = (options["stroke"] && style._strokeColor
          ? style._strokeWidth / 2 : 0) + tolerance,
      loc,
      res;
    // If we're asked to query for segments, ends or handles, do all that
    // before stroke or fill.
    var coords = [],
      that = this;
    var checkPoint = (seg, pt, name) {
      // TODO: We need to transform the point back to the coordinate
      // system of the DOM level on which the inquiry was started!
      if (point.getDistance(pt) < tolerance)
        return new HitResult(name, that, { "segment": seg, "point": pt });
    };
    var checkSegment = (seg, [ends]) {
      var point = seg._point;
      // Note, when checking for ends, we don't also check for handles,
      // since this will happen afterwards in a separate loop, see below.
      return (ends || options["segments"])
          && checkPoint(seg, point, 'segment')
        || (!ends && options["handles"]) && (
          checkPoint(seg, point.add(seg._handleIn), 'handle-in') ||
          checkPoint(seg, point.add(seg._handleOut), 'handle-out'));
    };
    if (options["ends"] && !options["segments"] && !_closed) {
      if (res = checkSegment(getFirstSegment(), true)
          || checkSegment(getLastSegment(), true))
        return res;
    } else if (options["segments"] || options["handles"]) {
      for (var i = 0, l = _segments.length; i < l; i++) {
        if (res = checkSegment(_segments[i]))
          return res;
      }
    }
    // If we're querying for stroke, perform that before fill
    if (options["stroke"] && radius > 0)
      loc = getNearestLocation(point);
    // Don't process loc yet, as we also need to query for stroke after fill
    // in some cases. Simply skip fill query if we already have a matching
    // stroke.
    if (!(loc != null && loc._distance <= radius) && options["fill"]
        && style._fillColor && contains(point))
      return new HitResult('fill', this);
    // Now query stroke if we haven't already
    if (loc == null && options["stroke"] && radius > 0)
      loc = getNearestLocation(point);
    if (loc != null && loc._distance <= radius)
      // TODO: Do we need to transform the location back to the coordinate
      // system of the DOM level on which the inquiry was started?
      return options["stroke"]
          ? new HitResult('stroke', this, { "location": loc })
          : new HitResult('fill', this);
  }

  // TODO: intersects(item)
  // TODO: contains(item)
  // TODO: intersect(item)
  // TODO: unite(item)
  // TODO: exclude(item)
  // TODO: getIntersections(path)

  // TODO we don't have access to the private members of point, so in paper.dart,
  // we use the x,y accessors instead. we will go back and optimize if we need to
  // Note that in the code below we're often accessing _x and _y on point
  // objects that were read from segments. This is because the SegmentPoint
  // class overrides the plain x / y properties with getter / setters and
  // stores the values in these private properties internally. To avoid
  // calling of getter functions all the time we directly access these private
  // properties here. The distinction between normal Point objects and
  // SegmentPoint objects maybe seem a bit tedious but is worth the benefit in
  // performance.

  static void _drawHandles(ctx, segments, matrix) {
    List coords = new List(6); // TODO is this correct list initialization?
    for(Segment segment in segments) {
      segment._transformCoordinates(matrix, coords, false);
      var state = segment._selectionState,
        selected = ((state & SelectionState.POINT) != 0),
        pX = coords[0],
        pY = coords[1];

      var drawHandle = (int index) {
        var hX = coords[index],
          hY = coords[index + 1];
        if (pX != hX || pY != hY) {
          ctx.beginPath();
          ctx.moveTo(pX, pY);
          ctx.lineTo(hX, hY);
          ctx.stroke();
          ctx.beginPath();
          ctx.arc(hX, hY, 1.75, 0, PI * 2, true);
          ctx.fill();
        }
      };

      if (selected || ((state & SelectionState.HANDLE_IN) != 0))
        drawHandle(2);
      if (selected || ((state & SelectionState.HANDLE_OUT) != 0))
        drawHandle(4);
      // Draw a rectangle at segment.point:
      ctx.save();
      ctx.beginPath();
      ctx.rect(pX - 2, pY - 2, 4, 4);
      ctx.fill();
      // If the point is not selected, draw a white square that is 1 px
      // smaller on all sides:
      if (!selected) {
        ctx.beginPath();
        ctx.rect(pX - 1, pY - 1, 2, 2);
        ctx.fillStyle = '#ffffff';
        ctx.fill();
      }
      ctx.restore();
    }
  }

  static void _drawSegments(ctx, path, [matrix]) {
    var segments = path._segments,
      length = segments.length,
      coords = new List(6),
      first = true,
      pX, pY,
      inX, inY,
      outX, outY;

    var drawSegment = (int i) {
      var segment = segments[i];
      // Optimise code when no matrix is provided by accessing semgent
      // points hand handles directly, since this is the default when
      // drawing paths. Matrix is only used for drawing selections.
      if (matrix != null) {
        segment._transformCoordinates(matrix, coords, false);
        pX = coords[0];
        pY = coords[1];
      } else {
        var point = segment._point;
        pX = point._x;
        pY = point._y;
      }
      if (first) {
        ctx.moveTo(pX, pY);
        first = false;
      } else {
        if (matrix != null) {
          inX = coords[2];
          inY = coords[3];
        } else {
          var handle = segment._handleIn;
          inX = pX + handle._x;
          inY = pY + handle._y;
        }
        if (inX == pX && inY == pY && outX == pX && outY == pY) {
          ctx.lineTo(pX, pY);
        } else {
          ctx.bezierCurveTo(outX, outY, inX, inY, pX, pY);
        }
      }
      if (matrix != null) {
        outX = coords[4];
        outY = coords[5];
      } else {
        var handle = segment._handleOut;
        outX = pX + handle._x;
        outY = pY + handle._y;
      }
    };

    for (var i = 0; i < length; i++)
      drawSegment(i);
    // Close path by drawing first segment again
    if (path._closed && length > 1)
      drawSegment(0);
  }

  void draw(ctx, param) {
    if (!param.compound)
      ctx.beginPath();

    // We can access styles directly on the internal _styles object,
    // since Path items do not have children, thus do not need style
    // accessors for merged styles.
    var style = style,
      fillColor = style._fillColor,
      strokeColor = style._strokeColor,
      dashArray = style._dashArray,
      hasDash = strokeColor && dashArray && dashArray.length;

    // Prepare the canvas path if we have any situation that requires it
    // to be defined.
    if (param.compound || clipMask || fillColor
        || strokeColor && !hasDash) {
      _drawSegments(ctx, this);
    }

    if (_closed)
      ctx.closePath();

    if (clipMask) {
      ctx.clip();
    } else if (!param.compound && (fillColor || strokeColor)) {
      // If the path is part of a compound path or doesn't have a fill
      // or stroke, there is no need to continue.
      ctx.save();
      setStyles(ctx);
      if (fillColor)
        ctx.fill();
      if (strokeColor) {
        if (hasDash) {
          // We cannot use the path created by drawSegments above
          // Use CurveFlatteners to draw dashed paths:
          ctx.beginPath();
          var flattener = new PathFlattener(this),
            from = style._dashOffset, to,
            i = 0;
          while (from < flattener.length) {
            to = from + dashArray[(i++) % dashArray.length];
            flattener.drawPart(ctx, from, to);
            from = to + dashArray[(i++) % dashArray.length];
          }
        }
        ctx.stroke();
      }
      ctx.restore();
    }
  }

  void drawSelected(ctx, matrix) {
    ctx.beginPath();
    _drawSegments(ctx, this, matrix);
    // Now stroke it and draw its handles:
    ctx.stroke();
    _drawHandles(ctx, _segments, matrix);
  }

  // Path Smoothing

  /**
   * Solves a tri-diagonal system for one of coordinates (x or y) of first
   * bezier control points.
   *
   * @param rhs right hand side vector.
   * @return Solution vector.
   */
  static List _getFirstControlPoints(rhs) {
    var n = rhs.length,
      x = [], // Solution vector.
      tmp = [], // Temporary workspace.
      b = 2;
    x[0] = rhs[0] / b;
    // Decomposition and forward substitution.
    for (var i = 1; i < n; i++) {
      tmp[i] = 1 / b;
      b = (i < n - 1 ? 4 : 2) - tmp[i];
      x[i] = (rhs[i] - x[i - 1]) / b;
    }
    // Back-substitution.
    for (var i = 1; i < n; i++) {
      x[n - i - 1] -= tmp[n - i] * x[n - i];
    }
    return x;
  }

  // Note: Documentation for smooth() is in PathItem
  void smooth() {
    // This code is based on the work by Oleg V. Polikarpotchkin,
    // http://ov-p.spaces.live.com/blog/cns!39D56F0C7A08D703!147.entry
    // It was extended to support closed paths by averaging overlapping
    // beginnings and ends. The result of this approach is very close to
    // Polikarpotchkin's closed curve solution, but reuses the same
    // algorithm as for open paths, and is probably executing faster as
    // well, so it is preferred.
    var segments = _segments,
      size = segments.length,
      n = size,
      // Add overlapping ends for averaging handles in closed paths
      overlap;

    if (size <= 2)
      return;

    if (_closed) {
      // Overlap up to 4 points since averaging beziers affect the 4
      // neighboring points
      overlap = min(size, 4);
      n += min(size, overlap) * 2;
    } else {
      overlap = 0;
    }
    var knots = [];
    for (var i = 0; i < size; i++)
      knots[i + overlap] = segments[i]._point;
    if (_closed) {
      // If we're averaging, add the 4 last points again at the
      // beginning, and the 4 first ones at the end.
      for (var i = 0; i < overlap; i++) {
        knots[i] = segments[i + size - overlap]._point;
        knots[i + size + overlap] = segments[i]._point;
      }
    } else {
      n--;
    }
    // Calculate first Bezier control points
    // Right hand side vector
    var rhs = [];

    // Set right hand side X values
    for (var i = 1; i < n - 1; i++)
      rhs[i] = 4 * knots[i]._x + 2 * knots[i + 1]._x;
    rhs[0] = knots[0]._x + 2 * knots[1]._x;
    rhs[n - 1] = 3 * knots[n - 1]._x;
    // Get first control points X-values
    var x = _getFirstControlPoints(rhs);

    // Set right hand side Y values
    for (var i = 1; i < n - 1; i++)
      rhs[i] = 4 * knots[i]._y + 2 * knots[i + 1]._y;
    rhs[0] = knots[0]._y + 2 * knots[1]._y;
    rhs[n - 1] = 3 * knots[n - 1]._y;
    // Get first control points Y-values
    var y = _getFirstControlPoints(rhs);

    if (_closed) {
      // Do the actual averaging simply by linearly fading between the
      // overlapping values.
      for (var i = 0, j = size; i < overlap; i++, j++) {
        var f1 = (i / overlap);
        var f2 = 1 - f1;
        // Beginning
        x[j] = x[i] * f1 + x[j] * f2;
        y[j] = y[i] * f1 + y[j] * f2;
        // End
        var ie = i + overlap, je = j + overlap;
        x[je] = x[ie] * f2 + x[je] * f1;
        y[je] = y[ie] * f2 + y[je] * f1;
      }
      n--;
    }
    var handleIn = null;
    // Now set the calculated handles
    for (var i = overlap; i <= n - overlap; i++) {
      var segment = segments[i - overlap];
      if (handleIn)
        segment.setHandleIn(handleIn.subtract(segment._point));
      if (i < n) {
        segment.setHandleOut(
            new Point.create(x[i], y[i]).subtract(segment._point));
        if (i < n - 1)
          handleIn = new Point.create(
              2 * knots[i + 1]._x - x[i + 1],
              2 * knots[i + 1]._y - y[i + 1]);
        else
          handleIn = new Point.create(
              (knots[n]._x + x[n - 1]) / 2,
              (knots[n]._y + y[n - 1]) / 2);
      }
    }
    if (_closed && handleIn) {
      var segment = _segments[0];
      segment.setHandleIn(handleIn.subtract(segment._point));
    }
  }
 
  // PostScript-style drawing commands
  /**
   * Helper method that returns the current segment and checks if a moveTo()
   * command is required first.
   */
  // TODO what is that?
  static Segment _getCurrentSegment(that) {
    var segments = that._segments;
    if (segments.length == 0)
      // TODO subclass Exception
      throw "Use a moveTo() command first";
      //throw new Error('Use a moveTo() command first');
    return segments[segments.length - 1];
  }

  // Note: Documentation for these methods is found in PathItem, as they
  // are considered abstract methods of PathItem and need to be defined in
  // all implementing classes.
  void moveTo(point) {
    // Let's not be picky about calling moveTo() when not at the
    // beginning of a path, just bail out:
    if (_segments.length == 0)
      _add([ new Segment(Point.read(point)) ]);
  }

  void moveBy(point) {
    // TODO subclass Exception
    throw "moveBy() is unsupported on Path items.";
    //throw new Error('moveBy() is unsupported on Path items.');
  }

  void lineTo(point) {
    // Let's not be picky about calling moveTo() first:
    _add([ new Segment(Point.read(point)) ]);
  }

  void cubicCurveTo(handle1, handle2, to) {
    handle1 = Point.read(handle1);
    handle2 = Point.read(handle2);
    to = Point.read(to);
    // First modify the current segment:
    var current = _getCurrentSegment(this);
    // Convert to relative values:
    current.setHandleOut(handle1.subtract(current._point));
    // And add the new segment, with handleIn set to c2
    _add([ new Segment(to, handle2.subtract(to)) ]);
  }

  void quadraticCurveTo(handle, to) {
    handle = Point.read(handle);
    to = Point.read(to);
    // This is exact:
    // If we have the three quad points: A E D,
    // and the cubic is A B C D,
    // B = E + 1/3 (A - E)
    // C = E + 1/3 (D - E)
    var current = _getCurrentSegment(this)._point;
    cubicCurveTo(
      handle.add(current.subtract(handle).multiply(1/3)),
      handle.add(to.subtract(handle).multiply(1/3)),
      to
    );
  }

  void curveTo(through, to, [parameter = 0.5]) {
    through = Point.read(through);
    to = Point.read(to);
    var t = parameter,
      t1 = 1 - t,
      current = _getCurrentSegment(this)._point,
      // handle = (through - (1 - t)^2 * current - t^2 * to) /
      // (2 * (1 - t) * t)
      handle = through.subtract(current.multiply(t1 * t1))
        .subtract(to.multiply(t * t)).divide(2 * t * t1);
    if (handle.isNaN())
      // TODO subclass Exception
      throw "Cannot put a curve through points with parameter = $t";
      //throw new Error(
      //  'Cannot put a curve through points with parameter = ' + t);
    quadraticCurveTo(handle, to);
  }

  // PORT: New implementation back to Scriptographer
  void arcTo(to, clockwise /* | through, to */) {
    // Get the start point:
    var current = _getCurrentSegment(this),
      from = current._point,
      through;
    if (!?clockwise)
      clockwise = true;
    if (clockwise is bool) {
      to = Point.read(to);
      var middle = from.add(to).divide(2),
      through = middle.add(middle.subtract(from).rotate(
          clockwise ? -90 : 90));
    } else {
      through = Point.read(to);
      to = Point.read(clockwise);
    }
    // Construct the two perpendicular middle lines to (from, through)
    // and (through, to), and intersect them to get the center
    var l1 = new Line(from.add(through).divide(2),
        through.subtract(from).rotate(90)),
       l2 = new Line(through.add(to).divide(2),
        to.subtract(through).rotate(90)),
      center = l1.intersect(l2),
      line = new Line(from, to, true),
      throughSide = line.getSide(through);
    if (center == null) {
      // If the two lines are colinear, there cannot be an arc as the
      // circle is infinitely big and has no center point. If side is
      // 0, the connecting arc line of this huge circle is a line
      // between the two points, so we can use #lineTo instead.
      // Otherwise we bail out:
      if (throughSide == 0)
        return lineTo(to);
      throw "Cannot put an arc through the given points: ${[from, through, to]}";
      //throw new Error("Cannot put an arc through the given points: "
      //  + [from, through, to]);
    }
    var vector = from.subtract(center),
      radius = vector.getLength(),
      extent = vector.getDirectedAngle(to.subtract(center)),
      centerSide = line.getSide(center);
    if (centerSide == 0) {
      // If the center is lying on the line, we might have gotten the
      // wrong sign for extent above. Use the sign of the side of the
      // through point.
      extent = throughSide * extent.abs();
    } else if (throughSide == centerSide) {
      // If the center is on the same side of the line (from, to) as
      // the through point, we're extending bellow 180 degrees and
      // need to adapt extent.
      extent -= 360 * (extent < 0 ? -1 : 1);
    }
    var ext = extent.abs(),
      count =  ext >= 360 ? 4 : (ext / 90).ceil(),
      inc = extent / count,
      half = inc * PI / 360,
      z = 4 / 3 * sin(half) / (1 + cos(half)),
      segments = [];
    for (var i = 0; i <= count; i++) {
      // Explicitely use to point for last segment, since depending
      // on values the calculation adds imprecision:
      var pt = i < count ? center.add(vector) : to;
      var out = i < count ? vector.rotate(90).multiply(z) : null;
      if (i == 0) {
        // Modify startSegment
        current.setHandleOut(out);
      } else {
        // Add new Segment
        segments.add(
          new Segment(pt, vector.rotate(-90).multiply(z), out));
      }
      vector = vector.rotate(inc);
    }
    // Add all segments at once at the end for higher performance
    _add(segments);
  }

  void lineBy(vector) {
    vector = Point.read(vector);
    var current = _getCurrentSegment(this);
    lineTo(current._point.add(vector));
  }

  void curveBy(throughVector, toVector, parameter) {
    throughVector = Point.read(throughVector);
    toVector = Point.read(toVector);
    var current = _getCurrentSegment(this)._point;
    curveTo(current.add(throughVector), current.add(toVector),
        parameter);
  }

  void arcBy(throughVector, toVector) {
    throughVector = Point.read(throughVector);
    toVector = Point.read(toVector);
    var current = _getCurrentSegment(this)._point;
    arcBy(current.add(throughVector), current.add(toVector));
  }

  void closePath() {
    setClosed(true);
  }

  // A dedicated scope for the tricky bounds calculations
  /**
   * Returns the bounding rectangle of the item excluding stroke width.
   */
  _getNormalBounds(matrix, [strokePadding]) {
    // Code ported and further optimised from:
    // http://blog.hackers-cafe.net/2009/06/how-to-calculate-bezier-curves-bounding.html
    var segments = _segments,
      first = segments[0];
    if (!first)
      return null;
    // TODO is this correct list initialization?
    List coords = new List(6),
          prevCoords = new List(6);
    // Make coordinates for first segment available in prevCoords.
    first._transformCoordinates(matrix, prevCoords, false);
    var min = prevCoords.getRange(0, 2),
      max = new List.from(min), // clone
      // Add some tolerance for good roots, as t = 0 / 1 are added
      // seperately anyhow, and we don't want joins to be added with
      // radiuses in getStrokeBounds()
      tMin = Numerical.TOLERANCE,
      tMax = 1 - tMin;
    var processSegment = (segment) {
      segment._transformCoordinates(matrix, coords, false);

      for (var i = 0; i < 2; i++) {
        var v0 = prevCoords[i], // prev.point
          v1 = prevCoords[i + 4], // prev.handleOut
          v2 = coords[i + 2], // segment.handleIn
          v3 = coords[i]; // segment.point

        var add = (value, t) {
          var padding = 0;
          if (value == null) {
            // Calculate bezier polynomial at t
            var u = 1 - t;
            value = u * u * u * v0
                + 3 * u * u * t * v1
                + 3 * u * t * t * v2
                + t * t * t * v3;
            // Only add strokeWidth to bounds for points which lie
            // within 0 < t < 1. The corner cases for cap and join
            // are handled in getStrokeBounds()
            padding = strokePadding != null ? strokePadding[i] : 0;
          }
          var left = value - padding,
            right = value + padding;
          if (left < min[i])
            min[i] = left;
          if (right > max[i])
            max[i] = right;

        };
        add(v3, null);

        // Calculate derivative of our bezier polynomial, divided by 3.
        // Dividing by 3 allows for simpler calculations of a, b, c and
        // leads to the same quadratic roots below.
        var a = 3 * (v1 - v2) - v0 + v3,
          b = 2 * (v0 + v2) - 4 * v1,
          c = v1 - v0;

        // Solve for derivative for quadratic roots. Each good root
        // (meaning a solution 0 < t < 1) is an extrema in the cubic
        // polynomial and thus a potential point defining the bounds
        // TODO: Use tolerance here, just like Numerical.solveQuadratic
        if (a == 0) {
          if (b == 0)
              continue;
          var t = -c / b;
          // Test for good root and add to bounds if good (same below)
          if (tMin < t && t < tMax)
            add(null, t);
          continue;
        }

        var q = b * b - 4 * a * c;
        if (q < 0)
          continue;
        // TODO: Match this with Numerical.solveQuadratic
        var sqrt = sqrt(q),
          f = -0.5 / a,
           t1 = (b - sqrt) * f,
          t2 = (b + sqrt) * f;
        if (tMin < t1 && t1 < tMax)
          add(null, t1);
        if (tMin < t2 && t2 < tMax)
          add(null, t2);
      }
      // Swap coordinate buffers
      var tmp = prevCoords;
      prevCoords = coords;
      coords = tmp;
    };
    for (var i = 1, l = segments.length; i < l; i++)
      processSegment(segments[i]);
    if (_closed)
      processSegment(first);
    return new Rectangle.create(min[0], min[1],
          max[0] - min[0], max[1] - min[1]);
  }

  /**
   * Returns the horizontal and vertical padding that a transformed round
   * stroke adds to the bounding box, by calculating the dimensions of a
   * rotated ellipse.
   */
  _getPenPadding(radius, [matrix]) {
    if (matrix == null)
      return [radius, radius];
    // If a matrix is provided, we need to rotate the stroke circle
    // and calculate the bounding box of the resulting rotated elipse:
    // Get rotated hor and ver vectors, and determine rotation angle
    // and elipse values from them:
    var mx = matrix.createShiftless(),
      hor = mx.transform(new Point.create(radius, 0)),
      ver = mx.transform(new Point.create(0, radius)),
      phi = hor.getAngleInRadians(),
      a = hor.getLength(),
      b = ver.getLength();
    // Formula for rotated ellipses:
    // x = cx + a*cos(t)*cos(phi) - b*sin(t)*sin(phi)
    // y = cy + b*sin(t)*cos(phi) + a*cos(t)*sin(phi)
    // Derivates (by Wolfram Alpha):
    // derivative of x = cx + a*cos(t)*cos(phi) - b*sin(t)*sin(phi)
    // dx/dt = a sin(t) cos(phi) + b cos(t) sin(phi) = 0
    // derivative of y = cy + b*sin(t)*cos(phi) + a*cos(t)*sin(phi)
    // dy/dt = b cos(t) cos(phi) - a sin(t) sin(phi) = 0
    // This can be simplified to:
    // tan(t) = -b * tan(phi) / a // x
    // tan(t) =  b * cot(phi) / a // y
    // Solving for t gives:
    // t = pi * n - arctan(b * tan(phi) / a) // x
    // t = pi * n + arctan(b * cot(phi) / a)
    //   = pi * n + arctan(b / tan(phi) / a) // y
    var sin_phi = sin(phi),
      cos_phi = cos(phi),
      tan_phi = tan(phi),
      tx = -atan(b * tan_phi / a),
      ty = atan(b / (tan_phi * a));
    // Due to symetry, we don't need to cycle through pi * n solutions:
    return [(a * cos(tx) * cos_phi - b * sin(tx) * sin_phi).abs(),
        (b * sin(ty) * cos_phi + a * cos(ty) * sin_phi).abs()];
  }

  /**
   * Returns the bounding rectangle of the item including stroke width.
   */
  _getStrokeBounds(matrix) {
    // See #draw() for an explanation of why we can access _style
    // properties directly here:
    var style = style;
    // TODO: Find a way to reuse 'bounds' cache instead?
    if (!style._strokeColor || !style._strokeWidth)
      return _getNormalBounds(matrix);
    var width = style._strokeWidth,
      radius = width / 2,
      padding = _getPenPadding(radius, matrix),
      join = style._strokeJoin,
      cap = style._strokeCap,
      // miter is relative to width. Divide it by 2 since we're
      // measuring half the distance below
      miter = style._miterLimit * width / 2,
      segments = this._segments,
      length = segments.length,
      bounds = _getBounds(matrix, padding);
    // Create a rectangle of padding size, used for union with bounds
    // further down
    var joinBounds = new Rectangle(new Size(padding).multiply(2));

    var add = (point) {
      bounds = bounds.include(matrix
        ? matrix._transformPoint(point, point) : point);
    };

    var addBevelJoin = (curve, t) {
      var point = curve.getPoint(t),
        normal = curve.getNormal(t).normalize(radius);
      add(point.add(normal));
      add(point.subtract(normal));
    };

    var addJoin = (segment, join) {
      // When both handles are set in a segment, the join setting is
      // ignored and round is always used.
      if (join === 'round' || !segment._handleIn.isZero()
          && !segment._handleOut.isZero()) {
        bounds = bounds.unite(joinBounds.setCenter(matrix
          ? matrix._transformPoint(segment._point) : segment._point));
      } else if (join == 'bevel') {
        var curve = segment.getCurve();
        addBevelJoin(curve, 0);
        addBevelJoin(curve.getPrevious(), 1);
      } else if (join == 'miter') {
        var curve2 = segment.getCurve(),
          curve1 = curve2.getPrevious(),
          point = curve2.getPoint(0),
          normal1 = curve1.getNormal(1).normalize(radius),
          normal2 = curve2.getNormal(0).normalize(radius),
          // Intersect the two lines
          line1 = new Line(point.subtract(normal1),
              new Point.create(-normal1.y, normal1.x)),
          line2 = new Line(point.subtract(normal2),
              new Point.create(-normal2.y, normal2.x)),
          corner = line1.intersect(line2);
        // Now measure the distance from the segment to the
        // intersection, which his half of the miter distance
        if (!corner || point.getDistance(corner) > miter) {
          addJoin(segment, 'bevel');
        } else {
          add(corner);
        }
      }
    };

    var addCap = (segment, cap, t) {
      switch (cap) {
      case 'round':
        return addJoin(segment, cap);
      case 'butt':
      case 'square':
        // Calculate the corner points of butt and square caps
        var curve = segment.getCurve(),
          point = curve.getPoint(t),
          normal = curve.getNormal(t).normalize(radius);
        // For square caps, we need to step away from point in the
        // direction of the tangent, which is the rotated normal
        if (cap === 'square')
          point = point.add(normal.rotate(t == 0 ? -90 : 90));
        add(point.add(normal));
        add(point.subtract(normal));
        break;
      }
    };

    for (var i = 1, l = length - (_closed ? 0 : 1); i < l; i++) {
      addJoin(segments[i], join);
    }
    if (_closed) {
      addJoin(segments[0], join);
    } else {
      addCap(segments[0], cap, 0);
      addCap(segments[length - 1], cap, 1);
    }
    return bounds;
  }

  /**
   * Returns the bounding rectangle of the item including handles.
   */
  _getHandleBounds(matrix, [stroke = 0, join = 0]) {
    // TODO is this correct list initialization?
    List coords = new List(6);
    var x1 = double.INFINITY,
      x2 = -x1,
      y1 = x1,
      y2 = x2;
    stroke = stroke / 2; // Stroke padding
    join = join / 2; // Join padding, for miterLimit
    for (var i = 0, l = _segments.length; i < l; i++) {
      var segment = _segments[i];
      segment._transformCoordinates(matrix, coords, false);
      for (var j = 0; j < 6; j += 2) {
        // Use different padding for points or handles
        var padding = j == 0 ? join : stroke,
          x = coords[j],
          y = coords[j + 1],
          xn = x - padding,
          xx = x + padding,
          yn = y - padding,
          yx = y + padding;
        if (xn < x1) x1 = xn;
        if (xx > x2) x2 = xx;
        if (yn < y1) y1 = yn;
        if (yx > y2) y2 = yx;
      }
    }
    return new Rectangle.create(x1, y1, x2 - x1, y2 - y1);
  }

  /**
   * Returns the rough bounding rectangle of the item that is shure to include
   * all of the drawing, including stroke width.
   */
  _getRoughBounds(matrix) {
    // Delegate to handleBounds, but pass on radius values for stroke and
    // joins. Hanlde miter joins specially, by passing the largets radius
    // possible.
    var style = style,
      width = style._strokeWidth;
    return _getHandleBounds(matrix, width,
        style._strokeJoin == 'miter'
          ? width * style._miterLimit
          : width);
  }

  _getBounds(type, matrix) {
    if(type == "bounds") _getNormalBounds(matrix);
    if(type == "strokeBounds") _getStrokeBounds(matrix);
    if(type == "handleBounds") _getHandleBounds(matrix);
    if(type == "roughBounds") _getRoughBounds(matrix);
  }
}
