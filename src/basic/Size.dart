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

 #library("Size.dart");

/**
 * @name Size
 *
 * @class The Size object is used to describe the size of something, through
 * its {@link #width} and {@link #height} properties.
 *
 * @classexample
 * // Create a size that is 10pt wide and 5pt high
 * var size = new Size(10, 5);
 * console.log(size.width); // 10
 * console.log(size.height); // 5
 */
class Size {
  num _width, _height;
  // DOCS: improve Size class description
  /**
   * Creates a Size object with the given width and height values.
   *
   * @name Size#initialize
   * @param {Number} width the width
   * @param {Number} height the height
   *
   * @example
   * // Create a size that is 10pt wide and 5pt high
   * var size = new Size(10, 5);
   * console.log(size.width); // 10
   * console.log(size.height); // 5
   */ // TODO the ending slash was missing here. fix and submit patch to paper.js
  /**
   * Creates a Size object using the numbers in the given array as
   * dimensions.
   *
   * @name Size#initialize
   * @param {array} array
   *
   * @example
   * // Creating a size of width: 320, height: 240 using an array of numbers:
   * var array = [320, 240];
   * var size = new Size(array);
   * console.log(size.width); // 320
   * console.log(size.height); // 240
   */
  /**
   * Creates a Size object using the properties in the given object.
   *
   * @name Size#initialize
   * @param {object} object
   *
   * @example
   * // Creating a size of width: 10, height: 20 using an object literal:
   *
   * var size = new Size({
   *   width: 10,
   *   height: 20
   * });
   * console.log(size.width); // 10
   * console.log(size.height); // 20
   */
  /**
   * Creates a Size object using the coordinates of the given Size object.
   *
   * @name Size#initialize
   * @param {Size} size
   */
  /**
   * Creates a Size object using the {@link Point#x} and {@link Point#y}
   * values of the given Point object.
   *
   * @name Size#initialize
   * @param {Point} point
   *
   * @example
   * var point = new Point(50, 50);
   * var size = new Size(point);
   * console.log(size.width); // 50
   * console.log(size.height); // 50
   */
  Size([arg0, arg1]) {
    if(arg1 == null) {
      _width = arg0;
      _height = arg1;
    } else if(arg0 != null) {
      if(arg0 is Map) {
        if(arg0.containsKey("width")) {
          _width = arg0["width"];
          _height = arg1["height"];
        }
      } else if(arg0 is Point) {
        _width = arg0.x;
        _height = arg0.y;
      } else if(arg0 is List) {
        _width = arg0[0];
        _height = arg0.length > 1 ? arg0[1] : arg0[0];
      } else if(arg0 is num) {
        _width = _height = arg0;
      }
    } else {
      _width = _height = 0;
    }
  }

  /**
   * @return {String} A string representation of the size.
   */
  String toString() {
    var format = Base.formatNumber;
    return '{ width: ${format(this.width)}'
           ', height: ${format(this.height)} }';
  }

  /**
   * The width of the size
   *
   * @name Size#width
   * @type Number
   */
  num get width() => _width;
      set width(num value) => _width = value;

  /**
   * The height of the size
   *
   * @name Size#height
   * @type Number
   */
  num get height() => _height;
      set height(num value) => _height = value;

  Size set(num width, num height) {
    this.width = width;
    this.height = height;
    return this;
  }

  /**
   * Returns a copy of the size.
   */
  Size clone() {
    return new Size.create(width, height);
  }

  /**
   * Returns the addition of the supplied value to the width and height of the
   * size as a new size. The object itself is not modified!
   *
   * @name Size#add
   * @function
   * @param {Number} number the number to add
   * @return {Size} the addition of the size and the value as a new size
   *
   * @example
   * var size = new Size(5, 10);
   * var result = size + 20;
   * console.log(result); // {width: 25, height: 30}
   */
  /**
   * Returns the addition of the width and height of the supplied size to the
   * size as a new size. The object itself is not modified!
   *
   * @name Size#add
   * @function
   * @param {Size} size the size to add
   * @return {Size} the addition of the two sizes as a new size
   *
   * @example
   * var size1 = new Size(5, 10);
   * var size2 = new Size(10, 20);
   * var result = size1 + size2;
   * console.log(result); // {width: 15, height: 30}
   */
  // TODO support first version with read
  Size add(Size size) {
    //size = Size.read(arguments);
    return new Size.create(width + size.width, height + size.height);
  }
  // operator
  Size operator + (Size size) => add(size);

