part of Basic.dart;

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
 * @name Rectangle
 *
 * @class A Rectangle specifies an area that is enclosed by it's top-left
 * point (x, y), its width, and its height. It should not be confused with a
 * rectangular path, it is not an item.
 */
class Rectangle {
  num _x, _y, _width, _height;
  /**
   * Creates a Rectangle object.
   *
   * @name Rectangle#initialize
   * @param {Point} point the top-left point of the rectangle
   * @param {Size} size the size of the rectangle
   */
  /**
   * Creates a rectangle object.
   *
   * @name Rectangle#initialize
   * @param {Number} x the left coordinate
   * @param {Number} y the top coordinate
   * @param {Number} width
   * @param {Number} height
   */
  /**
   * Creates a rectangle object from the passed points. These do not
   * necessarily need to be the top left and bottom right corners, the
   * constructor figures out how to fit a rectangle between them.
   *
   * @name Rectangle#initialize
   * @param {Point} point1 The first point defining the rectangle
   * @param {Point} point2 The second point defining the rectangle
   */
  /**
   * Creates a new rectangle object from the passed rectangle object.
   *
   * @name Rectangle#initialize
   * @param {Rectangle} rt
   */
  Rectangle([arg0, arg1, arg2, arg3]) {
    if(arg3 is num) {
      // Rectangle(x, y, width, height)
      _x = arg0;
      _y = arg1;
      _width = arg2;
      _height = arg3;
    } else if(arg1 is Point) {
      // Rectangle(Point, Point)
      var point1 = Point.read(arg0);
      var point2 = Point.read(arg1);
      _x = point1.x;
      _y = point1.y;
      _width = point2.x - point1.x;
      _height = point2.y - point1.y;
      if(_width < 0) {
        _x = point2.x;
        _width = -_width;
      }
      if(_height < 0) {
        _y = point2.y;
        _height = -_height;
      }
    } else if(arg1 != null) {
      // Rectangle(Point, Size);
      var point1 = Point.read(arg0);
      var point2 = Size.read(arg1);
      _x = point1.x;
      _y = point1.y;
      _width = point2.width;
      _height = point2.height;
    } else if(arg0 is Rectangle) {
      // Rectangle(Rectangle)
      _x = arg0.x;
      _y = arg0.y;
      _width = arg0.width;
      _height = arg0.height;
    } else if(arg0 is Map && arg0.containsKey("width")) {
      _x = arg0["x"];
      _y = arg0["y"];
      _width = arg0["width"];
      _height = arg0["height"];
    } else {
      _x = _y = _width = _height = 0;
    }
  }

  // generate Rectangles from Rectangle-like things
  // TODO make a factory constructor
  static Rectangle read(arg) {
    if(arg is Rectangle) return arg;
    return new Rectangle(arg);
  }

  /**
   * The x position of the rectangle.
   *
   * @name Rectangle#x
   * @type Number
   */
  void setX(num value) { _x = value; }
  num get x => _x;
      set x(num value) => _x = value;

  /**
   * The y position of the rectangle.
   *
   * @name Rectangle#y
   * @type Number
   */
  void setY(num value) { _y = value; }
  num get y => _y;
      set y(num value) => _y = value;

  /**
   * The width of the rectangle.
   *
   * @name Rectangle#width
   * @type Number
   */
  num get width => _width;
      set width(num value) => _width = value;

  /**
   * The height of the rectangle.
   *
   * @name Rectangle#height
   * @type Number
   */
  num get height => _height;
      set height(num value) => _height = value;

  // DOCS: why does jsdocs document this function, when there are no comments?
  /**
   * @ignore
   */
  Rectangle set(num x, num y, num width, num height) {
    _x = x;
    _y = y;
    _width = width;
    _height = height;
    return this;
  }

  /**
   * The top-left point of the rectangle
   *
   * @type Point
   * @bean
   */
  Point getPoint([dontLink = false]) {
    // Pass on the optional argument dontLink which tells LinkedPoint to
    // produce a normal point instead. Used internally for speed reasons.
    return new LinkedPoint.create(this, setPoint, x, y,
        dontLink);
  }
  // point property
  Point get point => getPoint();

