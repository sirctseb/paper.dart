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
library View;
import "dart:html" hide Point;
import "../core/Core.dart";
import "../project/Project.dart";
import "../basic/Basic.dart";

/**
 * @name View
 *
 * @class The View object wraps an html element and handles drawing and user
 * interaction through mouse and keyboard for it. It offer means to scroll the
 * view, find the currently visible bounds in project coordinates, or the
 * center, both useful for constructing artwork that should appear centered on
 * screen.
 */
class View extends Callback {
  
  var _onFrameCallback;
  get onFrame => getEvent("frame");
  set onFrame(value) => setEvent("frame", value);
  get onResize => getEvent("resize");
  set onResize(value) => setEvent("resize", value);
  
  void _installFrameHandler() {
    if (options.browser) {
    var that = this,
      requested = false,
      before,
      time = 0,
      count = 0;
    this._onFrameCallback = function(param, dontRequest) {
      requested = false;
      // See if we need to stop due to a call to uninstall()
      if (!that._onFrameCallback)
        return;
      // Set the global paper object to the current scope
      paper = that._scope;
      if (!dontRequest) {
        // Request next frame already
        requested = true;
        window.requestAnimationFrame(_onFrameCallback);
        // TODO js took an element, but I don't think rAF takes one
        /*DomEvent.requestAnimationFrame(that._onFrameCallback,
            that._element);*/
      }
      var now = new Date.now().millisecondsSinceEpoch / 1000,
         delta = before ? now - before : 0;
      // delta: Time elapsed since last redraw in seconds
      // time: Time since first call of frame() in seconds
      // Use Base.merge to convert into a Base object,
      // for #toString()
      that.fire('frame', Base.merge({
        "delta": delta,
        "time": time += delta,
        "count": count++
      }));
      before = now;
      // Update framerate stats
      if (that._stats)
        that._stats.update();
      // Automatically draw view on each frame.
      that.draw(true);
    };
    // Call the onFrame handler straight away, initializing the
    // sequence of onFrame calls.
    if (!requested)
      this._onFrameCallback();
    } // options.browser
  }
  
  void _uninstallFrameHandler() {
    _onFrameCallback = null;
  }
  
  // TODO should be the one in Callback
  Map _eventTypes;
  
  PaperScope _scope;
  Project _project;
  Element _element;
  String _id;

  View(Element element) {

    _eventTypes["onFrame"] = {"install": _installFrameHandler,
                              "uninstall": _uninstallFrameHandler};
    _eventTypes["onResize"] = {};
    
    // Store reference to the currently active global paper scope, and the
    // active project, which will be represented by this view
    _scope = paper;
    _project = paper.project;
    _element = element;
    
    // Install event handlers
    element.on.mouseDown.add(_mousedown, false);
    element.on.touchStart.add(_mousedown, false);
    element.on.selectStart.add(_selectstart, false);
    
    var size;
/*#*/ if (options.browser) {
    // Generate an id for this view / element if it does not have one
    // TODO separate static and member _id
    _id = element.attributes['id'];
    if (_id == null)
      element.attributes['id'] = _id = 'view-${View._lastId++}';

    // If the element has the resize attribute, resize the it to fill the
    // window and resize it again whenever the user resizes the window.
    if (PaperScript.hasAttribute(element, 'resize')) {
      // Subtract element' viewport offset from the total size, to
      // stretch it in
      var offset = DomElement.getOffset(element, true),
        that = this;
      size = DomElement.getViewportBounds(element)
          .getSize().subtract(offset);
      element.width = size.width;
      element.height = size.height;
      DomEvent.add(window, {
        "resize": function(event) {
          // Only update element offset if it's not invisible, as
          // otherwise the offset would be wrong.
          if (!DomElement.isInvisible(element))
            offset = DomElement.getOffset(element, true);
          // Set the size now, which internally calls onResize
          // and redraws the view
          that.setViewSize(DomElement.getViewportBounds(element)
              .getSize().subtract(offset));
        }
      });
    } else {
      // If the element is invisible, we cannot directly access
      // element.width / height, because they would appear 0. Reading
      // the attributes still works though:
      size = DomElement.isInvisible(element)
        ? Size.create(parseInt(element.getAttribute('width')),
            parseInt(element.getAttribute('height')))
        : DomElement.getSize(element);
    }
    // TODO: Test this on IE:
    if (PaperScript.hasAttribute(element, 'stats')) {
      _stats = new Stats();
      // Align top-left to the element
      var stats = _stats.domElement,
        style = stats.style,
        offset = DomElement.getOffset(element);
      style.position = 'absolute';
      style.left = offset.x + 'px';
      style.top = offset.y + 'px';
      document.body.appendChild(stats);
    }
/*#*/ } else if (options.server) {
    // Generate an id for this view
    _id = 'view-${View._lastId++}';
    size = Size.create(element.width, element.height);
/*#*/ } // options.server
    // Keep track of views internally
    View._views.push(this);
    // Link this id to our view
    View._viewsById[_id] = this;
    _viewSize = LinkedSize.create(this, 'setViewSize',
        size.width, size.height);
    _matrix = new Matrix();
    _zoom = 1;
    // Make sure the first view is focused for keyboard input straight away
    if (!View._focused)
      View._focused = this;
  }