  /**
   * Returns the subtraction of the supplied value from the width and height
   * of the size as a new size. The object itself is not modified!
   * The object itself is not modified!
   *
   * @name Size#subtract
   * @function
   * @param {Number} number the number to subtract
   * @return {Size} the subtraction of the size and the value as a new size
   *
   * @example
   * var size = new Size(10, 20);
   * var result = size - 5;
   * console.log(result); // {width: 5, height: 15}
   */
  /**
   * Returns the subtraction of the width and height of the supplied size from
   * the size as a new size. The object itself is not modified!
   *
   * @name Size#subtract
   * @function
   * @param {Size} size the size to subtract
   * @return {Size} the subtraction of the two sizes as a new size
   *
   * @example
   * var firstSize = new Size(10, 20);
   * var secondSize = new Size(5, 5);
   * var result = firstSize - secondSize;
   * console.log(result); // {width: 5, height: 15}
   */
  // TODO support first version with read
  Size subtract(Size size) {
    //size = Size.read(arguments);
    return new Size.create(width - size.width, height - size.height);
  }
  // operator
  Size operator - (Size size) => subtract(size);

  /**
   * Returns the multiplication of the supplied value with the width and
   * height of the size as a new size. The object itself is not modified!
   *
   * @name Size#multiply
   * @function
   * @param {Number} number the number to multiply by
   * @return {Size} the multiplication of the size and the value as a new size
   *
   * @example
   * var size = new Size(10, 20);
   * var result = size * 2;
   * console.log(result); // {width: 20, height: 40}
   */
  /**
   * Returns the multiplication of the width and height of the supplied size
   * with the size as a new size. The object itself is not modified!
   *
   * @name Size#multiply
   * @function
   * @param {Size} size the size to multiply by
   * @return {Size} the multiplication of the two sizes as a new size
   *
   * @example
   * var firstSize = new Size(5, 10);
   * var secondSize = new Size(4, 2);
   * var result = firstSize * secondSize;
   * console.log(result); // {width: 20, height: 20}
   */
  // TODO support first version with read
  Size multiply(Size size) {
    //size = Size.read(arguments);
    return new Size.create(width * size.width, height * size.height);
  }
  // operator
  Size operator * (Size size) => multiply(size);

  /**
   * Returns the division of the supplied value by the width and height of the
   * size as a new size. The object itself is not modified!
   *
   * @name Size#divide
   * @function
   * @param {Number} number the number to divide by
   * @return {Size} the division of the size and the value as a new size
   *
   * @example
   * var size = new Size(10, 20);
   * var result = size / 2;
   * console.log(result); // {width: 5, height: 10}
   */
  /**
   * Returns the division of the width and height of the supplied size by the
   * size as a new size. The object itself is not modified!
   *
   * @name Size#divide
   * @function
   * @param {Size} size the size to divide by
   * @return {Size} the division of the two sizes as a new size
   *
   * @example
   * var firstSize = new Size(8, 10);
   * var secondSize = new Size(2, 5);
   * var result = firstSize / secondSize;
   * console.log(result); // {width: 4, height: 2}
   */
  // TODO support first version with read
  Size divide(Size size) {
    //size = Size.read(arguments);
    return new Size.create(width / size.width, height / size.height);
  }
  // operator
  Size operator / (Size size) => divide(size);

  /**
   * The modulo operator returns the integer remainders of dividing the size
   * by the supplied value as a new size.
   *
   * @name Size#modulo
   * @function
   * @param {Number} value
   * @return {Size} the integer remainders of dividing the size by the value
   *                 as a new size
   *
   * @example
   * var size = new Size(12, 6);
   * console.log(size % 5); // {width: 2, height: 1}
   */
  /**
   * The modulo operator returns the integer remainders of dividing the size
   * by the supplied size as a new size.
   *
   * @name Size#modulo
   * @function
   * @param {Size} size
   * @return {Size} the integer remainders of dividing the sizes by each
   *                 other as a new size
   *
   * @example
   * var size = new Size(12, 6);
   * console.log(size % new Size(5, 2)); // {width: 2, height: 0}
   */
  // TODO support first version with read
  Size modulo(Size size) {
    //size = Size.read(arguments);
    return new Size.create(width % size.width, height % size.height);
  }
  // operator
  Size operator % (Size size) => modulo(size);

  Size negate() {
    return new Size.create(-this.width, -this.height);
  }
  // operator
  // TODO uncomment once they support this
  //Size operator - () => negate();

  /**
   * Checks whether the width and height of the size are equal to those of the
   * supplied size.
   *
   * @param {Size}
   * @return {Boolean}
   *
   * @example
   * var size = new Size(5, 10);
   * console.log(size == new Size(5, 10)); // true
   * console.log(size == new Size(1, 1)); // false
   * console.log(size != new Size(1, 1)); // true
   */
  bool equals(Size size) {
    //size = Size.read(arguments);
    return width == size.width && height == size.height;
  }
  // operator
  bool operator == (Size size) => equals(size);

  /**
   * {@grouptitle Tests}
   * Checks if this size has both the width and height set to 0.
   *
   * @return {Boolean} {@true both width and height are 0}
   */
  bool isZero() {
    return width == 0 && height == 0;
  }

  /**
   * Checks if the width or the height of the size are NaN.
   *
   * @return {Boolean} {@true if the width or height of the size are NaN}
   */
  bool isNaN() {
    return isNaN(width) || isNaN(height);
  }