  Rectangle setPoint(/*Point*/ point) {
    point = Point.read(point);
    x = point.x;
    y = point.y;
    return this;
  }
  // TODO does js version have this setter?
   setpoint(Point value) => setPoint(value);

  /**
   * The size of the rectangle
   *
   * @type Size
   * @bean
   */
  Size getSize([dontLink = false]) {
    // See Rectangle#getPoint() about arguments[0]
    return LinkedSize.create(this, 'setSize', width, height,
        dontLink);
  }
  // property
  Size get size => getSize();

  Rectangle setSize(/*Size*/ size) {
    size = Size.read(size);
    width = size.width;
    height = size.height;
    return this;
  }
  // TODO does js version have this setter?
  set size(Size value) => setSize(value);

  /**
   * {@grouptitle Side Positions}
   *
   * The position of the left hand side of the rectangle. Note that this
   * doesn't move the whole rectangle; the right hand side stays where it was.
   *
   * @type Number
   * @bean
   */
  num getLeft() {
    return x;
  }
  // property
  num get left => x;

  Rectangle setLeft(num left) {
    width -= left - x;
    x = left;
    return this;
  }
  // property
  set left(value) => setLeft(value);

  /**
   * The top coordinate of the rectangle. Note that this doesn't move the
   * whole rectangle: the bottom won't move.
   *
   * @type Number
   * @bean
   */
  num getTop() {
    return y;
  }
  // property
  num get top => y;

  Rectangle setTop(num top) {
    height -= top - y;
    y = top;
    return this;
  }
  // property
  set top(num value) => setTop(value);

  /**
   * The position of the right hand side of the rectangle. Note that this
   * doesn't move the whole rectangle; the left hand side stays where it was.
   *
   * @type Number
   * @bean
   */
  num getRight() {
    return x + width;
  }
  // property
  num get right => getRight();

  Rectangle setRight(num right) {
    width = right - x;
    return this;
  }
  // property
  set right(num value) => setRight(value);

  /**
   * The bottom coordinate of the rectangle. Note that this doesn't move the
   * whole rectangle: the top won't move.
   *
   * @type Number
   * @bean
   */
  num getBottom() {
    return y + height;
  }
  // property
  num get bottom => getBottom();

  Rectangle setBottom(num bottom) {
    height = bottom - y;
    return this;
  }
  // property
  set bottom(num value) => setBottom(value);

  /**
   * The center-x coordinate of the rectangle.
   *
   * @type Number
   * @bean
   * @ignore
   */
  num getCenterX() {
    return x + width * 0.5;
  }
  // property
  num get centerX => getCenterX();

  Rectangle setCenterX(num x) {
    this.x = x - width * 0.5;
    return this;
  }
  // property
  set centerX(num value) => setCenterX(value);

  /**
   * The center-y coordinate of the rectangle.
   *
   * @type Number
   * @bean
   * @ignore
   */
  num getCenterY() {
    return y + height * 0.5;
  }
  // property
  num get centerY => getCenterY();

  Rectangle setCenterY(y) {
    this.y = y - height * 0.5;
    return this;
  }
  // property
  set centerY(num value) => setCenterY(value);

  /**
   * {@grouptitle Corner and Center Point Positions}
   *
   * The center point of the rectangle.
   *
   * @type Point
   * @bean
   */
  Point getCenter([dontLink]) {
    return new LinkedPoint.create(this, setCenter,
        getCenterX(), getCenterY(), dontLink);
  }
  // property
  Point get center => getCenter();

  Rectangle setCenter(/*Point*/ point) {
    point = Point.read(point);
    return setCenterX(point.x).setCenterY(point.y);
  }
  // property
  set center(Point value) => setCenter(value);