  /**
   * Removes this view from and frees the associated element.
   */
  bool remove() {
    if (!_project)
      return false;
    // Clear focus if removed view had it
    if (View._focused == this)
      View._focused = null;
    // Remove view from internal structures
    View._views.splice(View._views.indexOf(this), 1);
    _viewsById.remove(_id);
    // Unlink from project
    if (_project.view == this)
      _project.view = null;
    // Uninstall event handlers again for this view.
    DomEvent.remove(_element, _handlers);
    _element = _project = null;
    // Removing all onFrame handlers makes the _onFrameCallback handler stop
    // automatically through its uninstall method.
    detach('frame');
    return true;
  }

  void _redraw() {
    _redrawNeeded = true;
    if (_onFrameCallback) {
      // If there's a _onFrameCallback, call it staight away,
      // but without requesting another animation frame.
      _onFrameCallback(0, true);
    } else {
      // Otherwise simply redraw the view now
      draw();
    }
  }

  void _transform(matrix) {
    _matrix.preConcatenate(matrix);
    // Force recalculation of these values next time they are requested.
    _bounds = null;
    _inverse = null;
    _redraw();
  }

  /**
   * The underlying native element.
   *
   * @type HTMLCanvasElement
   * @bean
   */
  Element getElement() {
    return _element;
  }
  Element get element => getElement();

  /**
   * The size of the view. Changing the view's size will resize it's
   * underlying element.
   *
   * @type Size
   * @bean
   */
  Size _viewSize;
  Size getViewSize() {
    return _viewSize;
  }
  Size get viewSize => getViewSize();

  void setViewSize(size) {
    size = Size.read(arguments);
    var delta = size.subtract(_viewSize);
    if (delta.isZero())
      return;
    _element.width = size.width;
    _element.height = size.height;
    // Update _viewSize but don't notify of change.
    _viewSize.set(size.width, size.height, true);
    // Force recalculation
    _bounds = null;
    _redrawNeeded = true;
    // Call onResize handler on any size change
    fire('resize', {
      size: size,
      delta: delta
    });
    _redraw();
  }
  set viewSize(size) => setViewSize(size);

  /**
   * The bounds of the currently visible area in project coordinates.
   *
   * @type Rectangle
   * @bean
   */
  Rectangle _bounds;
  Rectangle getBounds() {
    if (!_bounds)
      _bounds = _getInverse()._transformBounds(
          new Rectangle(new Point(), _viewSize));
    return _bounds;
  }
  Rectangle get bounds => getBounds();

  /**
   * The size of the visible area in project coordinates.
   *
   * @type Size
   * @bean
   */
  Size getSize() {
    return getBounds().getSize();
  }
  Size get size => getSize();

  /**
   * The center of the visible area in project coordinates.
   *
   * @type Point
   * @bean
   */
  Point getCenter() {
    return getBounds().getCenter();
  }
  Point get center => getCenter();

  void setCenter(center) {
    scrollBy(Point.read(arguments).subtract(getCenter()));
  }
  set center(center) => setCenter(center);

  /**
   * The zoom factor by which the project coordinates are magnified.
   *
   * @type Number
   * @bean
   */
  num _zoom;
  num getZoom() {
    return _zoom;
  }
  num get zoom => getZoom();

