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
 * @name Raster
 *
 * @class The Raster item represents an image in a Paper.js project.
 *
 * @extends PlacedItem
 */
class Raster extends PlacedItem {
  // Raster doesn't make the distinction between the different bounds,
  // so use the same name for all of them
  //_boundsType: 'bounds'

  // TODO: Implement url / type, width, height.
  // TODO: Have PlacedSymbol & Raster inherit from a shared class?
  // DOCS: Document Raster constructor.
  /**
   * Creates a new raster item and places it in the active layer.
   *
   * @param {HTMLImageElement|Canvas|string} [object]
   */
  Raster(object, pointOrMatrix) {
    // TODO is this correct? see above
    _boundsType = {"bounds": "bounds"};
    // TODO figure out what base does
    this.base(pointOrMatrix);
    // TODO how to test for member? should test for type
    if (object.getContext != null) {
      setCanvas(object);
    } else {
/*#*/ if (options.browser) {
      // If it's a string, get the element with this id first.
      if (object is String) {
        object = query("#$object");
/*#*/ } else if (options.server) {
        // If we're running on the server and it's a string,
        // load it from disk:
        if (object is String) {
          // TODO: load images async
          var data = fs.readFileSync(object);
          object = new Image();
          object.src = data;
        }
/*#*/ } // options.server
      setImage(object);
    }
  }

  clone() {
    var image = _image;
    if (image == null) {
      // If the Raster contains a Canvas object, we need to create
      // a new one and draw this raster's canvas on it.
      image = CanvasProvider.getCanvas(_size);
      image.getContext('2d').drawImage(_canvas, 0, 0);
    }
    var copy = new Raster(image);
    return _clone(copy);
  }

  /**
   * The size of the raster in pixels.
   *
   * @type Size
   * @bean
   */
  Size getSize() {
    return _size;
  }
  Size get size => _size;

  void setSize(size) {
    Size size = Size.read(size);
    // Get reference to image before changing canvas
    Image image = getImage();
    // Setting canvas internally sets _size
    setCanvas(CanvasProvider.getCanvas(size));
    // Draw image back onto new canvas
    getContext(true).drawImage(image, 0, 0, size.width, size.height);
  }
  void set size(Size value) => setSize(value);

  /**
   * The width of the raster in pixels.
   *
   * @type Number
   * @bean
   */
  num getWidth() {
    return _size.width;
  }
  num get width => getWidth();

  /**
   * The height of the raster in pixels.
   *
   * @type Number
   * @bean
   */
  num getHeight() {
    return _size.height;
  }
  num get height => getHeight();

  /**
   * Pixels per inch of the raster at its current size.
   *
   * @type Size
   * @bean
   */
  Size getPpi() {
    var matrix = _matrix,
      orig = new Point(0, 0).transform(matrix),
      u = new Point(1, 0).transform(matrix).subtract(orig),
      v = new Point(0, 1).transform(matrix).subtract(orig);
    return Size.create(
      72 / u.getLength(),
      72 / v.getLength()
    );
  }
  Size get ppi => getPpi();

  /**
   * The Canvas 2d drawing context of the raster.
   *
   * @type Context
   * @bean
   */
  Context getContext([bool notifyChange = false]) {
    if (!_context)
      _context = getCanvas().getContext('2d');
    // Support a hidden parameter that indicates if the context will be used
    // to modify the Raster object. We can notify such changes ahead since
    // they are only used afterwards for redrawing.
    if (notifyChange)
      _changed(Change.PIXELS);
    return _context;
  }
  Context get context => getContext();

  void setContext(Context context) {
    _context = context;
  }
  void set context(Context value) setContext(value);

  Canvas getCanvas() {
    if (_canvas == null) {
      _canvas = CanvasProvider.getCanvas(_size);
      if (_image != null)
        getContext(true).drawImage(_image, 0, 0);
    }
    return _canvas;
  }
  Canvas get canvas => getCanvas();

  void setCanvas(Canvas canvas) {
    if (_canvas != null)
      CanvasProvider.returnCanvas(_canvas);
    _canvas = canvas;
    _size = Size.create(canvas.width, canvas.height);
    _image = null;
    _context = null;
    _changed(Change.GEOMETRY | Change.PIXELS);
  }
  set canvas(Canvas value) setCanvas(value);

  /**
   * The HTMLImageElement or Canvas of the raster.
   *
   * @type HTMLImageElement|Canvas
   * @bean
   */
  Image getImage() {
    return _image != null ? _image : getCanvas();
  }
  Image get image => getImage();

  // TODO: Support string id of image element.
  void setImage(Image image) {
    if (_canvas != null)
      CanvasProvider.returnCanvas(_canvas);
    _image = image;
/*#*/ if (options.browser) {
    _size = Size.create(image.naturalWidth, image.naturalHeight);
/*#*/ } else if (options.server) {
    _size = Size.create(image.width, image.height);
/*#*/ } // options.server
    _canvas = null;
    _context = null;
    _changed(Change.GEOMETRY);
  }
  set image(Image value) => setImage(value);

  // DOCS: document Raster#getSubImage
  /**
   * @param {Rectangle} rect the boundaries of the sub image in pixel
   * coordinates
   *
   * @return {Canvas}
   */
  Canvas getSubImage(/*Rectangle*/ rect) {
    rect = Rectangle.read(arguments);
    var canvas = CanvasProvider.getCanvas(rect.getSize());
    canvas.getContext('2d').drawImage(this.getCanvas(), rect.x, rect.y,
        canvas.width, canvas.height, 0, 0, canvas.width, canvas.height);
    return canvas;
  }

  /**
   * Draws an image on the raster.
   *
   * @param {HTMLImageELement|Canvas} image
   * @param {Point} point the offset of the image as a point in pixel
   * coordinates
   */
  void drawImage(image, point) {
    point = Point.read(point);
    getContext(true).drawImage(image, point.x, point.y);
  }

  /**
   * Calculates the average color of the image within the given path,
   * rectangle or point. This can be used for creating raster image
   * effects.
   *
   * @param {Path|Rectangle|Point} object
   * @return {RgbColor} the average color contained in the area covered by the
   * specified path, rectangle or point.
   */
  RgbColor getAverageColor([object]) {
    var bounds, path;
    if (object == null) {
      bounds = getBounds();
    } else if (object is PathItem) {
      // TODO: What if the path is smaller than 1 px?
      // TODO: How about rounding of bounds.size?
      path = object;
      bounds = object.getBounds();
    } else if (object is Rectangle) {
      bounds = new Rectangle(object);
    } else if (object is Point) {
      // Create a rectangle of 1px size around the specified coordinates
      bounds = Rectangle.create(object.x - 0.5, object.y - 0.5, 1, 1);
    }
    // Use a sample size of max 32 x 32 pixels, into which the path is
    // scaled as a clipping path, and then the actual image is drawn in and
    // sampled.
    var sampleSize = 32,
      width = min(bounds.width, sampleSize),
      height = min(bounds.height, sampleSize);
    // Reuse the same sample context for speed. Memory consumption is low
    // since it's only 32 x 32 pixels.
    var ctx = Raster._sampleContext;
    if (ctx == null) {
      ctx = Raster._sampleContext = CanvasProvider.getCanvas(
          new Size(sampleSize)).getContext('2d');
    } else {
      // Clear the sample canvas:
      ctx.clearRect(0, 0, sampleSize, sampleSize);
    }
    ctx.save();
    // Scale the context so that the bounds ends up at the given sample size
    ctx.scale(width / bounds.width, height / bounds.height);
    ctx.translate(-bounds);
    // If a path was passed, draw it as a clipping mask:
    if (path != null)
      path.draw(ctx, { "clip": true });
    // Now draw the image clipped into it.
    _matrix.applyToContext(ctx);
    ctx.drawImage(_canvas != null ? _canvas : _image,
        -_size.width / 2, -_size.height / 2);
    ctx.restore();
    // Get pixel data from the context and calculate the average color value
    // from it, taking alpha into account.
    var pixels = ctx.getImageData(0.5, 0.5, ceil(width),
        ceil(height)).data,
      channels = [0, 0, 0],
      total = 0;
    for (var i = 0, l = pixels.length; i < l; i += 4) {
      var alpha = pixels[i + 3];
      total += alpha;
      alpha /= 255;
      channels[0] += pixels[i] * alpha;
      channels[1] += pixels[i + 1] * alpha;
      channels[2] += pixels[i + 2] * alpha;
    }
    for (var i = 0; i < 3; i++)
      channels[i] /= total;
    return total ? Color.read(channels) : null;
  }

  /**
   * {@grouptitle Pixels}
   * Gets the color of a pixel in the raster.
   *
   * @name Raster#getPixel
   * @function
   * @param x the x offset of the pixel in pixel coordinates
   * @param y the y offset of the pixel in pixel coordinates
   * @return {RgbColor} the color of the pixel
   */
  /**
   * Gets the color of a pixel in the raster.
   *
   * @name Raster#getPixel
   * @function
   * @param point the offset of the pixel as a point in pixel coordinates
   * @return {RgbColor} the color of the pixel
   */
  RgbColor getPixel(/*Point*/ point, [y]) {
    point = Point.read(point, y);
    var pixels = getContext().getImageData(point.x, point.y, 1, 1).data,
      channels = new List(4);
    for (var i = 0; i < 4; i++)
      channels[i] = pixels[i] / 255;
    return RgbColor.read(channels);
  }

  /**
   * Sets the color of the specified pixel to the specified color.
   *
   * @name Raster#setPixel
   * @function
   * @param x the x offset of the pixel in pixel coordinates
   * @param y the y offset of the pixel in pixel coordinates
   * @param color the color that the pixel will be set to
   */
  /**
   * Sets the color of the specified pixel to the specified color.
   *
   * @name Raster#setPixel
   * @function
   * @param point the offset of the pixel as a point in pixel coordinates
   * @param color the color that the pixel will be set to
   */
  void setPixel(point, color) {
    point = Point.read(point);
    color = Color.read(color);
    var ctx = getContext(true),
      imageData = ctx.createImageData(1, 1),
      alpha = color.getAlpha();
    imageData.data[0] = color.getRed() * 255;
    imageData.data[1] = color.getGreen() * 255;
    imageData.data[2] = color.getBlue() * 255;
    imageData.data[3] = alpha != null ? alpha * 255 : 255;
    ctx.putImageData(imageData, point.x, point.y);
  }

  // DOCS: document Raster#createData
  /**
   * {@grouptitle Image Data}
   * @param {Size} size
   * @return {ImageData}
   */
  ImageData createData(/*Size*/ size) {
    size = Size.read(size);
    return getContext().createImageData(size.width, size.height);
  }

  // TODO: Rename to #get/setImageData, as it will conflict with Item#getData
  // DOCS: document Raster#getData
  /**
   * @param {Rectangle} rect
   * @return {ImageData}
   */
  ImageData getData(rect) {
    rect = Rectangle.read(rect);
    if (rect.isEmpty())
      rect = new Rectangle(getSize());
    return getContext().getImageData(rect.x, rect.y,
        rect.width, rect.height);
  }

  // DOCS: document Raster#setData
  /**
   * @param {ImageData} data
   * @param {Point} point
   * @return {ImageData}
   */
  void setData(data, point) {
    point = Point.read(point);
    getContext(true).putImageData(data, point.x, point.y);
  }

  Rectangle _getBounds(type, matrix) {
    var rect = new Rectangle(_size).setCenter(0, 0);
    return matrix ? matrix._transformBounds(rect) : rect;
  }

  _hitTest(point, options) {
    if (point.isInside(_getBounds())) {
      return new HitResult('pixel', this, {
        "offset": point.add(_size.divide(2)).round(),
        // Becomes HitResult#color
        "getColor": () {
          return getPixel(offset);
        }
      }
    }
  }

  void draw(ctx, param) {
    ctx.drawImage(_canvas || _image,
        -_size.width / 2, -_size.height / 2);
  }

  void drawSelected(ctx, matrix) {
    Item.drawSelectedBounds(new Rectangle(_size).setCenter(0, 0), ctx,
        matrix);
  }
}
