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
library Item;
import "dart:math";
import "dart:html" hide Point;
import "../color/Color.dart";
import "../core/Core.dart";
import "../basic/Basic.dart";
import "./ChangeFlag.dart";
part "./HitResult.dart";
part "./Group.dart";
part "./Layer.dart";
part "./PlacedItem.dart";
part "./PlacedSymbol.dart";
part "./Raster.dart";

/**
 * @name Item
 *
 * @class The Item type allows you to access and modify the items in
 * Paper.js projects. Its functionality is inherited by different project
 * item types such as {@link Path}, {@link CompoundPath}, {@link Group},
 * {@link Layer} and {@link Raster}. They each add a layer of functionality that
 * is unique to their type, but share the underlying properties and functions
 * that they inherit from Item.
 */
class Item extends Callback {
//var Item = this.Item = Base.extend(Callback, /** @lends Item# */{
  // Flags defining which native events are required by which Paper events
  // as required for counting amount of necessary natives events.
  // The mapping is native -> virtual
  static Map mouseFlags = const {
    "mousedown": const {
      "mousedown": 1,
      "mousedrag": 1,
      "click": 1,
      "doubleclick": 1
    },
    "mouseup": const {
      "mouseup": 1,
      "mousedrag": 1,
      "click": 1,
      "doubleclick": 1
    },
    "mousemove": const {
      "mousedrag": 1,
      "mousemove": 1,
      "mouseenter": 1,
      "mouseleave": 1
    }
  };
  static int _next_id;

  // install method for mouse handlers
  void _installMouseHandler(String type) {
    // If the view requires counting of installed mouse events,
    // increase the counters now according to mouseFlags
    List<int> counters = _project.view._eventCounters;
    if(counters != null) {
      for(var key in mouseFlags.getKeys()) {
        counters[key] = (counters[key] != 0 ? counters[key] : 0) +
                        (mouseFlags[key][type] != null ? mouseFlags[key][type] : 0);
      }
    }
  }
  void _uninstallMouseHandler(String type) {
    // If the view requires counting of installed mouse events,
    // decrease the counters now according to mouseFlags
    var counters = _project.view._eventCounters;
    if (counters) {
      for (var key in mouseFlags.getKeys()) {
        if(mouseFlags[key].containsKey(type))
          counters[key] -= mouseFlags[key][type];  
      }
    }
  }
  static List _onFrameItems;
  static void _onFrame(event) {
    for(var handler in _onFrameItems) {
      handler.fire('frame', event);
    }
  }
  void _installFrameHandler() {
    if(_onFrameItems == null) _onFrameItems = [];
    if(_onFrameItems.length == 0) _project.view.attach('frame', _onFrame);
    _onFrameItems.add(this);
  }
  void _uninstallFrameHandler() {
    _onFrameItems.removeRange(_onFrameItems.indexOf(this), 1);
    if(_onFrameItems.length == 0) {
      _project.view.detach("frame", _onFrame);
    }
  }
  get onFrame => getEvent("frame");
  set onFrame(value) => setEvent("frame", value);
  get onMouseDown => getEvent("mousedown"); // TODO capitalization on these?
  set onMouseDown(value) => setEvent("mousedown", value);
  get onMouseUp => getEvent("mouseup");
  set onMouseUp(value) => setEvent("mouseup", value);
  get onMouseDrag => getEvent("mousedrag");
  set onMouseDrag(value) => setEvent("mousedrag", value);
  get onClick => getEvent("click");
  set onClick(value) => setEvent("click", value);
  get onDoubleClick => getEvent("doubleclick");
  set onDoubleClick(value) => setEvent("doubleclick", value);
  get onMouseMove => getEvent("mousemove");
  set onMouseMove(value) => setEvent("mousemove", value);
  get onMouseEnter => getEvent("mouseenter");
  set onMouseEnter(value) => setEvent("mouseenter", value);
  get onMouseLeave => getEvent("mouseleave");
  set onMouseLeave(value) => setEvent("mouseleave", value);

  Map _eventTypes;

  Item(/*Point or Matrix*/ [pointOrMatrix]) {
    // initialize fields
    _locked = false;
    _visible = true;
    _opacity = 1;
    _blendMode = 'normal';
    _guide = false;
    _selected = false;
    _clipMask = false;

    // build events
    _eventTypes = {};

    // Entry for all mouse events in the _events list
    var mouseEvent = {
      "install": _installMouseHandler,
      "uninstall": _uninstallMouseHandler
    };

    for(var event in ['onMouseDown', 'onMouseUp', 'onMouseDrag', 'onClick',
        'onDoubleClick', 'onMouseMove', 'onMouseEnter', 'onMouseLeave']) {
      _eventTypes[event] = mouseEvent;
    }
    _eventTypes["onFrame"] = {"install": _installFrameHandler,
                              "uninstall": _uninstallFrameHandler};

    if(_next_id == null) _next_id = 0;
    // Define this Item's unique id.
    _id = ++Item._next_id;
    // If _project is already set, the item was already moved into the DOM
    // hierarchy. Used by Layer, where it's added to project.layers instead
    if (_project == null)
      // TODO figure out global paper scope
      paper.project.activeLayer.addChild(this);
    // TextItem defines its own _style, based on CharacterStyle
    if (_style == null)
      // TODO port PathStyle
      _style = PathStyle.create(this);
    setStyle(_project.getCurrentStyle());
    _matrix = pointOrMatrix !== null
      ? pointOrMatrix is Matrix
        ? pointOrMatrix.clone()
        : new Matrix().translate(Point.read(pointOrMatrix))
      : new Matrix();
  }

  /**
   * Private notifier that is called whenever a change occurs in this item or
   * its sub-elements, such as Segments, Curves, PathStyles, etc.
   *
   * @param {ChangeFlag} flags describes what exactly has changed.
   */
  // public version
  changed(int flags) {
    _changed(flags);
  }
  _changed(int flags) {
    if ((flags & ChangeFlag.GEOMETRY) != 0) {
      // Clear cached bounds and position whenever geometry changes
      // TODO figure out bounds
      _bounds = null;
      _position = null;
    }
    if (_parent != null
        && ((flags & (ChangeFlag.GEOMETRY | ChangeFlag.STROKE)) != 0)) {
      // Clear cached bounds of all items that this item contributes to.
      // We call this on the parent, since the information is cached on
      // the parent, see getBounds().
      _parent._clearBoundsCache();
    }
    if ((flags & ChangeFlag.HIERARCHY) != 0) {
      // Clear cached bounds of all items that this item contributes to.
      // We don't call this on the parent, since we're already the parent
      // of the child that modified the hierarchy (that's where these
      // HIERARCHY notifications go)
      _clearBoundsCache();
    }
    if ((flags & ChangeFlag.APPEARANCE) != 0) {
      _project._needsRedraw();
    }
    // If this item is a symbol's definition, notify it of the change too
    // TODO I guess symbol sets this. declare it
    if (_parentSymbol != null)
      _parentSymbol._changed(flags);
    // Have project keep track of changed items, so they can be iterated.
    // This can be used for example to update the SVG tree. Needs to be
    // activated in Project
    if (_project._changes != null) {
      var entry = _project._changesById[_id];
      if (entry != null) {
        entry.flags |= flags;
      } else {
        entry = { "item": this, "flags": flags };
        _project._changesById[_id] = entry;
        _project._changes.push(entry);
      }
    }
  }

  /**
   * The unique id of the item.
   *
   * @type Number
   * @bean
   */
  int _id;
  int getId() {
    return _id;
  }
  // property
  int get id => _id;

  /**
   * The name of the item. If the item has a name, it can be accessed by name
   * through its parent's children list.
   *
   * @type String
   * @bean
   *
   * @example {@paperscript}
   * var path = new Path.Circle(new Point(80, 50), 35);
   * // Set the name of the path:
   * path.name = 'example';
   *
   * // Create a group and add path to it as a child:
   * var group = new Group();
   * group.addChild(path);
   *
   * // The path can be accessed by name:
   * group.children['example'].fillColor = 'red';
   */
  String _name;
  String getName() {
    return _name;
  }
  // property
  String get name => _name;

  void setName(String name) {
    // Note: Don't check if the name has changed and bail out if it has not,
    // because setName is used internally also to update internal structures
    // when an item is moved from one parent to another.

    // If the item already had a name, remove the reference to it from the
    // parent's children object:
    if (_name != null)
      _removeFromNamed();
    _name = name;
    if (name != null && _parent != null) {
      // TODO declare _children and _namedChildren
      var children = _parent._children;
      var namedChildren = _parent._namedChildren;
      // TODO namedChildren[name] is itself a list?
      if(namedChildren[name] == null) {
        namedChildren[name] = [this];
      } else {
        namedChildren[name].add(this);
      }
      // TODO we can't do this unless we use MapList
      //children[name] = this;
    }
    _changed(ChangeFlag.ATTRIBUTE);
  }
  // property
  set name(String name) {
    setName(name);
  }

  /**
   * The path style of the item.
   *
   * @name Item#getStyle
   * @type PathStyle
   * @bean
   *
   * @example {@paperscript}
   * // Applying several styles to an item in one go, by passing an object
   * // to its style property:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   * circle.style = {
   *   fillColor: 'blue',
   *   strokeColor: 'red',
   *   strokeWidth: 5
   * };
   *
   * @example {@paperscript split=true height=100}
   * // Copying the style of another item:
   * var path = new Path.Circle(new Point(50, 50), 30);
   * path.fillColor = 'red';
   *
   * var path2 = new Path.Circle(new Point(180, 50), 20);
   * // Copy the path style of path:
   * path2.style = path.style;
   *
   * @example {@paperscript}
   * // Applying the same style object to multiple items:
   * var myStyle = {
   *   fillColor: 'red',
   *   strokeColor: 'blue',
   *   strokeWidth: 4
   * };
   *
   * var path = new Path.Circle(new Point(80, 50), 30);
   * path.style = myStyle;
   *
   * var path2 = new Path.Circle(new Point(150, 50), 20);
   * path2.style = myStyle;
   */
  PathStyle _style;
  PathStyle getStyle() => _style;
  PathStyle get style => getStyle();
  void setStyle(Style style) {
    _style = style;
  }
  set style(PathStyle style) => setStyle(style);

  // TODO I _think_ we need to:
  // get/set style (notify owners on style setting? maybe not)
  // get/set style properties (def with owner notification)

