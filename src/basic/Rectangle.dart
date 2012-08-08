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
      _x = arg0.x;
      _y = arg0.y;
      _width = arg1.x - arg0.x;
      _height = arg1.y - arg0.y;
      if(_width < 0) {
        _x = arg1.x;
        _width = -_width;
      }
      if(_height < 0) {
        _y = arg1.y;
        _width = -_width;
      }
    } else if(arg1 is Size) {
      // Rectangle(Point, Size);
      _x = arg0.x;
      _y = arg0.y;
      _width = arg1.width;
      _height = arg2.height;
    } else if(arg0 is Rectangle) {
      // Rectangle(Rectangle)
      _x = arg0.x;
      _y = arg0.y;
      _width = arg0.width;
      _height = arg0.height;
    } else {
      _x = _y = _width = _height = 0;
    }
  }

  /**
   * The x position of the rectangle.
   *
   * @name Rectangle#x
   * @type Number
   */
  num get x() => _x;

  /**
   * The y position of the rectangle.
   *
   * @name Rectangle#y
   * @type Number
   */
  num get y() => _y;

  /**
   * The width of the rectangle.
   *
   * @name Rectangle#width
   * @type Number
   */
  num get width() => _width;

  /**
   * The height of the rectangle.
   *
   * @name Rectangle#height
   * @type Number
   */
  num get height() => _height;

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
  // TODO ohhhhhh, this is what linked points are for
  // TODO yeah, we will have to implement that
  Point getPoint([dontLink]) {
    // Pass on the optional argument dontLink which tells LinkedPoint to
    // produce a normal point instead. Used internally for speed reasons.
    return new LinkedPoint(this, 'setPoint', x, y,
        dontlink);
  }
  // point property
  Point get point() => getPoint();

  Rectangle setPoint(Point point) {
    x = point.x;
    y = point.y;
    return this;
  }
  // TODO does js version have this setter?
  Point set point(Point value) => setPoint(value);

  /**
   * The size of the rectangle
   *
   * @type Size
   * @bean
   */
  Size getSize([dontLink]) {
    // See Rectangle#getPoint() about arguments[0]
    return new LinkedSize(this, 'setSize', width, height,
        dontLink);
  }

  Rectangle setSize(Size size) {
    width = size.width;
    height = size.height;
    return this;
  }
  // TODO does js version have this setter?
  Size set size(Size value) => setSize(value);

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
  num get left() => x;

  Rectangle setLeft(num left) {
    width -= left - x;
    x = left;
    return this;
  }
  // property
  num set left(value) => setLeft(value);

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
  num get top() => y;

  Rectangle setTop(num top) {
    height -= top - y;
    y = top;
    return this;
  }
  // property
  num set top(num value) => setTop(value);

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
  num get right() => getRight();

  Rectangle setRight(num right) {
    width = right - x;
    return this;
  }
  // property
  num set right(num value) => setRight(value);

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
  num get bottom() => getBottom();

  Rectangle setBottom(num bottom) {
    height = bottom - y;
    return this;
  }
  // property
  num set bottom(num value) => setBottom(value);

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
  num get centerX() => getCenterX();

  Rectangle setCenterX(num x) {
    this.x = x - width * 0.5;
    return this;
  }
  // property
  num set centerX(num value) => setCenterX(value);

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
  num get centerY() => getCenterY();

  Rectangle setCenterY(y) {
    this.y = y - height * 0.5;
    return this;
  }
  // property
  num set centerY(num value) => setCenterY(value);

  /**
   * {@grouptitle Corner and Center Point Positions}
   *
   * The center point of the rectangle.
   *
   * @type Point
   * @bean
   */
  Point getCenter([dontLink]) {
    return LinkedPoint.create(this, 'setCenter',
        this.getCenterX(), this.getCenterY(), dontLink);
  }
  // property
  Point get center() => getCenter();

  Rectangle setCenter(point) {
    return setCenterX(point.x).setCenterY(point.y);
  }

  /**
   * The top-left point of the rectangle.
   *
   * @name Rectangle#topLeft
   * @type Point
   */

  /**
   * The top-right point of the rectangle.
   *
   * @name Rectangle#topRight
   * @type Point
   */

  /**
   * The bottom-left point of the rectangle.
   *
   * @name Rectangle#bottomLeft
   * @type Point
   */

  /**
   * The bottom-right point of the rectangle.
   *
   * @name Rectangle#bottomRight
   * @type Point
   */

  /**
   * The left-center point of the rectangle.
   *
   * @name Rectangle#leftCenter
   * @type Point
   */

  /**
   * The top-center point of the rectangle.
   *
   * @name Rectangle#topCenter
   * @type Point
   */

  /**
   * The right-center point of the rectangle.
   *
   * @name Rectangle#rightCenter
   * @type Point
   */

  /**
   * The bottom-center point of the rectangle.
   *
   * @name Rectangle#bottomCenter
   * @type Point
   */

  /**
   * Checks whether the coordinates and size of the rectangle are equal to
   * that of the supplied rectangle.
   *
   * @param {Rectangle} rect
   * @return {Boolean} {@true if the rectangles are equal}
   */
  equals: function(rect) {
    rect = Rectangle.read(arguments);
    return this.x == rect.x && this.y == rect.y
        && this.width == rect.width && this.height == rect.height;
  },

  /**
   * @return {Boolean} {@true the rectangle is empty}
   */
  isEmpty: function() {
    return this.width == 0 || this.height == 0;
  },

  /**
   * @return {String} A string representation of this rectangle.
   */
  toString: function() {
    var format = Base.formatNumber;
    return '{ x: ' + format(this.x)
        + ', y: ' + format(this.y)
        + ', width: ' + format(this.width)
        + ', height: ' + format(this.height)
        + ' }';
  },

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
  contains: function(arg) {
    // Detect rectangles either by checking for 'width' on the passed object
    // or by looking at the amount of elements in the arguments list,
    // or the passed array:
    return arg && arg.width !== undefined
        || (Array.isArray(arg) ? arg : arguments).length == 4
        ? this._containsRectangle(Rectangle.read(arguments))
        : this._containsPoint(Point.read(arguments));
  },

  _containsPoint: function(point) {
    var x = point.x,
      y = point.y;
    return x >= this.x && y >= this.y
        && x <= this.x + this.width
        && y <= this.y + this.height;
  },

  _containsRectangle: function(rect) {
    var x = rect.x,
      y = rect.y;
    return x >= this.x && y >= this.y
        && x + rect.width <= this.x + this.width
        && y + rect.height <= this.y + this.height;
  },

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
  intersects: function(rect) {
    rect = Rectangle.read(arguments);
    return rect.x + rect.width > this.x
        && rect.y + rect.height > this.y
        && rect.x < this.x + this.width
        && rect.y < this.y + this.height;
  },

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
  intersect: function(rect) {
    rect = Rectangle.read(arguments);
    var x1 = Math.max(this.x, rect.x),
      y1 = Math.max(this.y, rect.y),
      x2 = Math.min(this.x + this.width, rect.x + rect.width),
      y2 = Math.min(this.y + this.height, rect.y + rect.height);
    return Rectangle.create(x1, y1, x2 - x1, y2 - y1);
  },

  /**
   * Returns a new rectangle representing the union of this rectangle with the
   * specified rectangle.
   *
   * @param {Rectangle} rect the rectangle to be combined with this rectangle
   * @return {Rectangle} the smallest rectangle containing both the specified
   *                     rectangle and this rectangle.
   */
  unite: function(rect) {
    rect = Rectangle.read(arguments);
    var x1 = Math.min(this.x, rect.x),
      y1 = Math.min(this.y, rect.y),
      x2 = Math.max(this.x + this.width, rect.x + rect.width),
      y2 = Math.max(this.y + this.height, rect.y + rect.height);
    return Rectangle.create(x1, y1, x2 - x1, y2 - y1);
  },

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
  include: function(point) {
    point = Point.read(arguments);
    var x1 = Math.min(this.x, point.x),
      y1 = Math.min(this.y, point.y),
      x2 = Math.max(this.x + this.width, point.x),
      y2 = Math.max(this.y + this.height, point.y);
    return Rectangle.create(x1, y1, x2 - x1, y2 - y1);
  },

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
  expand: function(hor, ver) {
    if (ver === undefined)
      ver = hor;
    return Rectangle.create(this.x - hor / 2, this.y - ver / 2,
        this.width + hor, this.height + ver);
  },

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
  scale: function(hor, ver) {
    return this.expand(this.width * hor - this.width,
        this.height * (ver === undefined ? hor : ver) - this.height);
  },

  statics: {
    // See Point.create()
    create: function(x, y, width, height) {
      return new Rectangle(Rectangle.dont).set(x, y, width, height);
    }
  }
}, new function() {
  return Base.each([
      ['Top', 'Left'], ['Top', 'Right'],
      ['Bottom', 'Left'], ['Bottom', 'Right'],
      ['Left', 'Center'], ['Top', 'Center'],
      ['Right', 'Center'], ['Bottom', 'Center']
    ],
    function(parts, index) {
      var part = parts.join('');
      // find out if the first of the pair is an x or y property,
      // by checking the first character for [R]ight or [L]eft;
      var xFirst = /^[RL]/.test(part);
      // Rename Center to CenterX or CenterY:
      if (index >= 4)
        parts[1] += xFirst ? 'Y' : 'X';
      var x = parts[xFirst ? 0 : 1],
        y = parts[xFirst ? 1 : 0],
        getX = 'get' + x,
        getY = 'get' + y,
        setX = 'set' + x,
        setY = 'set' + y,
        get = 'get' + part,
        set = 'set' + part;
      this[get] = function(/* dontLink */) {
        return LinkedPoint.create(this, set,
            this[getX](), this[getY](), arguments[0]);
      };
      this[set] = function(point) {
        point = Point.read(arguments);
        // Note: call chaining happens here.
        return this[setX](point.x)[setY](point.y);
      };
    }, {});
});

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
var LinkedRectangle = Rectangle.extend({
  set: function(x, y, width, height, dontNotify) {
    this._x = x;
    this._y = y;
    this._width = width;
    this._height = height;
    if (!dontNotify)
      this._owner[this._setter](this);
    return this;
  },

  statics: {
    /**
     * Provide a faster creator for Points out of two coordinates that
     * does not rely on Point#initialize at all. This speeds up all math
     * operations a lot.
     *
     * @ignore
     */
    create: function(owner, setter, x, y, width, height) {
      var rect = new LinkedRectangle(LinkedRectangle.dont).set(
          x, y, width, height, true);
      rect._owner = owner;
      rect._setter = setter;
      return rect;
    }
  }
}, new function() {
  var proto = Rectangle.prototype;

  return Base.each(['x', 'y', 'width', 'height'], function(key) {
    var part = Base.capitalize(key);
    var internal = '_' + key;
    this['get' + part] = function() {
      return this[internal];
    };

    this['set' + part] = function(value) {
      this[internal] = value;
      // Check if this setter is called from another one which sets
      // _dontNotify, as it will notify itself
      if (!this._dontNotify)
        this._owner[this._setter](this);
    };
  }, Base.each(['Point', 'Size', 'Center',
      'Left', 'Top', 'Right', 'Bottom', 'CenterX', 'CenterY',
      'TopLeft', 'TopRight', 'BottomLeft', 'BottomRight',
      'LeftCenter', 'TopCenter', 'RightCenter', 'BottomCenter'],
    function(key) {
      var name = 'set' + key;
      this[name] = function(value) {
        // Make sure the above setters of x, y, width, height do not
        // each notify the owner, as we're going to take care of this
        // afterwards here, only once per change.
        this._dontNotify = true;
        proto[name].apply(this, arguments);
        delete this._dontNotify;
        this._owner[this._setter](this);
        return this;
      };
    }, {})
  );
}