  // Get a point by name
  Point getNamedPoint(String name) {
    switch(name) {
      case "TopLeft": return topLeft;
      case "TopRight": return topRight;
      case "BottomLeft": return bottomLeft;
      case "BottomRight": return bottomRight;
      case "LeftCenter": return leftCenter;
      case "TopCenter": return topCenter;
      case "RightCenter": return rightCenter;
      case "BottomCenter": return bottomCenter;
      default: return null;
    }
  }
  /**
   * The top-left point of the rectangle.
   *
   * @name Rectangle#topLeft
   * @type Point
   */
  Point getTopLeft([dontLink = false]) {
    return new LinkedPoint.create(this, setTopLeft, getLeft(), getTop(), dontLink);
  }
  // property
  Point get topLeft => getTopLeft();

  Rectangle setTopLeft(/*Point*/ point) {
    point = Point.read(point);
    return setLeft(point.x).setTop(point.y);
  }
  // property
  set topLeft(/*Point*/ value) => setTopLeft(value);

  /**
   * The top-right point of the rectangle.
   *
   * @name Rectangle#topRight
   * @type Point
   */
  Point getTopRight([dontLink = false]) {
    return new LinkedPoint.create(this, setTopRight, getRight(), getTop(), dontLink);
  }
  // property
  Point get topRight => getTopRight();

  Rectangle setTopRight(/*Point*/ point) {
    point = Point.read(point);
    return setRight(point.x).setTop(point.y);
  }
  // property
  set topRight(/*Point*/ value) => setTopRight(value);

  /**
   * The bottom-left point of the rectangle.
   *
   * @name Rectangle#bottomLeft
   * @type Point
   */
  Point getBottomLeft([dontLink = false]) {
    return new LinkedPoint.create(this, setBottomLeft, getLeft(), getBottom(), dontLink);
  }
  // property
  Point get bottomLeft => getBottomLeft();

  Rectangle setBottomLeft(/*Point*/ point) {
    point = Point.read(point);
    return setLeft(point.x).setBottom(point.y);
  }
  // property
  set bottomLeft(/*Point*/ value) => setBottomLeft(value);

  /**
   * The bottom-right point of the rectangle.
   *
   * @name Rectangle#bottomRight
   * @type Point
   */
  Point getBottomRight([dontLink = false]) {
    return new LinkedPoint.create(this, setBottomRight, getRight(), getBottom(), dontLink);
  }
  // property
  Point get bottomRight => getBottomRight();

  Rectangle setBottomRight(/*Point*/ point) {
    point = Point.read(point);
    return setRight(point.x).setBottom(point.y);
  }
  // property
  set bottomRight(/*Point*/ value) => setBottomRight(value);

  /**
   * The left-center point of the rectangle.
   *
   * @name Rectangle#leftCenter
   * @type Point
   */
  Point getLeftCenter([dontLink = false]) {
    return new LinkedPoint.create(this, setLeftCenter, getLeft(), getCenterY(), dontLink);
  }
  // property
  Point get leftCenter => getLeftCenter();

  Rectangle setLeftCenter(/*Point*/ point) {
    point = Point.read(point);
    return setCenterY(point.y).setLeft(point.x);
  }
  // property
  set leftCenter(/*Point*/ value) => setLeftCenter(value);

  /**
   * The top-center point of the rectangle.
   *
   * @name Rectangle#topCenter
   * @type Point
   */
  Point getTopCenter([dontLink = false]) {
    return new LinkedPoint.create(this, setTopCenter, getCenterX(), getTop(), dontLink);
  }
  // property
  Point get topCenter => getTopCenter();

  Rectangle setTopCenter(/*Point*/ point) {
    point = Point.read(point);
    return setCenter(point.x).setTop(point.y);
  }
  // property
  set topCenter(/*Point*/ value) => setTopCenter(value);

  /**
   * The right-center point of the rectangle.
   *
   * @name Rectangle#rightCenter
   * @type Point
   */
  Point getRightCenter([dontLink = false]) {
    return new LinkedPoint.create(this, setRightCenter, getRight(), getCenterY(), dontLink);
  }
  // property
  Point get rightCenter => getRightCenter();

  Rectangle setRightCenter(/*Point*/ point) {
    point = Point.read(point);
    return setCenter(point.y).setRight(point.x);
  }
  // property
  set rightCenter(/*Point*/ value) => setRightCenter(value);