  // Produce getter/setters for properties. We need setters because we want to
  // call _changed() if a property was modified.
  /**
   * Specifies whether the item is locked.
   *
   * @name Item#locked
   * @type Boolean
   * @default false
   * @ignore
   */
  bool _locked; // = false;
  bool get locked => _locked;
  set locked(bool locked) {
    if(_locked != locked) {
      _locked = locked;
      _changed(ChangeFlag.ATTRIBUTE);
    }
  }

  /**
   * Specifies whether the item is visible. When set to {@code false}, the
   * item won't be drawn.
   *
   * @name Item#visible
   * @type Boolean
   * @default true
   *
   * @example {@paperscript}
   * // Hiding an item:
   * var path = new Path.Circle(new Point(50, 50), 20);
   * path.fillColor = 'red';
   *
   * // Hide the path:
   * path.visible = false;
   */
  bool _visible; // = true;
  bool get visible => _visible;
  set visible(bool visible) {
    if(_visible != visible) {
      _visible = visible;
      _changed(Change.ATTRIBUTE);
    }
  }

  /**
   * The blend mode of the item.
   *
   * @name Item#blendMode
   * @type String('normal', 'multiply', 'screen', 'overlay', 'soft-light',
   * 'hard-light', 'color-dodge', 'color-burn', 'darken', 'lighten',
   * 'difference', 'exclusion', 'hue', 'saturation', 'luminosity', 'color',
   * 'add', 'subtract', 'average', 'pin-light', 'negation')
   * @default 'normal'
   *
   * @example {@paperscript}
   * // Setting an item's blend mode:
   *
   * // Create a white rectangle in the background
   * // with the same dimensions as the view:
   * var background = new Path.Rectangle(view.bounds);
   * background.fillColor = 'white';
   *
   * var circle = new Path.Circle(new Point(80, 50), 35);
   * circle.fillColor = 'red';
   *
   * var circle2 = new Path.Circle(new Point(120, 50), 35);
   * circle2.fillColor = 'blue';
   *
   * // Set the blend mode of circle2:
   * circle2.blendMode = 'multiply';
   */
  String _blendMode; //= 'normal';
  String get blendMode => _blendMode;
  set blendMode(String blendMode) {
    if(_blendMode != blendMode) {
      _blendMode = blendMode;
      _changed(Change.ATTRIBUTE);
    }
  }

  /**
   * The opacity of the item as a value between {@code 0} and {@code 1}.
   *
   * @name Item#opacity
   * @type Number
   * @default 1
   *
   * @example {@paperscript}
   * // Making an item 50% transparent:
   * var circle = new Path.Circle(new Point(80, 50), 35);
   * circle.fillColor = 'red';
     *
   * var circle2 = new Path.Circle(new Point(120, 50), 35);
   * circle2.style = {
   *   fillColor: 'blue',
   *   strokeColor: 'green',
   *   strokeWidth: 10
   * };
   *
   * // Make circle2 50% transparent:
   * circle2.opacity = 0.5;
   */
  num _opacity; //= 1;
  num get opacity => _opacity;
  set opacity(num opacity) {
    if(_opacity != opacity) {
      _opacity = opacity;
      _changed(Change.ATTRIBUTE);
    }
  }

  // TODO: Implement guides
  /**
   * Specifies whether the item functions as a guide. When set to
   * {@code true}, the item will be drawn at the end as a guide.
   *
   * @name Item#guide
   * @type Number
   * @default 1
   */
  // TODO why is does this have @type Number and @default 1?
  bool _guide; // = false;
  bool get guide => _guide;
  set guide(bool guide) {
    if(_guide != guide) {
      _guide = guide;
      _changed(Change.ATTRIBUTE);
    }
  }

  /**
   * Specifies whether an item is selected and will also return {@code true}
   * if the item is partially selected (groups with some selected or partially
   * selected paths).
   *
   * Paper.js draws the visual outlines of selected items on top of your
   * project. This can be useful for debugging, as it allows you to see the
   * construction of paths, position of path curves, individual segment points
   * and bounding boxes of symbol and raster items.
   *
   * @type Boolean
   * @default false
   * @bean
   * @see Project#selectedItems
   * @see Segment#selected
   * @see Point#selected
   *
   * @example {@paperscript}
   * // Selecting an item:
   * var path = new Path.Circle(new Size(80, 50), 35);
   * path.selected = true; // Select the path
   */
  bool _selected; // = false;
  bool isSelected() {
    if (_children != null) {
      for (var i = 0, l = _children.length; i < l; i++)
        if (_children[i].isSelected())
          return true;
    }
    return _selected;
  }
  bool get selected => isSelected();

  void setSelected(bool selected, [bool noChildren = false]) {
    // Don't recursively call #setSelected() if it was called with
    // noChildren set to true, see #setFullySelected().
    if (_children != null && !noChildren) {
      for (var i = 0, l = _children.length; i < l; i++)
        _children[i].setSelected(selected);
    } else if (selected != _selected) {
      _selected = selected;
      _project._updateSelection(this);
      _changed(Change.ATTRIBUTE);
    }
  }
  set selected(bool selected) => setSelected(selected);

  bool isFullySelected() {
    if (_children != null && _selected) {
      for (var i = 0, l = _children.length; i < l; i++)
        if (!_children[i].isFullySelected())
          return false;
      return true;
    }
    // If there are no children, this is the same as #selected
    return _selected;
  }

  void setFullySelected(bool selected) {
    if (_children != null) {
      for (var i = 0, l = _children.length; i < l; i++)
        _children[i].setFullySelected(selected);
    }
    // Pass true for hidden noChildren argument
    setSelected(selected, true);
  }

  /**
   * Specifies whether the item defines a clip mask. This can only be set on
   * paths, compound paths, and text frame objects, and only if the item is
   * already contained within a clipping group.
   *
   * @type Boolean
   * @default false
   * @bean
   */
  bool _clipMask;// = false;
  bool isClipMask() {
    return _clipMask;
  }
  bool get clipMask => _clipMask;

  void setClipMask(bool clipMask) {
    // On-the-fly conversion to boolean:
    if (_clipMask != clipMask) {
      _clipMask = clipMask;
      if (clipMask) {
        setFillColor(null);
        setStrokeColor(null);
      }
      _changed(Change.ATTRIBUTE);
      // Tell the parent the clipping mask has changed
      if (_parent != null)
        _parent._changed(ChangeFlag.CLIPPING);
    }
  }
  set clipMask(bool clipMask) => setClipMask(clipMask);

  // TODO: get/setIsolated (print specific feature)
  // TODO: get/setKnockout (print specific feature)
  // TODO: get/setAlphaIsShape
  // TODO: get/setData

  /**
   * {@grouptitle Position and Bounding Boxes}
   *
   * The item's position within the project. This is the
   * {@link Rectangle#center} of the item's {@link #bounds} rectangle.
   *
   * @type Point
   * @bean
   *
   * @example {@paperscript}
   * // Changing the position of a path:
   *
   * // Create a circle at position { x: 10, y: 10 }
   * var circle = new Path.Circle(new Point(10, 10), 10);
   * circle.fillColor = 'red';
   *
   * // Move the circle to { x: 20, y: 20 }
   * circle.position = new Point(20, 20);
   *
   * // Move the circle 100 points to the right and 50 points down
   * circle.position += new Point(100, 50);
   *
   * @example {@paperscript split=true height=100}
   * // Changing the x coordinate of an item's position:
   *
   * // Create a circle at position { x: 20, y: 20 }
   * var circle = new Path.Circle(new Point(20, 20), 10);
   * circle.fillColor = 'red';
   *
   * // Move the circle 100 points to the right
   * circle.position.x += 100;
   */
  // TODO init in constructor?
  Point _position;
  Point getPosition([bool dontLink = false]) {
    // Cache position value.
    // Pass true for dontLink in getCenter(), so receive back a normal point
    var pos = _position != null ? _position
        : (_position = this.getBounds().getCenter(true));
    // Do not cache LinkedPoints directly, since we would not be able to
    // use them to calculate the difference in #setPosition, as when it is
    // modified, it would hold new values already and only then cause the
    // calling of #setPosition.
    return dontLink ? pos
        : new LinkedPoint.create(this, setPosition, pos.x, pos.y);
  }
  Point get position => getPosition();

  void setPosition(/*Point*/ point) {
    // Calculate the distance to the current position, by which to
    // translate the item. Pass true for dontLink, as we do not need a
    // LinkedPoint to simply calculate this distance.
    translate(Point.read(point).subtract(getPosition(true)));
  }
  set position(/*Point*/ point) => setPosition(point);

  /**
   * The item's transformation matrix, defining position and dimensions in the
   * document.
   *
   * @type Matrix
   * @bean
   */
  Matrix _matrix;
  Matrix getMatrix() {
    return _matrix;
  }
  Matrix get matrix => _matrix;

  void setMatrix(Matrix matrix) {
    // Use Matrix#initialize to easily copy over values.
    _matrix.initialize(matrix);
    _changed(Change.GEOMETRY);
  }
  set matrix(Matrix matrix) => setMatrix(matrix);

  /**
   * Private method that deals with the calling of _getBounds, recursive
   * matrix concatenation and handles all the complicated caching mechanisms.
   */
  Map _bounds;
  Map _boundsCache;
  Map _boundsType;
  Rectangle _getCachedBounds(String type, [Matrix matrix, cacheItem]) {
    // See if we can cache these bounds. We only cache the bounds
    // transformed with the internally stored _matrix, (the default if no
    // matrix is passed).
    bool cache = (matrix == null || matrix.equals(this._matrix)) && type != null;
    // Set up a boundsCache structure that keeps track of items that keep
    // cached bounds that depend on this item. We store this in our parent,
    // for multiple reasons:
    // The parent receives HIERARCHY change notifications for when its
    // children are added or removed and can thus clear the cache, and we
    // save a lot of memory, e.g. when grouping 100 items and asking the
    // group for its bounds. If stored on the children, we would have 100
    // times the same structure.
    // Note: This needs to happen before returning cached values, since even
    // then, _boundsCache needs to be kept up-to-date.
    if (cacheItem != null && _parent != null) {
      // Set-up the parent's boundsCache structure if it does not
      // exist yet and add the cacheItem to it.
      var id = cacheItem._id;
      // TODO where is this used? is _parent._boundsCache ever not a map?
      Map ref = _parent._boundsCache
          = _parent._boundsCache != null ? _parent._boundsCache : {
        // Use both a hashtable for ids and an array for the list,
        // so we can keep track of items that were added already
        "ids": {},
        "list": []
      };
      if (!ref["ids"][id]) {
        ref["list"].add(cacheItem);
        ref["ids"][id] = cacheItem;
      }
    }
    if (cache && _bounds != null && _bounds[cache] != null)
      return _bounds[cache];
    // If the result of concatenating the passed matrix with our internal
    // one is an identity transformation, set it to null for faster
    // processing
    bool identity = _matrix.isIdentity();
    matrix = matrix == null || matrix.isIdentity()
        ? identity ? null : _matrix
        : identity ? matrix : matrix.clone().concatenate(_matrix);
    // If we're caching bounds on this item, pass it on as cacheItem, so the
    // children can setup the _boundsCache structures for it.
    var bounds = _getBounds(type, matrix, cache ? this : cacheItem);
    // If we can cache the result, update the _bounds cache structure
    // before returning
    if (cache) {
      if (_bounds == null)
        _bounds = {};
      // Put a separate instance into the cache, so modifications of the
      // returned one won't affect it.
      _bounds[cache] = new Rectangle(bounds);
    }
    return bounds;
  }