  void setZoom(num zoom) {
    // TODO: Clamp the view between 1/32 and 64, just like Illustrator?
    _transform(new Matrix().scale(zoom / _zoom,
      getCenter()));
    _zoom = zoom;
  }
  set zoom(zoom) => setZoom(zoom);

  /**
   * Checks whether the view is currently visible within the current browser
   * viewport.
   *
   * @return {Boolean} Whether the view is visible.
   */
  bool isVisible() {
    return DomElement.isVisible(_element);
  }

  /**
   * Scrolls the view by the given vector.
   *
   * @param {Point} point
   */
  Point scrollBy(point) {
    _transform(new Matrix().translate(Point.read(arguments).negate()));
  }

  /**
   * Draws the view.
   *
   * @name View#draw
   * @function
   */
  /*
  draw: function(checkRedraw) {
  },
  */

  // TODO: getInvalidBounds
  // TODO: invalidate(rect)
  // TODO: style: artwork / preview / raster / opaque / ink
  // TODO: getShowGrid
  // TODO: getMousePoint
  // TODO: projectToView(rect)

  Point projectToView(point) {
    return _matrix._transformPoint(Point.read(arguments));
  }

  Point viewToProject(point) {
    return _getInverse()._transformPoint(Point.read(arguments));
  }

  Matrix _getInverse() {
    if (!_inverse)
      _inverse = _matrix.createInverse();
    return _inverse;
  }

  /**
   * {@grouptitle Event Handlers}
   * Handler function to be called on each frame of an animation.
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
   * @example {@paperscript}
   * // Creating an animation:
   *
   * // Create a rectangle shaped path with its top left point at:
   * // {x: 50, y: 25} and a size of {width: 50, height: 50}
   * var path = new Path.Rectangle(new Point(50, 25), new Size(50, 50));
   * path.fillColor = 'black';
   *
   * function onFrame(event) {
   *   // Every frame, rotate the path by 3 degrees:
   *   path.rotate(3);
   * }
   *
   * @name View#onFrame
   * @property
   * @type Function
   */

  /**
   * Handler function that is called whenever a view is resized.
   *
   * @example
   * // Repositioning items when a view is resized:
   *
   * // Create a circle shaped path in the center of the view:
   * var path = new Path.Circle(view.bounds.center, 30);
   * path.fillColor = 'red';
   *
   * function onResize(event) {
   *   // Whenever the view is resized, move the path to its center:
   *   path.position = view.center;
   * }
   *
   * @name View#onResize
   * @property
   * @type Function
   */
  /**
   * {@grouptitle Event Handling}
   * 
   * Attach an event handler to the view.
   *
   * @name View#attach
   * @function
   * @param {String('frame', 'resize')} type the event type
   * @param {Function} function The function to be called when the event
   * occurs
   */
  /**
   * Attach one or more event handlers to the view.
   *
   * @name View#attach^2
   * @function
   * @param {Object} param An object literal containing one or more of the
   * following properties: {@code frame, resize}.
   */

  /**
   * Detach an event handler from the view.
   *
   * @name View#detach
   * @function
   * @param {String('frame', 'resize')} type the event type
   * @param {Function} function The function to be detached
   */
  /**
   * Detach one or more event handlers from the view.
   *
   * @name View#detach^2
   * @function
   * @param {Object} param An object literal containing one or more of the
   * following properties: {@code frame, resize}
   */

  /**
   * Fire an event on the view.
   *
   * @name View#fire
   * @function
   * @param {String('frame', 'resize')} type the event type
   * @param {Object} event An object literal containing properties describing
   * the event.
   */

  /**
   * Check if the view has one or more event handlers of the specified type.
   *
   * @name View#responds
   * @function
   * @param {String('frame', 'resize')} type the event type
   * @return {Boolean} {@true if the view has one or more event handlers of
   * the specified type}
   */
  static List _views = [];
  static Map _viewsById = {};
  static int _lastId = 0;

  static create(Element element) {
/*#*/ if (options.browser) {
      if (typeof element === 'string')
        element = document.getElementById(element);
/*#*/ } // options.browser
      // Factory to provide the right View subclass for a given element.
      // Produces only Canvas-Views for now:
      return new CanvasView(element);
  }