  /**
   * The bottom-center point of the rectangle.
   *
   * @name Rectangle#bottomCenter
   * @type Point
   */
  Point getBottomCenter([dontLink = false]) {
   return new LinkedPoint.create(this, setBottomCenter, getCenterX(), getBottom(), dontLink);
  }
  // property
  Point get bottomCenter => getBottomCenter();
  
  Rectangle setBottomCenter(/*Point*/ point) {
    point = Point.read(point);
    return setCenter(point.x).setBottom(point.y);
  }
  // property
  set bottomCenter(/*Point*/ value) => setBottomCenter(value);

  /**
   * Checks whether the coordinates and size of the rectangle are equal to
   * that of the supplied rectangle.
   *
   * @param {Rectangle} rect
   * @return {Boolean} {@true if the rectangles are equal}
   */
  bool equals(/*Rectangle*/ rect) {
    rect = Rectangle.read(rect);
    return this.x == rect.x && this.y == rect.y
        && this.width == rect.width && this.height == rect.height;
  }
  // operator
  bool operator ==(Rectangle rect) => equals(rect);

  /**
   * @return {Boolean} {@true the rectangle is empty}
   */
  bool isEmpty() {
    return width == 0 || height == 0;
  }

  /**
   * @return {String} A string representation of this rectangle.
   */
  String toString() {
    // TODO restore when format implemented
    //var format = Base.formatNumber;
    /*return '{ x: ${format(this.x)}'
           ', y: ${format(this.y)}'
           ', width: ${format(this.width)}'
           ', height: ${format(this.height)} }';*/
    return '{ x: ${x}'
           ', y: ${y}'
           ', width: ${width}'
           ', height: ${height} }';
  }

  /**
   * {@grouptitle Geometric Tests}
   *
   * Tests if the specified point is inside the boundary of the rectangle.
   *
   * @name Rectangle#contains
   * @function
   * @param {Point} point the specified point
   * @return {Boolean} {@true if the point is inside the rectangle's boundary}
   *
   * @example {@paperscript}
   * // Checking whether the mouse position falls within the bounding
   * // rectangle of an item:
   *
   * // Create a circle shaped path at {x: 80, y: 50}
   * // with a radius of 30.
   * var circle = new Path.Circle(new Point(80, 50), 30);
   * circle.fillColor = 'red';
   *
   * function onMouseMove(event) {
   *   // Check whether the mouse position intersects with the
   *   // bounding box of the item:
   *   if (circle.bounds.contains(event.point)) {
   *     // If it intersects, fill it with green:
   *     circle.fillColor = 'green';
   *   } else {
   *     // If it doesn't intersect, fill it with red:
   *     circle.fillColor = 'red';
   *   }
   * }
   */
  /**
   * Tests if the interior of the rectangle entirely contains the specified
   * rectangle.
   *
   * @name Rectangle#contains
   * @function
   * @param {Rectangle} rect The specified rectangle
   * @return {Boolean} {@true if the rectangle entirely contains the specified
   *                   rectangle}
   *
   * @example {@paperscript}
   * // Checking whether the bounding box of one item is contained within
   * // that of another item:
   *
   * // All newly created paths will inherit these styles:
   * project.currentStyle = {
   *   fillColor: 'green',
   *   strokeColor: 'black'
   * };
   *
   * // Create a circle shaped path at {x: 80, y: 50}
   * // with a radius of 45.
   * var largeCircle = new Path.Circle(new Point(80, 50), 45);
   *
   * // Create a smaller circle shaped path in the same position
   * // with a radius of 30.
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * function onMouseMove(event) {
   *   // Move the circle to the position of the mouse:
   *   circle.position = event.point;
   *
   *   // Check whether the bounding box of the smaller circle
   *   // is contained within the bounding box of the larger item:
   *   if (largeCircle.bounds.contains(circle.bounds)) {
   *     // If it does, fill it with green:
   *     circle.fillColor = 'green';
   *     largeCircle.fillColor = 'green';
   *   } else {
   *     // If doesn't, fill it with red:
   *     circle.fillColor = 'red';
   *     largeCircle.fillColor = 'red';
   *   }
   * }
   */
  bool contains(arg) {
    // Detect rectangles either by checking for 'width' on the passed object
    // or by looking at the amount of elements in the arguments list,
    // or the passed array:
//    return arg && arg.width !== undefined
//        || (Array.isArray(arg) ? arg : arguments).length == 4
//        ? this._containsRectangle(Rectangle.read(arguments))
//        : this._containsPoint(Point.read(arguments));
    // TODO to what extent can we accept Rectangle-like and Point-like objects in the same argument?
    if(arg is Rectangle) return _containsRectangle(arg);
    return containsPoint(Point.read(arg));
  }