  /**
   * Clears cached bounds of all items that the children of this item are
   * contributing to. See #_getCachedBounds() for an explanation why this
   * information is stored on parents, not the children themselves.
   */
  void _clearBoundsCache() {
    if (_boundsCache != null) {
      for (var i = 0, list = _boundsCache["list"], l = list.length;
          i < l; i++) {
        var item = list[i];
        item._bounds = null;
        // We need to recursively call _clearBoundsCache, because if the
        // cache for this item's children is not valid anymore, that
        // propagates up the DOM tree.
        if (item != this && item._boundsCache != null)
          item._clearBoundsCache();
      }
      _boundsCache = null;
    }
  }

  /**
   * Protected method used in all the bounds getters. It loops through all the
   * children, gets their bounds and finds the bounds around all of them.
   * Subclasses override it to define calculations for the various required
   * bounding types.
   */
  Rectangle _getBounds([String type, Matrix matrix, cacheItem]) {
    // Note: We cannot cache these results here, since we do not get
    // _changed() notifications here for changing geometry in children.
    // But cacheName is used in sub-classes such as PlacedItem.
    var children = _children;
    // TODO: What to return if nothing is defined, e.g. empty Groups?
    // Scriptographer behaves weirdly then too.
    if (children == null || children.length == 0)
      return new Rectangle();
    num x1 = double.INFINITY;
    num x2 = -x1;
    num y1 = x1;
    num y2 = x2;
    for (var i = 0, l = children.length; i < l; i++) {
      var child = children[i];
      if (child._visible) {
        var rect = child._getCachedBounds(type, matrix, cacheItem);
        x1 = min(rect.x, x1);
        y1 = min(rect.y, y1);
        x2 = max(rect.x + rect.width, x2);
        y2 = max(rect.y + rect.height, y2);
      }
    }
    return new Rectangle.create(x1, y1, x2 - x1, y2 - y1);
  }

  void setBounds(/*Rectangle*/ rect) {
    rect = Rectangle.read(rect);
    var bounds = getBounds(),
      matrix = new Matrix();
    Point center = rect.getCenter();
    // Read this from bottom to top:
    // Translate to new center:
    matrix.translate(center);
    // Scale to new Size, if size changes and avoid divisions by 0:
    if (rect.width != bounds.width || rect.height != bounds.height) {
      matrix.scale(
          bounds.width != 0 ? rect.width / bounds.width : 1,
          bounds.height != 0 ? rect.height / bounds.height : 1);
    }
    // Translate to bounds center:
    center = bounds.getCenter();
    matrix.translate(-center);
    // Now execute the transformation
    // TODO: do we need to apply too, or just change the matrix?
    transform(matrix);
  }

  // Produce getters for bounds properties. These handle caching, matrices
  // and redirect the call to the private _getBounds, which can be
  // overridden by subclasses, see below.
  Rectangle boundsAccessor(String name, [Matrix matrix]) {
    var type = _boundsType;
    Rectangle bounds = _getCachedBounds(
      // Allow subclasses to override _boundsType if they use the same
      // calculations for multiple types. The default is name:
      type is String ? type : type != null ? type[name] : name,
      // Pass on the optional matrix
      matrix
      );
    // If we're returning 'bounds', create a LinkedRectangle that uses the
    // setBounds() setter to update the Item whenever the bounds are
    // changed:
    return name == "bounds" ? new LinkedRectangle.create(this, setBounds,
      bounds.x, bounds.y, bounds.width, bounds.height) : bounds;
  }

  /**
   * The bounding rectangle of the item excluding stroke width.
   *
   * @name Item#getBounds
   * @type Rectangle
   * @bean
   */
   Rectangle getBounds([Matrix matrix]) => boundsAccessor("bounds", matrix);
   Rectangle get bounds => getBounds();

  /**
   * The bounding rectangle of the item including stroke width.
   *
   * @name Item#getStrokeBounds
   * @type Rectangle
   * @bean
   */
   Rectangle getStrokeBounds([Matrix matrix]) => boundsAccessor("strokeBounds", matrix);
   Rectangle get strokeBounds => getStrokeBounds();

  /**
   * The bounding rectangle of the item including handles.
   *
   * @name Item#getHandleBounds
   * @type Rectangle
   * @bean
   */
   Rectangle getHandleBounds([Matrix matrix]) => boundsAccessor("handleBounds", matrix);
   Rectangle get handleBounds => getHandleBounds();

  /**
   * TODO typo below shure-> sure. submit pull request?
   * The rough bounding rectangle of the item that is sure to include all of
   * the drawing, including stroke width.
   *
   * @name Item#getRoughBounds
   * @type Rectangle
   * @bean
   * @ignore
   */
   Rectangle getRoughBounds([Matrix matrix]) => boundsAccessor("roughBounds", matrix);
   Rectangle get roughBounds => getRoughBounds();

  /**
   * {@grouptitle Project Hierarchy}
   * The project that this item belongs to.
   *
   * @type Project
   * @bean
   */
  Project _project;
  Project getProject() {
    return _project;
  }
  Project get project => _project;

  void _setProject(Project project) {
    if (_project != project) {
      _project = project;
      if (_children) {
        for (var i = 0, l = _children.length; i < l; i++) {
          _children[i]._setProject(project);
        }
      }
    }
  }

  /**
   * The layer that this item is contained within.
   *
   * @type Layer
   * @bean
   */
  Layer getLayer() {
    var parent = this;
    while (parent = parent._parent != null) {
      if (parent is Layer)
        return parent;
    }
    return null;
  }
  Layer get layer => getLayer();

  /**
   * The item that this item is contained within.
   *
   * @type Item
   * @bean
   *
   * @example
   * var path = new Path();
   *
   * // New items are placed in the active layer:
   * console.log(path.parent == project.activeLayer); // true
   *
   * var group = new Group();
   * group.addChild(path);
   *
   * // Now the parent of the path has become the group:
   * console.log(path.parent == group); // true
   */
  Item _parent;
  Item getParent() {
    return _parent;
  }
  Item get parent => _parent;

  /**
   * The children items contained within this item. Items that define a
   * {@link #name} can also be accessed by name.
   *
   * <b>Please note:</b> The children array should not be modified directly
   * using array functions. To remove single items from the children list, use
   * {@link Item#remove()}, to remove all items from the children list, use
   * {@link Item#removeChildren()}. To add items to the children list, use
   * {@link Item#addChild(item)} or {@link Item#insertChild(index,item)}.
   *
   * @type Item[]
   * @bean
   *
   * @example {@paperscript}
   * // Accessing items in the children array:
   * var path = new Path.Circle(new Point(80, 50), 35);
   *
   * // Create a group and move the path into it:
   * var group = new Group();
   * group.addChild(path);
   *
   * // Access the path through the group's children array:
   * group.children[0].fillColor = 'red';
   *
   * @example {@paperscript}
   * // Accessing children by name:
   * var path = new Path.Circle(new Point(80, 50), 35);
   * // Set the name of the path:
   * path.name = 'example';
   *
   * // Create a group and move the path into it:
   * var group = new Group();
   * group.addChild(path);
   *
   * // The path can be accessed by name:
   * group.children['example'].fillColor = 'orange';
   *
   * @example {@paperscript}
   * // Passing an array of items to item.children:
   * var path = new Path.Circle(new Point(80, 50), 35);
   *
   * var group = new Group();
   * group.children = [path];
   *
   * // The path is the first child of the group:
   * group.firstChild.fillColor = 'green';
   */
  List<Item> _children;
  List<Item> getChildren() {
    return this._children;
  }
  List<Item> get children => getChildren();

  void setChildren(List<Item> items) {
    removeChildren();
    addChildren(items);
  }
  
  // storage for named children
  // TODO use MapList for _children
  Map<String, List<Item>> _namedChildren;
  

  /**
   * The first item contained within this item. This is a shortcut for
   * accessing {@code item.children[0]}.
   *
   * @type Item
   * @bean
   */
  Item getFirstChild() {
    return _children != null ? _children[0] : null;
  }

  /**
   * The last item contained within this item.This is a shortcut for
   * accessing {@code item.children[item.children.length - 1]}.
   *
   * @type Item
   * @bean
   */
  Item getLastChild() {
    return _children != null ? _children[_children.length - 1]
        : null;
  }

  /**
   * The next item on the same level as this item.
   *
   * @type Item
   * @bean
   */
  Item getNextSibling() {
    // TODO I think we have to be more careful about index overflow
    return _parent != null ? _parent._children[_index + 1] : null;
  }

  /**
   * The previous item on the same level as this item.
   *
   * @type Item
   * @bean
   */
  Item getPreviousSibling() {
    // TODO I think we have to be more careful about index overflow
    return _parent != null ? _parent._children[_index - 1] : null;
  }

  /**
   * The index of this item within the list of its parent's children.
   *
   * @type Number
   * @bean
   */
  int getIndex() {
    return _index;
  }
  int _index;

  /**
   * Clones the item within the same project and places the copy above the
   * item.
   *
   * @return {Item} the newly cloned item
   *
   * @example {@paperscript}
   * // Cloning items:
   * var circle = new Path.Circle(new Point(50, 50), 10);
   * circle.fillColor = 'red';
   *
   * // Make 20 copies of the circle:
   * for (var i = 0; i < 20; i++) {
   *   var copy = circle.clone();
   *
   *   // Distribute the copies horizontally, so we can see them:
   *   copy.position.x += i * copy.bounds.width;
   * }
   */
  Item clone() {
    return _clone(new Item());
  }