  // Injection scope for mouse events on the browser
/*#*/// if (options.browser) {
  Tool tool;
  Point curPoint;
  var tempFocus;
  static bool dragging = false;

  var getView = (Event event) {
    // Get the view from the current event target.
    return View._viewsById[((event.target != null ? event.target : event.srcElement) as Element).attributes['id']];
  };

  var viewToProject = (view, event) {
    return view.viewToProject(DomEvent.getOffset(event, view._element));
  };

  static void _updateFocus(event) {
    if (!View._focused || !View._focused.isVisible()) {
      // Find the first visible view
      for (var i = 0, l = View._views.length; i < l; i++) {
        var view = View._views[i];
        if (view && view.isVisible()) {
          View._focused = tempFocus = view;
          break;
        }
      }
    }
  }

  // TODO these used to store in _handlers, which might interact with Callback
  void _mousedown(event) {
    // Get the view from the event, and store a reference to the view that
    // should receive keyboard input.
    var view = View._focused = getView(event);
    curPoint = viewToProject(view, event);
    dragging = true;
    // Always first call the view's mouse handlers, as required by
    // CanvasView, and then handle the active tool, if any.
    if (view._onMouseDown)
      view._onMouseDown(event, curPoint);
    if (tool = view._scope.tool)
      tool._onHandleEvent('mousedown', curPoint, event);
    // In the end we always call draw(), but pass checkRedraw = true, so we
    // only redraw the view if anything has changed in the above calls.
    view.draw(true);
  }

  static void _mousemove(event) {
    var view;
    if (!dragging) {
      // See if we can get the view from the current event target, and
      // handle the mouse move over it.
      view = getView(event);
      if (view) {
        // Temporarily focus this view without making it sticky, so
        // Key events are handled too during the mouse over
        View._focused = tempFocus = view;
      } else if (tempFocus && tempFocus == View._focused) {
        // Clear temporary focus again and update it.
        View._focused = null;
        updateFocus();
      }
    }
    if (!(view = view || View._focused))
      return;
    var point = event && viewToProject(view, event);
    if (view._onMouseMove)
      view._onMouseMove(event, point);
    if (tool = view._scope.tool) {
      var onlyMove = !!(!tool.onMouseDrag && tool.onMouseMove);
      if (dragging && !onlyMove) {
        if ((curPoint = point || curPoint) 
            && tool._onHandleEvent('mousedrag', curPoint, event))
          DomEvent.stop(event);
      // PORT: If there is only an onMouseMove handler, also call it when
      // the user is dragging:
      } else if ((!dragging || onlyMove)
          && tool._onHandleEvent('mousemove', point, event)) {
        DomEvent.stop(event);
      }
    }
    view.draw(true);
  }

  static void _mouseup(event) {
    var view = View._focused;
    if (!view || !dragging)
      return;
    var point = viewToProject(view, event);
    curPoint = null;
    dragging = false;
    if (view._onMouseUp)
      view._onMouseUp(event, point);
    // Cancel DOM-event if it was handled by our tool
    if (tool && tool._onHandleEvent('mouseup', point, event))
      DomEvent.stop(event);
    view.draw(true);
  }

  static void _selectstart(event) {
    // Only stop this even if we're dragging already, since otherwise no
    // text whatsoever can be selected on the page.
    if (dragging)
      DomEvent.stop(event);
  }

  // mousemove and mouseup events need to be installed on document, not the
  // view element, since we want to catch the end of drag events even outside
  // our view. Only the mousedown events are installed on the view, as handled
  // by _createHandlers below.
  
  static bool _addStaticHandlers() {
    document.on.mouseMove.add(_mousemove, false);
    document.on.mouseUp.add(_mouseup, false);
    document.on.touchMove.add(_mousemove, false);
    document.on.touchEnd.add(_mouseup, false);
    document.on.selectStart.add(_selectstart, false);
    document.on.scroll.add(_updateFocus, false);
    window.on.load.add(_updateFocus, false);
  }
  static bool _staticHandlersInitialized = _addStaticHandlers();

    /**
     * Loops through all views and sets the focus on the first
     * active one.
     */
    static var updateFocus = updateFocus;
}