  bool containsPoint(Point point) {
    num x = point.x;
    num y = point.y;
    return x >= this.x && y >= this.y
        && x <= this.x + this.width
        && y <= this.y + this.height;
  }

  bool _containsRectangle(Rectangle rect) {
    num x = rect.x;
    num y = rect.y;
    return x >= this.x && y >= this.y
        && x + rect.width <= this.x + this.width
        && y + rect.height <= this.y + this.height;
  }

  /**
   * Tests if the interior of this rectangle intersects the interior of
   * another rectangle.
   *
   * @param {Rectangle} rect the specified rectangle
   * @return {Boolean} {@true if the rectangle and the specified rectangle
   *                   intersect each other}
   *
   * @example {@paperscript}
   * // Checking whether the bounding box of one item intersects with
   * // that of another item:
   *
   * // All newly created paths will inherit these styles:
   * project.currentStyle = {
   *   fillColor: 'green',
   *   strokeColor: 'black'
   * };
   *
   * // Create a circle shaped path at {x: 80, y: 50}
   * // with a radius of 45.
   * var largeCircle = new Path.Circle(new Point(80, 50), 45);
   *
   * // Create a smaller circle shaped path in the same position
   * // with a radius of 30.
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * function onMouseMove(event) {
   *   // Move the circle to the position of the mouse:
   *   circle.position = event.point;
   *
   *   // Check whether the bounding box of the two circle
   *   // shaped paths intersect:
   *   if (largeCircle.bounds.intersects(circle.bounds)) {
   *     // If it does, fill it with green:
   *     circle.fillColor = 'green';
   *     largeCircle.fillColor = 'green';
   *   } else {
   *     // If doesn't, fill it with red:
   *     circle.fillColor = 'red';
   *     largeCircle.fillColor = 'red';
   *   }
   * }
   */
  bool intersects(/*Rectangle*/ rect) {
    rect = Rectangle.read(rect);
    return rect.x + rect.width > this.x
        && rect.y + rect.height > this.y
        && rect.x < this.x + this.width
        && rect.y < this.y + this.height;
  }

  /**
   * {@grouptitle Boolean Operations}
   *
   * Returns a new rectangle representing the intersection of this rectangle
   * with the specified rectangle.
   *
   * @param {Rectangle} rect The rectangle to be intersected with this
   *                         rectangle
   * @return {Rectangle} The largest rectangle contained in both the specified
   *                     rectangle and in this rectangle.
   *
   * @example {@paperscript}
   * // Intersecting two rectangles and visualizing the result using rectangle
   * // shaped paths:
   *
   * // Create two rectangles that overlap each other
   * var size = new Size(50, 50);
   * var rectangle1 = new Rectangle(new Point(25, 15), size);
   * var rectangle2 = new Rectangle(new Point(50, 40), size);
   *
   * // The rectangle that represents the intersection of the
   * // two rectangles:
   * var intersected = rectangle1.intersect(rectangle2);
   *
   * // To visualize the intersecting of the rectangles, we will
   * // create rectangle shaped paths using the Path.Rectangle
   * // constructor.
   *
   * // Have all newly created paths inherit a black stroke:
   * project.currentStyle.strokeColor = 'black';
   *
   * // Create two rectangle shaped paths using the abstract rectangles
   * // we created before:
   * new Path.Rectangle(rectangle1);
   * new Path.Rectangle(rectangle2);
   *
   * // Create a path that represents the intersected rectangle,
   * // and fill it with red:
   * var intersectionPath = new Path.Rectangle(intersected);
   * intersectionPath.fillColor = 'red';
   */
  Rectangle intersect(/*Rectangle*/ rect) {
    rect = Rectangle.read(rect);
    num x1 = Math.max(this.x, rect.x);
    num y1 = Math.max(this.y, rect.y);
    num x2 = Math.min(this.x + this.width, rect.x + rect.width);
    num y2 = Math.min(this.y + this.height, rect.y + rect.height);
    return new Rectangle.create(x1, y1, x2 - x1, y2 - y1);
  }