  Item cloneTo(Item copy) {
    return _clone(copy);
  }
  Item _clone(Item copy) {
    // Copy over style
    copy.setStyle(_style);
    // If this item has children, clone and append each of them:
    if (_children != null) {
      for (var i = 0, l = _children.length; i < l; i++)
        copy.addChild(_children[i].clone());
    }
    // TODO other fields?
    copy._locked = _locked;
    copy._visible = _visible;
    copy._blendMode = _blendMode;
    copy._opacity = _opacity;
    copy._clipMask = _clipMask;
    copy._guide = _guide;
    // Use Matrix#initialize to easily copy over values.
    copy._matrix.initialize(_matrix);
    // Copy over the selection state, use setSelected so the item
    // is also added to Project#selectedItems if it is selected.
    copy.setSelected(_selected);
    // Only set name once the copy is moved, to avoid setting and unsettting
    // name related structures.
    if (_name != null)
      copy.setName(_name);
    return copy;
  }

  /**
   * When passed a project, copies the item to the project,
   * or duplicates it within the same project. When passed an item,
   * copies the item into the specified item.
   *
   * @param {Project|Layer|Group|CompoundPath} item the item or project to
   * copy the item to
   * @return {Item} the new copy of the item
   */
  Item copyTo(/*Item of Project*/ itemOrProject) {
    var copy = clone();
    if (itemOrProject.layers) {
      itemOrProject.activeLayer.addChild(copy);
    } else {
      itemOrProject.addChild(copy);
    }
    return copy;
  }

  /**
   * Rasterizes the item into a newly created Raster object. The item itself
   * is not removed after rasterization.
   *
   * @param {Number} [resolution=72] the resolution of the raster in dpi
   * @return {Raster} the newly created raster item
   *
   * @example {@paperscript}
   * // Rasterizing an item:
   * var circle = new Path.Circle(new Point(80, 50), 5);
   * circle.fillColor = 'red';
   *
   * // Create a rasterized version of the path:
   * var raster = circle.rasterize();
   *
   * // Move it 100pt to the right:
   * raster.position.x += 100;
   *
   * // Scale the path and the raster by 300%, so we can compare them:
   * circle.scale(5);
   * raster.scale(5);
   */
  Raster rasterize([num resolution = 72]) {
    Rectangle bounds = getStrokeBounds();
    num scale = resolution / 72;
    var canvas = CanvasProvider.getCanvas(bounds.getSize().multiply(scale));
    var ctx = canvas.getContext('2d');
    Matrix matrix = new Matrix().scale(scale).translate(-bounds);
    matrix.applyToContext(ctx);
    // XXX: Decide how to handle _matrix
    draw(ctx, {});
    var raster = new Raster(canvas);
    raster.setBounds(bounds);
    return raster;
  }

  /**
   * Perform a hit test on the item (and its children, if it is a
   * {@link Group} or {@link Layer}) at the location of the specified point.
   * 
   * The optional options object allows you to control the specifics of the
   * hit test and may contain a combination of the following values:
   * <b>tolerance:</b> {@code Number} - The tolerance of the hit test in
   * points.
   * <b>options.type:</b> Only hit test again a certain item
   * type: {@link PathItem}, {@link Raster}, {@link TextItem}, etc.
   * <b>options.fill:</b> {@code Boolean} - Hit test the fill of items.
   * <b>options.stroke:</b> {@code Boolean} - Hit test the curves of path
   * items, taking into account stroke width.
   * <b>options.segment:</b> {@code Boolean} - Hit test for
   * {@link Segment#point} of {@link Path} items.
   * <b>options.handles:</b> {@code Boolean} - Hit test for the handles
   * ({@link Segment#handleIn} / {@link Segment#handleOut}) of path segments.
   * <b>options.ends:</b> {@code Boolean} - Only hit test for the first or
   * last segment points of open path items.
   * <b>options.bounds:</b> {@code Boolean} - Hit test the corners and
   * side-centers of the bounding rectangle of items ({@link Item#bounds}).
   * <b>options.center:</b> {@code Boolean} - Hit test the
   * {@link Rectangle#center} of the bounding rectangle of items
   * ({@link Item#bounds}).
   * <b>options.guide:</b> {@code Boolean} - Hit test items that have
   * {@link Item#guide} set to {@code true}.
   * <b>options.selected:</b> {@code Boolean} - Only hit selected items.
   *
   * @param {Point} point The point where the hit test should be performed
   * @param {Object} [options={ fill: true, stroke: true, segments: true,
   * tolerance: 2 }]
   * @return {HitResult} A hit result object that contains more
   * information about what exactly was hit or {@code null} if nothing was
   * hit.
   */
  HitResult hitTest(Point point, Map options) {
    options = HitResult.getOptions(point, options);
    point = options["point"] = _matrix.inverseTransform(options["point"]);
    // Check if the point is withing roughBounds + tolerance, but only if
    // this item does not have children, since we'd have to travel up the
    // chain already to determine the rough bounds.
    if (_children == null && !this.getRoughBounds()
        .expand(options["tolerance"]).containsPoint(point))
      return null;
    if ((options["center"] || options["bounds"]) &&
        // Ignore top level layers:
        !(this is Layer && _parent == null)) {
      // Don't get the transformed bounds, check against transformed
      // points instead
      Rectangle bounds = getBounds();
      var that = this;
        // TODO: Move these into a private scope
      var points = ['TopLeft', 'TopRight', 'BottomLeft', 'BottomRight',
        'LeftCenter', 'TopCenter', 'RightCenter', 'BottomCenter'];
      var res;
      var checkBounds = (type, part) {
        var pt = bounds.getNamedPoint(part);
        // TODO: We need to transform the point back to the coordinate
        // system of the DOM level on which the inquiry was started!
        if (point.getDistance(pt) < options["tolerance"])
          return new HitResult(type, that,
              { "name": Base.hyphenate(part), "point": pt });
      };
      if (options["center"] && (res = checkBounds('center', 'Center') != null))
        return res;
      if (options["bounds"]) {
        for (var i = 0; i < 8; i++)
          if (res = checkBounds('bounds', points[i]))
            return res;
      }
    }

    // TODO: Support option.type even for things like CompoundPath where
    // children are matched but the parent is returned.

    // Filter for guides or selected items if that's required
    return _children != null || !(options["guides"] && !_guide
        || options["selected"] && !_selected)
          ? _hitTest(point, options) : null;
  }

  HitResult _hitTest(Point point, Map options) {
    if (_children != null) {
      // Loop backwards, so items that get drawn last are tested first
      for (var i = _children.length - 1; i >= 0; i--) {
        var res = _children[i].hitTest(point, options);
        if (res != null) return res;
      }
    }
    return null;
  }

  /**
   * {@grouptitle Hierarchy Operations}
   * Adds the specified item as a child of this item at the end of the
   * its children list. You can use this function for groups, compound
   * paths and layers.
   *
   * @param {Item} item The item to be added as a child
   */
  bool addChild(Item item) {
    return this.insertChild(null, item);
  }

  /**
   * Inserts the specified item as a child of this item at the specified
   * index in its {@link #children} list. You can use this function for
   * groups, compound paths and layers.
   *
   * @param {Number} index
   * @param {Item} item The item to be appended as a child
   */
  bool insertChild(int index, Item item) {
    if (_children != null) {
      item._remove(false, true);
      Base.splice(this._children, [item], index, 0);
      item._parent = this;
      item._setProject(_project);
      // Setting the name again makes sure all name lookup structures are
      // kept in sync.
      if (item._name != null)
        item.setName(item._name);
      _changed(Change.HIERARCHY);
      return true;
    }
    return false;
  }

  /**
   * Adds the specified items as children of this item at the end of the
   * its children list. You can use this function for groups, compound
   * paths and layers.
   *
   * @param {item[]} items The items to be added as children
   */
  void addChildren(List<Item> items) {
    for(Item item in items) {
      insertChild(null, item);
    }
  }

  /**
   * Inserts the specified items as children of this item at the specified
   * index in its {@link #children} list. You can use this function for
   * groups, compound paths and layers.
   *
   * @param {Number} index
   * @param {Item[]} items The items to be appended as children
   */
  void insertChildren(int index, List<Item> items) {
    for(Item item in items) {
      if(insertChild(index, item))
        index++;
    }
  }

  /**
   * Inserts this item above the specified item.
   *
   * @param {Item} item The item above which it should be moved
   * @return {Boolean} {@true it was inserted}
   */
  bool insertAbove(Item item) {
    var index = item._index;
    if (item._parent == _parent && index < _index)
       index++;
    return item._parent.insertChild(index, this);
  }

  /**
   * Inserts this item below the specified item.
   *
   * @param {Item} item The item above which it should be moved
   * @return {Boolean} {@true it was inserted}
   */
  bool insertBelow(Item item) {
    var index = item._index;
    if (item._parent == _parent && index > _index)
       index--;
    return item._parent.insertChild(index, this);
  }

  /**
   * Inserts the specified item as a child of this item by appending it to
   * the list of children and moving it above all other children. You can
   * use this function for groups, compound paths and layers.
   *
   * @param {Item} item The item to be appended as a child
   * @deprecated use {@link #addChild(item)} instead.
   */
  bool appendTop(Item item) {
    return addChild(item);
  }

  /**
   * Inserts the specified item as a child of this item by appending it to
   * the list of children and moving it below all other children. You can
   * use this function for groups, compound paths and layers.
   *
   * @param {Item} item The item to be appended as a child
   * @deprecated use {@link #insertChild(index, item)} instead.
   */
  bool appendBottom(Item item) {
    return insertChild(0, item);
  }

  /**
   * Moves this item above the specified item.
   *
   * @param {Item} item The item above which it should be moved
   * @return {Boolean} {@true it was moved}
   * @deprecated use {@link #insertAbove(item)} instead.
   */
  bool moveAbove(Item item) {
    return this.insertAbove(item);
  }

  /**
   * Moves the item below the specified item.
   *
   * @param {Item} item the item below which it should be moved
   * @return {Boolean} {@true it was moved}
   * @deprecated use {@link #insertBelow(item)} instead.
   */
  bool moveBelow(Item item) {
    return insertBelow(item);
  }