  Size.create(num width, num height) {
    this.set(width, height);
  }

  /**
   * Returns a new size object with the smallest {@link #width} and
   * {@link #height} of the supplied sizes.
   *
   * @static
   * @param {Size} size1
   * @param {Size} size2
   * @returns {Size} The newly created size object
   *
   * @example
   * var size1 = new Size(10, 100);
   * var size2 = new Size(200, 5);
   * var minSize = Size.min(size1, size2);
   * console.log(minSize); // {width: 10, height: 5}
   */
  static Size min(Size size1, Size size2) {
    return new Size.create(
      Math.min(size1.width, size2.width),
      Math.min(size1.height, size2.height));
  }

  /**
   * Returns a new size object with the largest {@link #width} and
   * {@link #height} of the supplied sizes.
   *
   * @static
   * @param {Size} size1
   * @param {Size} size2
   * @returns {Size} The newly created size object
   *
   * @example
   * var size1 = new Size(10, 100);
   * var size2 = new Size(200, 5);
   * var maxSize = Size.max(size1, size2);
   * console.log(maxSize); // {width: 200, height: 100}
   */
  static Size max(Size size1, Size size2) {
    return new Size.create(
      Math.max(size1.width, size2.width),
      Math.max(size1.height, size2.height));
  }

  /**
   * Returns a size object with random {@link #width} and {@link #height}
   * values between {@code 0} and {@code 1}.
   *
   * @returns {Size} The newly created size object
   * @static
   *
   * @example
   * var maxSize = new Size(100, 100);
   * var randomSize = Size.random();
   * var size = maxSize * randomSize;
   */
  Size.random() {
    this.set(Math.random(), Math.random());
  }

  /**
   * {@grouptitle Math Functions}
   *
   * Returns a new size with rounded {@link #width} and {@link #height} values.
   * The object itself is not modified!
   *
   * @name Size#round
   * @function
   * @return {Size}
   *
   * @example
   * var size = new Size(10.2, 10.9);
   * var roundSize = size.round();
   * console.log(roundSize); // {x: 10, y: 11}
   */
   Size round() {
    // TODO check if dart's round is the same as js
    returns new Size.create(width.round(), height.round());
   }

  /**
   * Returns a new size with the nearest greater non-fractional values to the
   * specified {@link #width} and {@link #height} values. The object itself is not
   * modified!
   *
   * @name Size#ceil
   * @function
   * @return {Size}
   *
   * @example
   * var size = new Size(10.2, 10.9);
   * var ceilSize = size.ceil();
   * console.log(ceilSize); // {x: 11, y: 11}
   */
   Size ceil() {
    return new Size.create(width.ceil(), height.ceil());
   }

  /**
   * Returns a new size with the nearest smaller non-fractional values to the
   * specified {@link #width} and {@link #height} values. The object itself is not
   * modified!
   *
   * @name Size#floor
   * @function
   * @return {Size}
   *
   * @example
   * var size = new Size(10.2, 10.9);
   * var floorSize = size.floor();
   * console.log(floorSize); // {x: 10, y: 10}
   */
   Size floor() {
    return new Size.create(width.floor(), height.floor());
   }

  /**
   * Returns a new size with the absolute values of the specified {@link #width}
   * and {@link #height} values. The object itself is not modified!
   *
   * @name Size#abs
   * @function
   * @return {Size}
   *
   * @example
   * var size = new Size(-5, 10);
   * var absSize = size.abs();
   * console.log(absSize); // {x: 5, y: 10}
   */
   Size abs() {
    return new Size.create(width.abs(), height.abs());
   }
}

/**
 * @name LinkedSize
 *
 * @class An internal version of Size that notifies its owner of each change
 * through setting itself again on the setter that corresponds to the getter
 * that produced this LinkedSize. See uses of LinkedSize.create()
 * Note: This prototype is not exported.
 *
 * @private
 */
class LinkedSize extends Size {
  Object _owner;
  var _setter;

  LinkedSize set(num width, num height, [dontNotify = false]) {
    _width = width;
    _height = height;
    if (!dontNotify)
      //this._owner[this._setter](this);
      _setter(this);
    return this;
  }

  // TODO Size should already have this
//  num getWidth() {
//    return _width;
//  }

  setWidth(num width) {
    this._width = width;
    //this._owner[this._setter](this);
    _setter(this);
  }

  // TODO Size should already have this
//  num getHeight() {
//    return _height;
//  }

  setHeight(num height) {
    _height = height;
    //this._owner[this._setter](this);
    _setter(this);
  }

  factory LinkedSize.create(Object owner, setter, num width, num height, [bool dontLink = false]) {
      // See LinkedPoint.create() for an explanation about dontLink.
      if (dontLink)
        return Size.create(width, height);
      var size = new LinkedSize(LinkedSize.dont);
      size._width = width;
      size._height = height;
      size._owner = owner;
      size._setter = setter;
      return size;
    }
  }
}