  /**
   * Returns a new rectangle representing the union of this rectangle with the
   * specified rectangle.
   *
   * @param {Rectangle} rect the rectangle to be combined with this rectangle
   * @return {Rectangle} the smallest rectangle containing both the specified
   *                     rectangle and this rectangle.
   */
  Rectangle unite(/*Rectangle*/ rect) {
    rect = Rectangle.read(rect);
    num x1 = Math.min(this.x, rect.x);
    num y1 = Math.min(this.y, rect.y);
    num x2 = Math.max(this.x + this.width, rect.x + rect.width);
    num y2 = Math.max(this.y + this.height, rect.y + rect.height);
    return new Rectangle.create(x1, y1, x2 - x1, y2 - y1);
  }

  /**
   * Adds a point to this rectangle. The resulting rectangle is the
   * smallest rectangle that contains both the original rectangle and the
   * specified point.
   *
   * After adding a point, a call to {@link #contains(point)} with the added
   * point as an argument does not necessarily return {@code true}.
   * The {@link Rectangle#contains(point)} method does not return {@code true}
   * for points on the right or bottom edges of a rectangle. Therefore, if the
   * added point falls on the left or bottom edge of the enlarged rectangle,
   * {@link Rectangle#contains(point)} returns {@code false} for that point.
   *
   * @param {Point} point
   */
  Rectangle include(/*Point*/ point) {
    point = Point.read(point);
    num x1 = Math.min(this.x, point.x);
    num y1 = Math.min(this.y, point.y);
    num x2 = Math.max(this.x + this.width, point.x);
    num y2 = Math.max(this.y + this.height, point.y);
    return new Rectangle.create(x1, y1, x2 - x1, y2 - y1);
  }

  /**
   * Expands the rectangle by the specified amount in both horizontal and
   * vertical directions.
   *
   * @name Rectangle#expand
   * @function
   * @param {Number} amount
   */
  /**
   * Expands the rectangle in horizontal direction by the specified
   * {@code hor} amount and in vertical direction by the specified {@code ver}
   * amount.
   *
   * @name Rectangle#expand^2
   * @function
   * @param {Number} hor
   * @param {Number} ver
   */
  Rectangle expand(num hor, [num ver]) {
    if (ver === null)
      ver = hor;
    return new Rectangle.create(this.x - hor / 2, this.y - ver / 2,
        this.width + hor, this.height + ver);
  }

  /**
   * Scales the rectangle by the specified amount from its center.
   *
   * @name Rectangle#scale
   * @function
   * @param {Number} amount
   */
  /**
   * Scales the rectangle in horizontal direction by the specified
   * {@code hor} amount and in vertical direction by the specified {@code ver}
   * amount from its center.
   *
   * @name Rectangle#scale^2
   * @function
   * @param {Number} hor
   * @param {Number} ver
   */
  Rectangle scale(num hor, [num ver]) {
    return this.expand(this.width * hor - this.width,
        this.height * (ver === null ? hor : ver) - this.height);
  }

  Rectangle.create(num x, num y, num width, num height) {
    this.set(x,y,width,height);
  }
}

/**
 * @name LinkedRectangle
 *
 * @class An internal version of Rectangle that notifies its owner of each
 * change through setting itself again on the setter that corresponds to the
 * getter that produced this LinkedRectangle.
 * See uses of LinkedRectangle.create()
 * Note: This prototype is not exported.
 *
 * @private
 */