  /**
  * Removes the item from its parent's named children list.
  */
  void _removeFromNamed() {
    var children = _parent._children;
    var namedChildren = _parent._namedChildren;
    String name = this._name;
    var namedArray = namedChildren[name];
    int index = namedArray != null ? namedArray.indexOf(this) : -1;
    if (index == -1)
      return;
    // Remove the named reference
    // TODO we can't do this unless we use MapList
    /*if (children[name] == this)
      delete children[name];*/
    // Remove this entry
    namedArray.removeRange(index, 1);
    // If there are any items left in the named array, set
    // the last of them to be this.parent.children[this.name]
    if (namedArray.length > 0) {
      // TODO we can't do this unless we use MapList
      //children[name] = namedArray[namedArray.length - 1];
    } else {
      // Otherwise delete the empty array
      namedChildren.remove(name);
    }
  }

  /**
  * Removes the item from its parent's children list.
  */
  bool _remove(bool deselect, bool notify) {
    if (_parent != null) {
      if (deselect)
        setSelected(false);
      if (_name != null)
        _removeFromNamed();
      if (_index != null)
        Base.splice(this._parent._children, null, this._index, 1);
      // Notify parent of changed hierarchy
      if (notify)
        _parent._changed(Change.HIERARCHY);
      _parent = null;
      return true;
    }
    return false;
  }

  /**
  * Removes the item from the project. If the item has children, they are also
  * removed.
  *
  * @return {Boolean} {@true the item was removed}
  */
  bool remove() {
    return _remove(true, true);
  }

  /**
   * Removes all of the item's {@link #children} (if any).
   *
   * @name Item#removeChildren
   * @function
   * @return {Item[]} an array containing the removed items
   */
  /**
   * Removes the children from the specified {@code from} index to the
   * {@code to} index from the parent's {@link #children} array.
   *
   * @name Item#removeChildren
   * @function
   * @param {Number} from the beginning index, inclusive
   * @param {Number} [to=children.length] the ending index, exclusive
   * @return {Item[]} an array containing the removed items
   */
  List<Item> removeChildren([int from = 0, int to = null]) {
    if (_children == null)
      return null;
    to = to == null ? _children.length : to;
    // Use Base.splice(), wich adjusts #_index for the items above, and
    // deletes it for the removed items. Calling #_remove() afterwards is
    // fine, since it only calls Base.splice() if #_index is set.
    var removed = Base.splice(this._children, null, from, to - from);
    for (var i = removed.length - 1; i >= 0; i--)
      removed[i]._remove(true, false);
    if (removed.length > 0)
      _changed(Change.HIERARCHY);
    return removed;
  }

  /**
   * Reverses the order of the item's children
   */
  void reverseChildren() {
    if (_children != null) {
      // TODO implement reverse somewhere until dart does
      _children.reverse();
      // Adjust inidces
      for (var i = 0, l = this._children.length; i < l; i++)
        _children[i]._index = i;
      _changed(Change.HIERARCHY);
    }
  }

  // TODO: Item#isEditable is currently ignored in the documentation, as
  // locking an item currently has no effect
  /**
   * {@grouptitle Tests}
   * Checks whether the item is editable.
   *
   * @return {Boolean} {@true when neither the item, nor its parents are
   * locked or hidden}
   * @ignore
   */
  bool isEditable() {
    var item = this;
    while (item != null) {
      if (!item._visible || item._locked)
        return false;
      item = item._parent;
    }
    return true;
  }

  /**
   * Checks whether the item is valid, i.e. it hasn't been removed.
   *
   * @return {Boolean} {@true the item is valid}
   */
  // TODO: isValid / checkValid

  /**
   * Returns -1 if 'this' is above 'item', 1 if below, 0 if their order is not
   * defined in such a way, e.g. if one is a descendant of the other.
   */
  int _getOrder(Item item) {
    // Private method that produces a list of anchestors, starting with the
    // root and ending with the actual element as the last entry.
    var getList = (item) {
      var list = [];
      do {
        list.add(item);
      } while (item = item._parent != null);
      return list;
    };
    var list1 = getList(this);
    var list2 = getList(item);
    for (var i = 0, l = min(list1.length, list2.length); i < l; i++) {
      if (list1[list1.length - i - 1] != list2[list2.length - i - 1]) {
        // Found the position in the parents list where the two start
        // to differ. Look at who's above who.
        return list1[list1.length - i - 1]._index < list2[list2.length - i - 1]._index ? 1 : -1;
      }
    }
    return 0;
  }

  /**
   * {@grouptitle Hierarchy Tests}
   *
   * Checks if the item contains any children items.
   *
   * @return {Boolean} {@true it has one or more children}
   */
  bool hasChildren() {
    return _children != null && _children.length > 0;
  }

  /**
   * Checks if this item is above the specified item in the stacking order
   * of the project.
   *
   * @param {Item} item The item to check against
   * @return {Boolean} {@true if it is above the specified item}
   */
  bool isAbove(Item item) {
    return _getOrder(item) == -1;
  }

  /**
   * Checks if the item is below the specified item in the stacking order of
   * the project.
   *
   * @param {Item} item The item to check against
   * @return {Boolean} {@true if it is below the specified item}
   */
  bool isBelow(Item item) {
    return _getOrder(item) == 1;
  }

  /**
   * Checks whether the specified item is the parent of the item.
   *
   * @param {Item} item The item to check against
   * @return {Boolean} {@true if it is the parent of the item}
   */
  bool isParent(Item item) {
    return _parent == item;
  }

  /**
   * Checks whether the specified item is a child of the item.
   *
   * @param {Item} item The item to check against
   * @return {Boolean} {@true it is a child of the item}
   */
  bool isChild(Item item) {
    return item != null && item._parent == this;
  }

  /**
   * Checks if the item is contained within the specified item.
   *
   * @param {Item} item The item to check against
   * @return {Boolean} {@true if it is inside the specified item}
   */
  bool isDescendant(Item item) {
    var parent = this;
    while (parent = parent._parent != null) {
      if (parent == item)
        return true;
    }
    return false;
  }

  /**
   * Checks if the item is an ancestor of the specified item.
   *
   * @param {Item} item the item to check against
   * @return {Boolean} {@true if the item is an ancestor of the specified
   * item}
   */
  bool isAncestor(Item item) {
    return item != null ? item.isDescendant(this) : false;
  }

  /**
   * Checks whether the item is grouped with the specified item.
   *
   * @param {Item} item
   * @return {Boolean} {@true if the items are grouped together}
   */
  bool isGroupedWith(Item item) {
    var parent = _parent;
    while (parent != null) {
      // Find group parents. Check for parent._parent, since don't want
      // top level layers, because they also inherit from Group
      if (parent._parent != null
        && (parent is Group || parent is CompoundPath)
        && item.isDescendant(parent))
          return true;
      // Keep walking up otherwise
      parent = parent._parent;
    }
    return false;
  }

  // Document all style properties which get injected into Item by Style:
  // TODO implement these properties and pass through to style object

  /**
   * {@grouptitle Stroke Style}
   *
   * The color of the stroke.
   *
   * @name Item#strokeColor
   * @property
   * @type RgbColor|HsbColor|HslColor|GrayColor
   *
   * @example {@paperscript}
   * // Setting the stroke color of a path:
   *
   * // Create a circle shaped path at { x: 80, y: 50 }
   * // with a radius of 35:
   * var circle = new Path.Circle(new Point(80, 50), 35);
   *
   * // Set its stroke color to RGB red:
   * circle.strokeColor = new RgbColor(1, 0, 0);
   */

  /**
   * The width of the stroke.
   *
   * @name Item#strokeWidth
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Setting an item's stroke width:
   *
   * // Create a circle shaped path at { x: 80, y: 50 }
   * // with a radius of 35:
   * var circle = new Path.Circle(new Point(80, 50), 35);
   *
   * // Set its stroke color to black:
   * circle.strokeColor = 'black';
   *
   * // Set its stroke width to 10:
   * circle.strokeWidth = 10;
   */

  /**
   * The shape to be used at the end of open {@link Path} items, when they
   * have a stroke.
   *
   * @name Item#strokeCap
   * @property
   * @default 'butt'
   * @type String('round', 'square', 'butt')
   *
   * @example {@paperscript height=200}
   * // A look at the different stroke caps:
   *
   * var line = new Path(new Point(80, 50), new Point(420, 50));
   * line.strokeColor = 'black';
   * line.strokeWidth = 20;
   *
   * // Select the path, so we can see where the stroke is formed:
   * line.selected = true;
   *
   * // Set the stroke cap of the line to be round:
   * line.strokeCap = 'round';
   *
   * // Copy the path and set its stroke cap to be square:
   * var line2 = line.clone();
   * line2.position.y += 50;
   * line2.strokeCap = 'square';
   *
   * // Make another copy and set its stroke cap to be butt:
   * var line2 = line.clone();
   * line2.position.y += 100;
   * line2.strokeCap = 'butt';
   */

  /**
   * The shape to be used at the corners of paths when they have a stroke.
   *
   * @name Item#strokeJoin
   * @property
   * @default 'miter'
   * @type String ('miter', 'round', 'bevel')
   *
   *
   * @example {@paperscript height=120}
   * // A look at the different stroke joins:
   * var path = new Path();
   * path.add(new Point(80, 100));
   * path.add(new Point(120, 40));
   * path.add(new Point(160, 100));
   * path.strokeColor = 'black';
   * path.strokeWidth = 20;
   *
   * // Select the path, so we can see where the stroke is formed:
   * path.selected = true;
     *
   * var path2 = path.clone();
   * path2.position.x += path2.bounds.width * 1.5;
   * path2.strokeJoin = 'round';
     *
   * var path3 = path2.clone();
   * path3.position.x += path3.bounds.width * 1.5;
   * path3.strokeJoin = 'bevel';
   */

  /**
   * The dash offset of the stroke.
   *
   * @name Item#dashOffset
   * @property
   * @default 0
   * @type Number
   */

  /**
   * Specifies an array containing the dash and gap lengths of the stroke.
   *
   * @example {@paperscript}
   * var path = new Path.Circle(new Point(80, 50), 40);
   * path.strokeWidth = 2;
   * path.strokeColor = 'black';
   *
   * // Set the dashed stroke to [10pt dash, 4pt gap]:
   * path.dashArray = [10, 4];
   *
   * @name Item#dashArray
   * @property
   * @default []
   * @type Array
   */

  /**
   * The miter limit of the stroke.
   * When two line segments meet at a sharp angle and miter joins have been
   * specified for {@link Item#strokeJoin}, it is possible for the miter to
   * extend far beyond the {@link Item#strokeWidth} of the path. The
   * miterLimit imposes a limit on the ratio of the miter length to the
   * {@link Item#strokeWidth}.
   *
   * @default 10
   * @property
   * @name Item#miterLimit
   * @type Number
   */

  /**
   * {@grouptitle Fill Style}
   *
   * The fill color of the item.
   *
   * @name Item#fillColor
   * @property
   * @type RgbColor|HsbColor|HslColor|GrayColor
   *
   * @example {@paperscript}
   * // Setting the fill color of a path to red:
   *
   * // Create a circle shaped path at { x: 80, y: 50 }
   * // with a radius of 35:
   * var circle = new Path.Circle(new Point(80, 50), 35);
   *
   * // Set the fill color of the circle to RGB red:
   * circle.fillColor = new RgbColor(1, 0, 0);
   */

  // DOCS: Document the different arguments that this function can receive.
  // DOCS: Document the apply parameter in all transform functions.
  /**
   * {@grouptitle Transform Functions}
   *
   * Scales the item by the given value from its center point, or optionally
   * from a supplied point.
   *
   * @name Item#scale
   * @function
   * @param {Number} scale the scale factor
   * @param {Point} [center={@link Item#position}]
   * @param {Boolean} apply
   *
   * @example {@paperscript}
   * // Scaling an item from its center point:
   *
   * // Create a circle shaped path at { x: 80, y: 50 }
   * // with a radius of 20:
   * var circle = new Path.Circle(new Point(80, 50), 20);
   * circle.fillColor = 'red';
   *
   * // Scale the path by 150% from its center point
   * circle.scale(1.5);
   *
   * @example {@paperscript}
   * // Scaling an item from a specific point:
   *
   * // Create a circle shaped path at { x: 80, y: 50 }
   * // with a radius of 20:
   * var circle = new Path.Circle(new Point(80, 50), 20);
   * circle.fillColor = 'red';
   *
   * // Scale the path 150% from its bottom left corner
   * circle.scale(1.5, circle.bounds.bottomLeft);
   */
  /**
   * Scales the item by the given values from its center point, or optionally
   * from a supplied point.
   *
   * @name Item#scale
   * @function
   * @param {Number} hor the horizontal scale factor
   * @param {Number} ver the vertical scale factor
   * @param {Point} [center={@link Item#position}]
   * @param {Boolean} apply
   *
   * @example {@paperscript}
   * // Scaling an item horizontally by 300%:
   *
   * // Create a circle shaped path at { x: 100, y: 50 }
   * // with a radius of 20:
   * var circle = new Path.Circle(new Point(100, 50), 20);
   * circle.fillColor = 'red';
     *
   * // Scale the path horizontally by 300%
   * circle.scale(3, 1);
   */
  Item scale(num hor, [ver /* | scale */, center, apply]) {
    // See Matrix#scale for explanation of this:
    if(ver == null || ver is! num) {
      apply = center;
      center = ver;
      ver = hor;
    }
    return transform(new Matrix().scale(hor, ver,
        center == null ? this.getPosition(true) : center), apply);
  }

  /**
   * Translates (moves) the item by the given offset point.
   *
   * @param {Point} delta the offset to translate the item by
   * @param {Boolean} apply
   */
  Item translate(delta, [bool apply = false]) {
    var mx = new Matrix();
    return transform(mx.translate(delta), apply);
  }

  /**
   * Rotates the item by a given angle around the given point.
   *
   * Angles are oriented clockwise and measured in degrees.
   *
   * @param {Number} angle the rotation angle
   * @param {Point} [center={@link Item#position}]
   * @param {Boolean} apply
   * @see Matrix#rotate
   *
   * @example {@paperscript}
   * // Rotating an item:
   *
   * // Create a rectangle shaped path with its top left
   * // point at {x: 80, y: 25} and a size of {width: 50, height: 50}:
   * var path = new Path.Rectangle(new Point(80, 25), new Size(50, 50));
   * path.fillColor = 'black';
     *
   * // Rotate the path by 30 degrees:
   * path.rotate(30);
   *
   * @example {@paperscript height=200}
   * // Rotating an item around a specific point:
   *
   * // Create a rectangle shaped path with its top left
   * // point at {x: 175, y: 50} and a size of {width: 100, height: 100}:
   * var topLeft = new Point(175, 50);
   * var size = new Size(100, 100);
   * var path = new Path.Rectangle(topLeft, size);
   * path.fillColor = 'black';
   *
   * // Draw a circle shaped path in the center of the view,
   * // to show the rotation point:
   * var circle = new Path.Circle(view.center, 5);
   * circle.fillColor = 'white';
   *
   * // Each frame rotate the path 3 degrees around the center point
   * // of the view:
   * function onFrame(event) {
   *   path.rotate(3, view.center);
   * }
   */
  Item rotate(num angle, center, [bool apply = false]) {
    return transform(new Matrix().rotate(angle,
        center == null ? this.getPosition(true) : center), apply);
  }

  // TODO: Add test for item shearing, as it might be behaving oddly.
  /**
   * Shears the item by the given value from its center point, or optionally
   * by a supplied point.
   *
   * @name Item#shear
   * @function
   * @param {Point} point
   * @param {Point} [center={@link Item#position}]
   * @param {Boolean} apply
   * @see Matrix#shear
   */
  /**
   * Shears the item by the given values from its center point, or optionally
   * by a supplied point.
   *
   * @name Item#shear
   * @function
   * @param {Number} hor the horizontal shear factor.
   * @param {Number} ver the vertical shear factor.
   * @param {Point} [center={@link Item#position}]
   * @param {Boolean} apply
   * @see Matrix#shear
   */
  Item shear(num hor, [ver, center, apply]) {
    // PORT: Add support for center and apply back to Scriptographer too!
    // See Matrix#scale for explanation of this:
    if(ver == null || ver is! num) {
      apply = center;
      center = ver;
      ver = hor;
    }
    return transform(new Matrix().shear(hor, ver,
        center == null ? center : getPosition(true)), apply);
  }

  /**
   * Transform the item.
   *
   * @param {Matrix} matrix the matrix by which the item shall be transformed.
   * @param {Boolean} apply controls wether the transformation should just be
   * concatenated to {@link #matrix} ({@code false}) or if it should directly
   * be applied to item's content and its children.
   */
  // Remove this for now:
  // @param {String[]} flags Array of any of the following: 'objects',
  //        'children', 'fill-gradients', 'fill-patterns', 'stroke-patterns',
  //        'lines'. Default: ['objects', 'children']
  Item transform(Matrix matrix, [bool apply = false]) {
    // Calling _changed will clear _bounds and _position, but depending
    // on matrix we can calculate and set them again.
    var bounds = this._bounds;
    var position = this._position;
    // Simply preconcatenate the internal matrix with the passed one:
    _matrix.preConcatenate(matrix);
    // TODO what? is this checking for the existence of method _transform?
    if (this._transform)
      this._transform(matrix);
    if (apply)
      this.apply();
    // We always need to call _changed since we're caching bounds on all
    // items, including Group.
    _changed(Change.GEOMETRY);
    // Detect matrices that contain only translations and scaling
    // and transform the cached _bounds and _position without having to
    // fully recalculate each time.
    if (bounds != null && matrix.getRotation() % 90 === 0) {
      // Transform the old bound by looping through all the cached bounds
      // in _bounds and transform each.
      for (var key in bounds.getKeys()) {
        var rect = bounds[key];
        matrix.transformBounds(rect, rect);
      }
      // If we have cached 'bounds', update _position again as its 
      // center. We need to take into account _boundsType here too, in 
      // case another type is assigned to it, e.g. 'strokeBounds'.
      var type = _boundsType;
      // TODO what?
      var rect = bounds[type != null ? type['bounds'] : 'bounds'];
      if (rect != null)
        _position = rect.getCenter(true);
      _bounds = bounds;
    } else if (position != null) {
      // Transform position as well.
      _position = matrix.transformPoint(position, position);
    }
    // PORT: Return 'this' in all chainable commands
    return this;
  }

  // DOCS: Document #apply()
  void apply() {
    // Call the internal #_apply(), and set the internal _matrix to the
    // identity transformation if it was possible to apply it.
    // Application is not possible on Raster, PointText, PlacedSymbol, since
    // the matrix is storing the actual location / transformation state.
    // Pass on this._matrix to _apply calls, for reasons of faster access
    // and code minification.
    if (_apply(_matrix)) {
      // Set _matrix to the identity
      _matrix.setIdentity();
      // TODO: This needs a _changed notification, but the GEOMETRY
      // actually doesn't change! What to do?
    }
  }

  bool _apply(Matrix matrix) {
    // Pass on the transformation to the children, and apply it there too:
    if (_children != null) {
      for (var i = 0, l = _children.length; i < l; i++) {
        var child = _children[i];
        child.transform(matrix);
        child.apply();
      }
      return true;
    }
  }

  /**
   * Transform the item so that its {@link #bounds} fit within the specified
   * rectangle, without changing its aspect ratio.
   *
   * @param {Rectangle} rectangle
   * @param {Boolean} [fill=false]
   *
   * @example {@paperscript height=100}
   * // Fitting an item to the bounding rectangle of another item's bounding
   * // rectangle:
   *
   * // Create a rectangle shaped path with its top left corner
   * // at {x: 80, y: 25} and a size of {width: 75, height: 50}:
   * var size = new Size(75, 50);
   * var path = new Path.Rectangle(new Point(80, 25), size);
   * path.fillColor = 'black';
   *
   * // Create a circle shaped path with its center at {x: 80, y: 50}
   * // and a radius of 30.
   * var circlePath = new Path.Circle(new Point(80, 50), 30);
   * circlePath.fillColor = 'red';
   *
   * // Fit the circlePath to the bounding rectangle of
   * // the rectangular path:
   * circlePath.fitBounds(path.bounds);
   *
   * @example {@paperscript height=100}
   * // Fitting an item to the bounding rectangle of another item's bounding
   * // rectangle with the fill parameter set to true:
   *
   * // Create a rectangle shaped path with its top left corner
   * // at {x: 80, y: 25} and a size of {width: 75, height: 50}:
   * var size = new Size(75, 50);
   * var path = new Path.Rectangle(new Point(80, 25), size);
   * path.fillColor = 'black';
   *
   * // Create a circle shaped path with its center at {x: 80, y: 50}
   * // and a radius of 30.
   * var circlePath = new Path.Circle(new Point(80, 50), 30);
   * circlePath.fillColor = 'red';
   *
   * // Fit the circlePath to the bounding rectangle of
   * // the rectangular path:
   * circlePath.fitBounds(path.bounds, true);
   *
   * @example {@paperscript height=200}
   * // Fitting an item to the bounding rectangle of the view
   * var path = new Path.Circle(new Point(80, 50), 30);
   * path.fillColor = 'red';
   *
   * // Fit the path to the bounding rectangle of the view:
   * path.fitBounds(view.bounds);
   */
  void fitBounds(/*Rectangle*/ rectangle, [bool fill = false]) {
    // TODO: Think about passing options with various ways of defining
    // fitting.
    rectangle = Rectangle.read(rectangle);
    Rectangle bounds = getBounds();
    num itemRatio = bounds.height / bounds.width;
    num rectRatio = rectangle.height / rectangle.width;
    num scale = (fill ? itemRatio > rectRatio : itemRatio < rectRatio)
          ? rectangle.width / bounds.width
          : rectangle.height / bounds.height;
    Rectangle newBounds = new Rectangle(new Point(),
          new Size.create(bounds.width * scale, bounds.height * scale));
    newBounds.setCenter(rectangle.getCenter());
    setBounds(newBounds);
  }