class LinkedRectangle extends Rectangle {
  bool _dontNotify;
  var _owner, _setter;

  LinkedRectangle set(num x, num y, num width, num height, [bool dontNotify = false]) {
    this._x = x;
    this._y = y;
    this._width = width;
    this._height = height;
    if (!dontNotify)
      _setter(this);
      //this._owner[this._setter](this);
    return this;
  }

  // TODO submit fixed comment to paper.js
  /**
   * Provide a faster creator for Points out of two coordinates that
   * does not rely on Point#initialize at all. This speeds up all math
   * operations a lot.
   *
   * @ignore
   */
  LinkedRectangle.create(Object owner, setter, num x, num y, num width, num height) {
    this.set(x,y,width, height, true);
    _owner = owner;
    _setter = setter;
    _dontNotify = false;
    //return rect;
  }

  // Notifying accessors
  Rectangle setX(num x) {
    super.setX(x);
    if(!_dontNotify) _setter(this);
    return this;
  }
  set x(num value) => setX(value);

  Rectangle setY(num y) {
    super.setY(y);
    if(!_dontNotify) _setter(this);
    return this;
  }
  set y(num value) => setY(value);

  Rectangle setPoint(Point point) {
    _dontNotify = true;
    super.setPoint(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set point(Point value) => setPoint(value);

  Rectangle setSize(/*Size*/ size) {
    _dontNotify = true;
    super.setSize(size);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set size(/*Size*/ value) => setSize(value);

  Rectangle setCenter(/*Point*/ point) {
    _dontNotify = true;
    super.setCenter(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set center(/*Point*/ value) => setCenter(value);

  Rectangle setLeft(num left) {
    _dontNotify = true;
    super.setLeft(left);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set left(num value) => setLeft(value);

  Rectangle setTop(num top) {
    _dontNotify = true;
    super.setTop(top);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set top(num value) => setTop(value);

  Rectangle setRight(num right) {
    _dontNotify = true;
    super.setRight(right);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set right(num value) => setRight(value);

  Rectangle setBottom(num bottom) {
    _dontNotify = true;
    super.setBottom(bottom);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set bottom(num value) => setBottom(value);

  Rectangle setCenterX(num centerX) {
    _dontNotify = true;
    super.setCenterX(centerX);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set centerX(num value) => setCenterX(value);

  Rectangle setCenterY(num centerY) {
    _dontNotify = true;
    super.setCenterY(centerY);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set centerY(num value) => setCenterY(value);

  Rectangle setTopLeft(/*Point*/ point) {
    _dontNotify = true;
    super.setTopLeft(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set topLeft(/*Point*/ value) => setTopLeft(value);

  Rectangle setTopRight(/*Point*/ point) {
    _dontNotify = true;
    super.setTopRight(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set topRight(/*Point*/ value) => setTopRight(value);

  Rectangle setBottomLeft(/*Point*/ point) {
    _dontNotify = true;
    super.setBottomLeft(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set bottomLeft(/*Point*/ value) => setBottomLeft(value);

  Rectangle setBottomRight(/*Point*/ point) {
    _dontNotify = true;
    super.setBottomRight(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set bottomRight(/*Point*/ value) => setBottomRight(value);

  Rectangle setLeftCenter(/*Point*/ point) {
    _dontNotify = true;
    super.setLeftCenter(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set leftCenter(/*Point*/ value) => setLeftCenter(value);

  Rectangle setTopCenter(/*Point*/ point) {
    _dontNotify = true;
    super.setTopCenter(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set topCenter(/*Point*/ value) => setTopCenter(value);

  Rectangle setRightCenter(/*Point*/ point) {
    _dontNotify = true;
    super.setRightCenter(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set rightCenter(/*Point*/ value) => setRightCenter(value);

  Rectangle setBottomCenter(/*Point*/ point) {
    _dontNotify = true;
    super.setBottomCenter(point);
    _dontNotify = false;
    _setter(this);
    return this;
  }
  set bottomCenter(/*Point*/ value) => setBottomCenter(value);
}