  String toString() {
    // TODO original used this.constructor._name if it was set instead of Item
    String descriptor = _name != null ? " '$_name'" : " @$_id";
    return "Item $descriptor";
  }

  /**
   * {@grouptitle Event Handlers}
   * Item level handler function to be called on each frame of an animation.
   * The function receives an event object which contains information about
   * the frame event:
   *
   * <b>{@code event.count}</b>: the number of times the frame event was
   * fired.
   * <b>{@code event.time}</b>: the total amount of time passed since the
   * first frame event in seconds.
   * <b>{@code event.delta}</b>: the time passed in seconds since the last
   * frame event.
   *
    * @see View#onFrame
   * @example {@paperscript}
   * // Creating an animation:
   *
   * // Create a rectangle shaped path with its top left point at:
   * // {x: 50, y: 25} and a size of {width: 50, height: 50}
   * var path = new Path.Rectangle(new Point(50, 25), new Size(50, 50));
   * path.fillColor = 'black';
   *
   * path.onFrame = function(event) {
   *   // Every frame, rotate the path by 3 degrees:
   *   this.rotate(3);
   * }
   *
   * @name Item#onFrame
   * @property
   * @type Function
   */

  /**
   * The function to be called when the mouse button is pushed down on the
   * item. The function receives a {@link MouseEvent} object which contains
   * information about the mouse event.
   *
   * @name Item#onMouseDown
   * @property
   * @type Function
   *
   * @example {@paperscript}
   * // Press the mouse button down on the circle shaped path, to make it red:
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse is pressed on the item,
   * // set its fill color to red:
   * path.onMouseDown = function(event) {
   *   this.fillColor = 'red';
   * }
   * 
   * @example {@paperscript}
   * // Press the mouse on the circle shaped paths to remove them:
   * 
   * // Loop 30 times:
   * for (var i = 0; i < 30; i++) {
   *   // Create a circle shaped path at a random position
   *   // in the view:
   *   var position = Point.random() * view.size;
   *   var path = new Path.Circle(position, 25);
   *   path.fillColor = 'black';
   *   path.strokeColor = 'white';
   *   // When the mouse is pressed on the item, remove it:
   *   path.onMouseDown = function(event) {
   *     this.remove();
   *   }
   * }
   */

  /**
   * The function to be called when the mouse button is released over the item.
   * The function receives a {@link MouseEvent} object which contains
   * information about the mouse event.
   *
   * @name Item#onMouseUp
   * @property
   * @type Function
   *
   * @example {@paperscript}
   * // Release the mouse button over the circle shaped path, to make it red:
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse is released over the item,
   * // set its fill color to red:
   * path.onMouseUp = function(event) {
   *   this.fillColor = 'red';
   * }
   */

  /**
   * The function to be called when the mouse clicks on the item. The function
   * receives a {@link MouseEvent} object which contains information about the
   * mouse event.
   *
   * @name Item#onClick
   * @property
   * @type Function
   *
   * @example {@paperscript}
   * // Click on the circle shaped path, to make it red:
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse is clicked on the item,
   * // set its fill color to red:
   * path.onClick = function(event) {
   *   this.fillColor = 'red';
   * }
   * 
   * @example {@paperscript}
   * // Click on the circle shaped paths to remove them:
   * 
   * // Loop 30 times:
   * for (var i = 0; i < 30; i++) {
   *   // Create a circle shaped path at a random position
   *   // in the view:
   *   var position = Point.random() * view.size;
   *   var path = new Path.Circle(position, 25);
   *   path.fillColor = 'black';
   *   path.strokeColor = 'white';
   *   // When the mouse is clicked on the item, remove it:
   *   path.onClick = function(event) {
   *     this.remove();
   *   }
   * }
   */

  /**
   * The function to be called when the mouse double clicks on the item. The
   * function receives a {@link MouseEvent} object which contains information
   * about the mouse event.
   *
   * @name Item#onDoubleClick
   * @property
   * @type Function
   *
   * @example {@paperscript}
   * // Double click on the circle shaped path, to make it red:
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse is double clicked on the item,
   * // set its fill color to red:
   * path.onDoubleClick = function(event) {
   *   this.fillColor = 'red';
   * }
   * 
   * @example {@paperscript}
   * // Double click on the circle shaped paths to remove them:
   * 
   * // Loop 30 times:
   * for (var i = 0; i < 30; i++) {
   *   // Create a circle shaped path at a random position
   *   // in the view:
   *   var position = Point.random() * view.size;
   *   var path = new Path.Circle(position, 25);
   *   path.fillColor = 'black';
   *   path.strokeColor = 'white';
   *   // When the mouse is clicked on the item, remove it:
   *   path.onDoubleClick = function(event) {
   *     this.remove();
   *   }
   * }
   */

  /**
   * The function to be called repeatedly when the mouse moves on top of the
   * item. The function receives a {@link MouseEvent} object which contains
   * information about the mouse event.
   *
   * @name Item#onMouseMove
   * @property
   * @type Function
   *
   * @example {@paperscript}
   * // Move over the circle shaped path, to change its opacity:
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse moves on top of the item, set its opacity
   * // to a random value between 0 and 1:
   * path.onMouseMove = function(event) {
   *   this.opacity = Math.random();
   * }
   */

  /**
   * The function to be called when the mouse moves over the item. This
   * function will only be called again, once the mouse moved outside of the
   * item first. The function receives a {@link MouseEvent} object which
   * contains information about the mouse event.
   *
   * @name Item#onMouseEnter
   * @property
   * @type Function
   *
   * @example {@paperscript}
   * // When you move the mouse over the item, its fill color is set to red.
   * // When you move the mouse outside again, its fill color is set back
   * // to black.
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse enters the item, set its fill color to red:
   * path.onMouseEnter = function(event) {
   *   this.fillColor = 'red';
   * }
   *
   * // When the mouse leaves the item, set its fill color to black:
   * path.onMouseLeave = function(event) {
   *   this.fillColor = 'black';
   * }
   * @example {@paperscript}
   * // When you click the mouse, you create new circle shaped items. When you
   * // move the mouse over the item, its fill color is set to red. When you
   * // move the mouse outside again, its fill color is set back
   * // to black.
   * 
   * function enter(event) {
   *   this.fillColor = 'red';
   * }
   * 
   * function leave(event) {
   *   this.fillColor = 'black';
   * }
   * 
   * // When the mouse is pressed:
   * function onMouseDown(event) {
   *   // Create a circle shaped path at the position of the mouse:
   *   var path = new Path.Circle(event.point, 25);
   *   path.fillColor = 'black';
     * 
   *   // When the mouse enters the item, set its fill color to red:
   *   path.onMouseEnter = enter;
     * 
   *   // When the mouse leaves the item, set its fill color to black:
   *   path.onMouseLeave = leave;
   * }
   */

  /**
   * The function to be called when the mouse moves out of the item.
   * The function receives a {@link MouseEvent} object which contains
   * information about the mouse event.
   *
   * @name Item#onMouseLeave
   * @property
   * @type Function
   *
   * @example {@paperscript}
   * // Move the mouse over the circle shaped path and then move it out
   * // of it again to set its fill color to red:
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse leaves the item, set its fill color to red:
   * path.onMouseLeave = function(event) {
   *   this.fillColor = 'red';
   * }
   */

  /**
   * {@grouptitle Event Handling}
   * 
   * Attach an event handler to the item.
   *
   * @name Item#attach
   * @function
   * @param {String('mousedown', 'mouseup', 'mousedrag', 'click',
   * 'doubleclick', 'mousemove', 'mouseenter', 'mouseleave')} type the event
   * type
   * @param {Function} function The function to be called when the event
   * occurs
   *
   * @example {@paperscript}
   * // Change the fill color of the path to red when the mouse enters its
   * // shape and back to black again, when it leaves its shape.
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse enters the item, set its fill color to red:
   * path.attach('mouseenter', function() {
   *   this.fillColor = 'red';
   * });
   * 
   * // When the mouse leaves the item, set its fill color to black:
   * path.attach('mouseleave', function() {
   *   this.fillColor = 'black';
   * });
   */
  /**
   * Attach one or more event handlers to the item.
   *
   * @name Item#attach^2
   * @function
   * @param {Object} param An object literal containing one or more of the
   * following properties: {@code mousedown, mouseup, mousedrag, click,
   * doubleclick, mousemove, mouseenter, mouseleave}.
   *
   * @example {@paperscript}
   * // Change the fill color of the path to red when the mouse enters its
   * // shape and back to black again, when it leaves its shape.
   * 
   * // Create a circle shaped path at the center of the view:
   * var path = new Path.Circle(view.center, 25);
   * path.fillColor = 'black';
   * 
   * // When the mouse enters the item, set its fill color to red:
   * path.attach({
   *   mouseenter: function(event) {
   *     this.fillColor = 'red';
   *   },
   *   mouseleave: function(event) {
   *     this.fillColor = 'black';
   *   }
   * });
   * @example {@paperscript}
   * // When you click the mouse, you create new circle shaped items. When you
   * // move the mouse over the item, its fill color is set to red. When you
   * // move the mouse outside again, its fill color is set black.
   * 
   * var pathHandlers = {
   *   mouseenter: function(event) {
   *     this.fillColor = 'red';
   *   },
   *   mouseleave: function(event) {
   *     this.fillColor = 'black';
   *   }
   * }
   * 
   * // When the mouse is pressed:
   * function onMouseDown(event) {
   *   // Create a circle shaped path at the position of the mouse:
   *   var path = new Path.Circle(event.point, 25);
   *   path.fillColor = 'black';
     * 
   *   // Attach the handers inside the object literal to the path:
   *   path.attach(pathHandlers);
   * }
   */

  /**
   * Detach an event handler from the item.
   *
   * @name Item#detach
   * @function
   * @param {String('mousedown', 'mouseup', 'mousedrag', 'click',
   * 'doubleclick', 'mousemove', 'mouseenter', 'mouseleave')} type the event
   * type
   * @param {Function} function The function to be detached
   */
  /**
   * Detach one or more event handlers to the item.
   *
   * @name Item#detach^2
   * @function
   * @param {Object} param An object literal containing one or more of the
   * following properties: {@code mousedown, mouseup, mousedrag, click,
   * doubleclick, mousemove, mouseenter, mouseleave}
   */

  /**
   * Fire an event on the item.
   *
   * @name Item#fire
   * @function
   * @param {String('mousedown', 'mouseup', 'mousedrag', 'click',
   * 'doubleclick', 'mousemove', 'mouseenter', 'mouseleave')} type the event
   * type
   * @param {Object} event An object literal containing properties describing
   * the event.
   */

  /**
   * Check if the item has one or more event handlers of the specified type.
   *
   * @name Item#responds
   * @function
   * @param {String('mousedown', 'mouseup', 'mousedrag', 'click',
   * 'doubleclick', 'mousemove', 'mouseenter', 'mouseleave')} type the event
   * type
   * @return {Boolean} {@true if the item has one or more event handlers of
   * the specified type}
   */

  /**
   * Private method that sets Path related styles on the canvas context.
   * Not defined in Path as it is required by other classes too,
   * e.g. PointText.
   */
  // public version
  // TODO put in a class between Item and Path / other subclasses that use it?
  void setStyles(ctx) {
    _setStyles(ctx);
  }
  void _setStyles(ctx) {
    // We can access internal properties since we're only using this on
    // items without children, where styles would be merged.
    var style = _style,
      width = style._strokeWidth,
      join = style._strokeJoin,
      cap = style._strokeCap,
      limit = style._miterLimit,
      fillColor = style._fillColor,
      strokeColor = style._strokeColor;
    if (width != null) ctx.lineWidth = width;
    if (join != null) ctx.lineJoin = join;
    if (cap != null) ctx.lineCap = cap;
    if (limit != null) ctx.miterLimit = limit;
    if (fillColor != null) ctx.fillStyle = fillColor.getCanvasStyle(ctx);
    if (strokeColor != null) ctx.strokeStyle = strokeColor.getCanvasStyle(ctx);
    // If the item only defines a strokeColor or a fillColor, draw it
    // directly with the globalAlpha set, otherwise we will do it later when
    // we composite the temporary canvas.
    if (fillColor == null || strokeColor == null)
      ctx.globalAlpha = _opacity;
  }

  //statics: {
  static void drawSelectedBounds(bounds, ctx, matrix) {
    List coords = matrix._transformCorners(bounds);
    ctx.beginPath();
    for (var i = 0; i < 8; i++)
      ctx[i == 0 ? 'moveTo' : 'lineTo'](coords[i], coords[++i]);
    ctx.closePath();
    ctx.stroke();
    for (var i = 0; i < 8; i++) {
      ctx.beginPath();
      ctx.rect(coords[i] - 2, coords[++i] - 2, 4, 4);
      ctx.fill();
    }
  }

  // TODO: Implement View into the drawing.
  // TODO: Optimize temporary canvas drawing to ignore parts that are
  // outside of the visible view.
  static draw(item, ctx, param) {
    if (!item._visible || item._opacity == 0)
      return;
    var tempCanvas, parentCtx,
       itemOffset, prevOffset;
    // If the item has a blendMode or is defining an opacity, draw it on
    // a temporary canvas first and composite the canvas afterwards.
    // Paths with an opacity < 1 that both define a fillColor
    // and strokeColor also need to be drawn on a temporary canvas
    // first, since otherwise their stroke is drawn half transparent
    // over their fill.
    if (item._blendMode !== 'normal' || item._opacity < 1
        && !(item._segments != null
          && (item.getFillColor() == null || item.getStrokeColor() == null))) {
      var bounds = item.getStrokeBounds();
      if (bounds.width == 0 || bounds.height == 0)
        return;
      // Store previous offset and save the parent context, so we can
      // draw onto it later
      prevOffset = param.offset;
      parentCtx = ctx;
      // Floor the offset and ceil the size, so we don't cut off any
      // antialiased pixels when drawing onto the temporary canvas.
      itemOffset = param.offset = bounds.getTopLeft().floor();
      tempCanvas = CanvasProvider.getCanvas(
          bounds.getSize().ceil().add(new Size.create(1, 1)));
      // Set ctx to the context of the temporary canvas,
      // so we draw onto it, instead of the parentCtx
      ctx = tempCanvas.getContext('2d');
    }
    if (!param.clipping)
      ctx.save();
    // Translate the context so the topLeft of the item is at (0, 0)
    // on the temporary canvas.
    if (tempCanvas != null)
      ctx.translate(-itemOffset.x, -itemOffset.y);
    item._matrix.applyToContext(ctx);
    item.draw(ctx, param);
    if (!param.clipping)
      ctx.restore();
    // If we created a temporary canvas before, composite it onto the
    // parent canvas:
    if (tempCanvas) {
      // Restore previous offset.
      param.offset = prevOffset;
      // If the item has a blendMode, use BlendMode#process to
      // composite its canvas on the parentCanvas.
      if (item._blendMode !== 'normal') {
        // The pixel offset of the temporary canvas to the parent
        // canvas.
        BlendMode.process(item._blendMode, ctx, parentCtx,
          item._opacity, itemOffset.subtract(prevOffset));
      } else {
      // Otherwise we just need to set the globalAlpha before drawing
      // the temporary canvas on the parent canvas.
        parentCtx.save();
        parentCtx.globalAlpha = item._opacity;
        parentCtx.drawImage(tempCanvas, itemOffset.x, itemOffset.y);
        parentCtx.restore();
      }
      // Return the temporary canvas, so it can be reused
      CanvasProvider.returnCanvas(tempCanvas);
    }
  }

  Item removeOnDown() {
    return removeOn({"down": true});
  }
  Item removeOnDrag() {
    return removeOn({"drag": true});
  }
  Item removeOnUp() {
    return removeOn({"up": true});
  }
  Item removeOnMove() {
    return removeOn({"move": true});
  }
  /**
   * {@grouptitle Remove On Event}
   *
   * Removes the item when the events specified in the passed object literal
   * occur.
   * The object literal can contain the following values:
   * Remove the item when the next {@link Tool#onMouseMove} event is
   * fired: {@code object.move = true}
   *
   * Remove the item when the next {@link Tool#onMouseDrag} event is
   * fired: {@code object.drag = true}
   *
   * Remove the item when the next {@link Tool#onMouseDown} event is
   * fired: {@code object.down = true}
   *
   * Remove the item when the next {@link Tool#onMouseUp} event is
   * fired: {@code object.up = true}
   *
   * @name Item#removeOn
   * @function
   * @param {Object} object
   *
   * @example {@paperscript height=200}
   * // Click and drag below:
   * function onMouseDrag(event) {
   *   // Create a circle shaped path at the mouse position,
   *   // with a radius of 10:
   *   var path = new Path.Circle(event.point, 10);
   *   path.fillColor = 'black';
   *
   *   // Remove the path on the next onMouseDrag or onMouseDown event:
   *   path.removeOn({
   *     drag: true,
   *     down: true
   *   });
   * }
   */

  /**
   * Removes the item when the next {@link Tool#onMouseMove} event is fired.
   *
   * @name Item#removeOnMove
   * @function
   *
   * @example {@paperscript height=200}
   * // Move your mouse below:
   * function onMouseMove(event) {
   *   // Create a circle shaped path at the mouse position,
   *   // with a radius of 10:
   *   var path = new Path.Circle(event.point, 10);
   *   path.fillColor = 'black';
   *
   *   // On the next move event, automatically remove the path:
   *   path.removeOnMove();
   * }
   */

  /**
   * Removes the item when the next {@link Tool#onMouseDown} event is fired.
   *
   * @name Item#removeOnDown
   * @function
   *
   * @example {@paperscript height=200}
   * // Click a few times below:
   * function onMouseDown(event) {
   *   // Create a circle shaped path at the mouse position,
   *   // with a radius of 10:
   *   var path = new Path.Circle(event.point, 10);
   *   path.fillColor = 'black';
   *
   *   // Remove the path, next time the mouse is pressed:
   *   path.removeOnDown();
   * }
   */

  /**
   * Removes the item when the next {@link Tool#onMouseDrag} event is fired.
   *
   * @name Item#removeOnDrag
   * @function
   *
   * @example {@paperscript height=200}
   * // Click and drag below:
   * function onMouseDrag(event) {
   *   // Create a circle shaped path at the mouse position,
   *   // with a radius of 10:
   *   var path = new Path.Circle(event.point, 10);
   *   path.fillColor = 'black';
   *
   *   // On the next drag event, automatically remove the path:
   *   path.removeOnDrag();
   * }
   */

  /**
   * Removes the item when the next {@link Tool#onMouseUp} event is fired.
   *
   * @name Item#removeOnUp
   * @function
   *
   * @example {@paperscript height=200}
   * // Click a few times below:
   * function onMouseDown(event) {
   *   // Create a circle shaped path at the mouse position,
   *   // with a radius of 10:
   *   var path = new Path.Circle(event.point, 10);
   *   path.fillColor = 'black';
   *
   *   // Remove the path, when the mouse is released:
   *   path.removeOnUp();
   * }
   */
  // TODO: implement Item#removeOnFrame
  Item removeOn(obj) {
    for (var name in obj) {
      if (obj[name]) {
        var key = 'mouse$name',
          sets = Tool._removeSets = Tool._removeSets != null ? Tool._removeSets : {};
        sets[key] = sets.containsKey(key) ? sets[key] : {};
        sets[key][_id] = this;
      }
    }
    return this;
  }

  // TODO style accessor stuff
}
