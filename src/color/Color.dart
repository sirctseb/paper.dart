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
#library("Color.dart");
#import("../basic/Basic.dart");
#import("../core/Base.dart");
#import("../util/CanvasProvider.dart");
#import("dart:core");
#source("GradientStop.dart");

/**
 * @name Color
 *
 * @class All properties and functions that expect color values accept
 * instances of the different color classes such as {@link RgbColor},
 * {@link HsbColor} and {@link GrayColor}, and also accept named colors
 * and hex values as strings which are then converted to instances of
 * {@link RgbColor} internally.
 *
 * @classexample {@paperscript}
 * // Named color values:
 *
 * // Create a circle shaped path at {x: 80, y: 50}
 * // with a radius of 30.
 * var circle = new Path.Circle(new Point(80, 50), 30);
 *
 * // Pass a color name to the fillColor property, which is internally
 * // converted to an RgbColor.
 * circle.fillColor = 'green';
 *
 * @classexample {@paperscript}
 * // Hex color values:
 *
 * // Create a circle shaped path at {x: 80, y: 50}
 * // with a radius of 30.
 * var circle = new Path.Circle(new Point(80, 50), 30);
 *
 * // Pass a hex string to the fillColor property, which is internally
 * // converted to an RgbColor.
 * circle.fillColor = '#ff0000';
 */
class Color {
  
  // color components
  Map<String, num> _components;

  // gray components
  num get _gray() => _components["gray"];
  set _gray(num value) => _components["gray"] = value;
  
  // Rgb components
  //num _red, _green, _blue;
  num get _red() => _components["red"];
  set _red(num value) => _components["red"] = value;
  num get _green() => _components["green"];
  set _green(num value) => _components["green"] = value;
  num get _blue() => _components["blue"];
  set _blue(num value) => _components["blue"] = value;

  // hsb components
  //num _hue, _saturation, _brightness;
  num get _hue() => _components["hue"];
  set _hue(num value) => _components["hue"] = value;
  num get _saturation() => _components["saturation"];
  set _saturation(num value) => _components["saturation"] = value;
  num get _brightness() => _components["brightness"];
  set _brightness(num value) => _components["brightness"] = value;

  // hsl components
  //num _lightness;
  num get _lightness() => _components["lightness"];
  set _lightness(num value) => _components["lightness"] = value;

  // remembers which components are currently definitive
  String _type;

  // Items that use this color object for styling
  List _owners;

  num _alpha;
  
  String _cssString;

  // accessors
  // helper functions for validating input
  num _clampUnit(num input) {
    return Math.max(0, Math.min(1, input));
  }
  num _modDegrees(num input) {
    return ((input % 360) + 360) % 360;
  }

  setValue(String component, String type, num value, [bool isHue = false]) {
    if(value != _components[component]) {
      // if the current color type has the component we're setting,
      // we can simply set the value
      if(components[_type].indexOf(component) != -1) {
        _components[component] = isHue ? _modDegrees(value) : _clampUnit(value);
        // set other properties, which may have been computed and stored, to null
        for(String other_comp in other_components[_type]) {
          _components[component] = null;
        }
      } else {
        Color color = convert(type);
        color._components[component] = value;
        setComponents(color.convert(_type));
      }
      _cssString = null;
      _changed();
    }
  }
  
  // Gray accessors
  num get gray() {
    // if we don't have gray ready, compute it
    if(_gray == null) {
      GrayColor color = this.convert("gray");
      _gray = color.gray;
    }
    return _gray;
  }
  set gray(num value) {
    setValue("gray", "gray", value);
  }

  // helper function to set rgb values from whatever the color currently is
  void _updateRgb() {
      Color color = this.convert("rgb");
      _red = color.red;
      _blue = color.blue;
      _green = color.green;
  }
  // Rgb accessors
  num get red() {
    if(_red == null) {
      _updateRgb();
    }
    return _red;
  }
  set red(num value) {
    setValue("red", "rgb", value);
  }
  num get blue() {
    if(_blue == null) {
      _updateRgb();
    }
    return _blue;
  }
  set blue(num value) {
    setValue("blue", "rgb", value);
  }

  num get green() {
    if(_green == null) {
      _updateRgb();
    }
    return _green;
  }
  set green(num value) {
    setValue("green", "rgb", value);
  }

  // helper function to set hsb values from whatever the color currently is
  void _updateHsb() {
    HsbColor color = this.convert("hsb");
    _hue = color.hue;
    _saturation = color.saturation;
    _brightness = color.brightness;
  }

  // hsb accessors
  num get hue() {
    if(_hue == null) {
      _updateHsb();
    }
    return _hue;
  }
  set hue(num value) {
    setValue("hue", "hsb", value, true);
  }

  num get saturation() {
    if(_saturation == null) {
      _updateHsb();
    }
    return _saturation;
  }
  set saturation(num value) {
    setValue("saturation", _type == "hsl" ? "hsl" : "hsb", value);
  }

  num get brightness() {
    if(_brightness == null) {
      _updateHsb();
    }
    return _brightness;
  }
  set brightness(num value) {
    setValue("brightness", "hsb", value);
  }

  // helper function to set hsl values from whatever color currently is
  void _updateHsl() {
    HslColor color = this.convert("hsl");
    _hue = color.hue;
    _saturation = color.saturation;
    _lightness = color.lightness;
  }
  // hsl accessors
  num get lightness() {
    if(_lightness == null) {
      _updateHsl();
      return _lightness;
    }
  }
  set lightness(num value) {
    setValue("lightness", "hsl", value);
  }

  // alpha accessors
  num get alpha() => _alpha == null ? 1 : _alpha;
  set alpha(num value) {
    _alpha = value == null ? null : _clampUnit(value);
    _cssString = null;
    _changed();
  }
  // TODO why do we need this if we return a valid value always?
  bool hasAlpha() => _alpha != null;
  
  void setComponents(Color color) {
    _gray = color._gray;
    _red = color._red;
    _green = color._green;
    _blue = color._blue;
    _hue = color._hue;
    _saturation = color._saturation;
    _brightness = color._brightness;
    _lightness = color._lightness;
  }


  static var components = const {
    "gray": const ['gray'],
    "rgb": const ['red', 'green', 'blue'],
    "hsb": const ['hue', 'saturation', 'brightness'],
    "hsl": const ['hue', 'saturation', 'lightness']
  };
  static var other_components = const {
    "gray": const ['red', 'green', 'blue', 'hue', 'saturation', 'brightness', 'lightness'],
    "rgb": const ['gray', 'hue', 'saturation', 'brightness', 'lightness'],
    "hsb": const ['gray', 'red', 'green', 'blue', 'lightness'],
    "hsl": const ['gray', 'red', 'green', 'blue', 'brightness']
  };

  static var colorCache;
  static var colorContext;

  static _nameToRgbColor(String name) {
    if(colorCache == null) colorCache = {};
    var color = colorCache[name];
    if (color != null)
      return color.clone();
    // Use a canvas to draw to with the given name and then retrieve rgb
    // values from. Build a cache for all the used colors.
    // TODO woah! this should be interesting
    if (colorContext == null) {
      var canvas = CanvasProvider.getCanvas(new Size.create(1, 1));
      colorContext = canvas.getContext('2d');
      colorContext.globalCompositeOperation = 'copy';
    }
    // Set the current fillStyle to transparent, so that it will be
    // transparent instead of the previously set color in case the new color
    // can not be interpreted.
    colorContext.fillStyle = 'rgba(0,0,0,0)';
    // Set the fillStyle of the context to the passed name and fill the
    // canvas with it, then retrieve the data for the drawn pixel:
    colorContext.fillStyle = name;
    colorContext.fillRect(0, 0, 1, 1);
    var data = colorContext.getImageData(0, 0, 1, 1).data,
      rgb = [data[0] / 255, data[1] / 255, data[2] / 255];
    return (colorCache[name] = new RgbColor(rgb)).clone();
  }

  // TODO use Math.parseInt(..., 16) once they implement it
  static int parseHex(String hex) {
    int result = 0;
    for(int i = hex.length - 1; i >= 0; i--) {
      result += hex[i] == "a" ? 10 << i * 4 :
                hex[i] == "b" ? 11 << i * 4 :
                hex[i] == "c" ? 12 << i * 4 :
                hex[i] == "d" ? 13 << i * 4 :
                hex[i] == "e" ? 14 << i * 4 :
                hex[i] == "f" ? 15 << i * 4 :
                Math.parseInt(hex[i]) << i * 4;
    }
    return result;
  }
  static _hexToRgbColor(String string) {
    var hex = new RegExp(@"^#?(\w{1,2})(\w{1,2})(\w{1,2})$").firstMatch(string);
    if (hex.groupCount() >= 3) {
      var rgb = new List(3);
      for (var i = 0; i < 3; i++) {
        var channel = hex[i + 1];
        rgb[i] = parseHex(channel.length == 1
                ? "$channel$channel" : "$channel") / 255;
        //rgb[i] = Math.parseInt(channel.length == 1
        //    ? "$channel$channel" : "$channel", 16) / 255;
      }
      return new RgbColor(rgb[0], rgb[1], rgb[2]);
    }
  }

  // For hsb-rgb conversion, used to lookup the right parameters in the
  // values array.
  static var _hsbIndices = const [
    const [0, 3, 1], // 0
    const [2, 0, 1], // 1
    const [1, 0, 3], // 2
    const [1, 2, 0], // 3
    const [3, 1, 0], // 4
    const [0, 1, 2]  // 5
  ];

  static Map _converters;
  static _initconverters () {
    if(_converters == null)
      _converters = {
    'rgb-hsb': (color) {
      var r = color._red,
        g = color._green,
        b = color._blue,
        max = Math.max(r, Math.max(g, b)),
        min = Math.min(r, Math.max(g, b)),
        delta = max - min,
        h = delta == 0 ? 0
          :   ( max == r ? (g - b) / delta + (g < b ? 6 : 0)
            : max == g ? (b - r) / delta + 2
            :            (r - g) / delta + 4) * 60, // max == b
        s = max == 0 ? 0 : delta / max,
        v = max; // = brightness, also called value
      return new HsbColor(h, s, v, color._alpha);
    },

    'hsb-rgb': (color) {
      var h = (color._hue / 60) % 6; // Scale to 0..6
      var s = color._saturation;
      var b = color._brightness;
      var i = h.floor().toInt(); // 0..5
      var f = h - i;
      i = _hsbIndices[i];
      var v = [
          b,            // b, index 0
          b * (1 - s),      // p, index 1
          b * (1 - s * f),    // q, index 2
          b * (1 - s * (1 - f))  // t, index 3
        ];
      return new RgbColor(v[i[0]], v[i[1]], v[i[2]], color._alpha);
    },

    // HSL code is based on:
    // http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
    'rgb-hsl': (color) {
      var r = color._red,
        g = color._green,
        b = color._blue,
        max = Math.max(r, Math.max(g, b)),
        min = Math.min(r, Math.max(g, b)),
        delta = max - min,
        achromatic = delta == 0,
        h = achromatic ? 0
          :   ( max == r ? (g - b) / delta + (g < b ? 6 : 0)
            : max == g ? (b - r) / delta + 2
            :            (r - g) / delta + 4) * 60, // max == b
        l = (max + min) / 2,
        s = achromatic ? 0 : l < 0.5
            ? delta / (max + min)
            : delta / (2 - max - min);
      return new HslColor(h, s, l, color._alpha);
    },

    'hsl-rgb': (color) {
      var s = color._saturation,
        h = color._hue / 360,
        l = color._lightness,
        t1, t2, c;
      if (s == 0)
        return new RgbColor(l, l, l, color._alpha);
      var t3s = [ h + 1 / 3, h, h - 1 / 3 ];
        t2 = l < 0.5 ? l * (1 + s) : l + s - l * s;
        t1 = 2 * l - t2;
        c = [];
      for (var i = 0; i < 3; i++) {
        var t3 = t3s[i];
        if (t3 < 0) t3 += 1;
        if (t3 > 1) t3 -= 1;
        c[i] = 6 * t3 < 1
          ? t1 + (t2 - t1) * 6 * t3
          : 2 * t3 < 1
            ? t2
            : 3 * t3 < 2
              ? t1 + (t2 - t1) * ((2 / 3) - t3) * 6
              : t1;
      }
      return new RgbColor(c[0], c[1], c[2], color._alpha);
    },

    'rgb-gray': (color) {
      // Using the standard NTSC conversion formula that is used for
      // calculating the effective luminance of an RGB color:
      // http://www.mathworks.com/support/solutions/en/data/1-1ASCU/index.html?solution=1-1ASCU
      return new GrayColor(1 - (color._red * 0.2989 + color._green * 0.587
          + color._blue * 0.114), color._alpha);
    },

    'gray-rgb': (color) {
      var comp = 1 - color._gray;
      return new RgbColor(comp, comp, comp, color._alpha);
    },

    'gray-hsb': (color) {
      return new HsbColor(0, 0, 1 - color._gray, color._alpha);
    },

    'gray-hsl': (color) {
      return new HslColor(0, 0, 1 - color._gray, color._alpha);
    }
  };
  }

//  var fields = /** @lends Color# */{
  bool _readNull;

  //initialize: function(arg) {
  Color([arg, arg1, arg2, arg3]) {

    _components = new Map<String, num>();
    
    if (arg is Map) {
      // Called on the abstract Color class. Guess color type
      // from arg
      if(arg.containsKey("red")) {
        _red = arg["red"];
        _green = arg["green"];
        _blue = arg["blue"];
        _alpha = arg["alpha"];
        _type = "rgb";
      } else if(arg.containsKey("gray")) {
        _gray = arg["gray"];
        _alpha = arg["alpha"];
        _type = "gray";
      } else if(arg.containsKey("brightness")) {
        _hue = arg["hue"];
        _saturation = arg["saturation"];
        _brightness = arg["brightness"];
        _alpha = arg["alpha"];
        _type = "hsb";
      } else if(arg.containsKey("hue")) {
        _hue = arg["hue"];
        _saturation = arg["saturation"];
        _lightness = arg["lightness"];
        _alpha = arg["alpha"];
        _type = "hsl";
      } else {
        _red = _blue = _green = 0;
        _type = "rgb";
      }
    } else if (arg is String) {
      var rgbColor = new RegExp(@"^#[0-9a-f]{3,6}$", false, true).hasMatch(arg) ?
        _hexToRgbColor(arg) : _nameToRgbColor(arg);
      _red = rgbColor.red;
      _green = rgbColor.green;
      _blue = rgbColor.blue;
      _type = "rgb";
    } else if(arg == null) {
      _red = _blue = _green = 0;
      _type = "rgb";
    } else {
      // TODO support params to array
      var components = arg is List ? arg : [arg, arg1, arg2, arg3];
      // Called on the abstract Color class. Guess color type
      // from arg
      //if (components.length >= 4)
      //  return new CmykColor(components);
      if (components.length >= 2) {
        _red = components[0];
        _green = components[1];
        _blue = components[2];
        _alpha = components.length > 3 ? components[3] : null;
        _type = "rgb";
      } else {
        _gray = components[0];
        _alpha = components.length > 1 ? components[1] : null;
        _type = "gray";
      }
    }
  }

  /**
   * @return {RgbColor|GrayColor|HsbColor} a copy of the color object
   */
  Color clone() {
    Color copy = new Color();
    copy._gray = _gray;
    copy._red = _red;
    copy._green = _green;
    copy._blue = _blue;
    copy._hue = _hue;
    copy._saturation = _saturation;
    copy._brightness = _brightness;
    copy._lightness = _lightness;
    copy._alpha = _alpha;
    copy._type = _type;
    return copy;
  }

  Color convert(String type) {
    _initconverters();
    var converter;
    return _type == type
        ? this.clone()
        : (converter = _converters['${_type}-${type}']) != null
          ? converter(this)
          : _converters['rgb-$type'](
              _converters['${_type}-rgb'](this));
  }

  /**
   * Called by various setters whenever a color value changes
   */
  void _changed() {
    _cssString = null;
    // Loop through the items that use this color and notify them about
    // the style change, so they can redraw.
    if(_owners == null) _owners = [];
    for(var owner in _owners)
      owner._changed(Change.STYLE);
  }

  /**
   * Called by PathStyle whenever this color is used to define an item's style
   * This is required to pass on _changed() notifications to the _owners.
   */
   // TODO I think we will have to make this public
  void _addOwner(item) {
    if (this._owners == null)
      _owners = [];
    _owners.add(item);
  }

  /**
   * Called by PathStyle whenever this color stops being used to define an
   * item's style.
   * TODO: Should we remove owners that are not used anymore for good, e.g.
   * in an Item#destroy() method?
   */
  void _removeOwner(/*Item*/ item) {
    var index = _owners.indexOf(item);
    if(index != -1) _owners.removeRange(index, 1);
  }

  /**
   * Returns the type of the color as a string.
   *
   * @type String('rgb', 'hsb', 'gray')
   * @bean
   *
   * @example
   * var color = new RgbColor(1, 0, 0);
   * console.log(color.type); // 'rgb'
   */
  getType() {
    return this._type;
  }

  // TODO do we need this?
  /*getComponents: function() {
    var length = this._components.length;
    var comps = new Array(length);
    for (var i = 0; i < length; i++)
      comps[i] = this['_' + this._components[i]];
    return comps;
  },*/

  /**
   * The color's alpha value as a number between {@code 0} and {@code 1}. All
   * colors of the different subclasses support alpha values.
   *
   * @type Number
   * @bean
   *
   * @example {@paperscript}
   * // A filled path with a half transparent stroke:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // Fill the circle with red and give it a 20pt green stroke:
   * circle.style = {
   *   fillColor: 'red',
   *   strokeColor: 'green',
   *   strokeWidth: 20
   * };
   *
   * // Make the stroke half transparent:
   * circle.strokeColor.alpha = 0.5;
   */
  num getAlpha() {
    return alpha;
  }

  Color setAlpha(num alpha) {
    this.alpha = alpha;
    return this;
  }

  /**
   * Checks if the color has an alpha value.
   *
   * @return {Boolean} {@true if the color has an alpha value}
   */
  // TODO put implementation down here

  /**
   * Checks if the component color values of the color are the
   * same as those of the supplied one.
   *
   * @param {Color} color the color to compare with
   * @return {Boolean} {@true if the colors are the same}
   */
  bool equals(Color color) {
    // TODO why not consider them equal when they don't have the same type?
    // TODO we may cause problems with this when we change _type in setters
    if (color != null && color._type === this._type) {
      switch(_type) {
        case "gray": return _gray == color._gray;
        case "rgb" : return _red == color._red && _green == color._green && _blue == color._blue;
        case "hsb" : return _hue == color._hue && _saturation == color._saturation && _brightness == color._brightness;
        case "hsl" : return _hue == color._hue && _saturation == color._saturation && _lightness == color._lightness;
        default: return false;
      }
    }
    return false;
  }
  // operator version
  bool operator == (Color color) => equals(color);

  /**
   * {@grouptitle String Representations}
   * @return {String} A string representation of the color.
   */
  String toString() {
    var format = Base.formatNumber;
    String alpha_component = "${_alpha == null ? '' : ', alpha: $_alpha'}";
    switch(_type) {
      case "gray": return "{ gray: ${_gray}$alpha_component }";
      case "rgb": return "{ red: $_red, green: $_green, blue: $_blue$alpha_component }";
      case "hsb": return "{ hue: $_hue, saturation: $_saturation, brightness: $_brightness$alpha_component }";
      case "hsl": return "{ hue: $_hue, saturation: $_saturation, lightness: $_lightness$alpha_component }";
      default: return "";
    }
  }

  /**
   * @return {String} A css string representation of the color.
   */
  String toCssString() {
    if (_cssString == null) {
        _cssString = "rgba(${(red*255).round().toInt()}, ${(green*255).round().toInt()}, ${(blue*255).round().toInt()}, $alpha)";
    }
    return this._cssString;
  }

  String getCanvasStyle() {
    return this.toCssString();
  }

  /**
   * {@grouptitle RGB Components}
   *
   * The amount of red in the color as a value between {@code 0} and
   * {@code 1}.
   *
   * @name Color#red
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Changing the amount of red in a color:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   * circle.fillColor = 'blue';
   *
   * // Blue + red = purple:
   * circle.fillColor.red = 1;
   */

  /**
   * The amount of green in the color as a value between {@code 0} and
   * {@code 1}.
   *
   * @name Color#green
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Changing the amount of green in a color:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // First we set the fill color to red:
   * circle.fillColor = 'red';
   *
   * // Red + green = yellow:
   * circle.fillColor.green = 1;
   */

  /**
   * The amount of blue in the color as a value between {@code 0} and
   * {@code 1}.
   *
   * @name Color#blue
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Changing the amount of blue in a color:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // First we set the fill color to red:
   * circle.fillColor = 'red';
   *
   * // Red + blue = purple:
   * circle.fillColor.blue = 1;
   */

  /**
   * {@grouptitle Gray Components}
   *
   * The amount of gray in the color as a value between {@code 0} and
   * {@code 1}.
   *
   * @name Color#gray
   * @property
   * @type Number
   */

  /**
   * {@grouptitle HSB Components}
   *
   * The hue of the color as a value in degrees between {@code 0} and
   * {@code 360}.
   *
   * @name Color#hue
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Changing the hue of a color:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   * circle.fillColor = 'red';
   * circle.fillColor.hue += 30;
   *
   * @example {@paperscript}
   * // Hue cycling:
   *
   * // Create a rectangle shaped path, using the dimensions
   * // of the view:
   * var path = new Path.Rectangle(view.bounds);
   * path.fillColor = 'red';
   *
   * function onFrame(event) {
   *   path.fillColor.hue += 0.5;
   * }
   */

  /**
   * The saturation of the color as a value between {@code 0} and {@code 1}.
   *
   * @name Color#saturation
   * @property
   * @type Number
   */

  /**
   * The brightness of the color as a value between {@code 0} and {@code 1}.
   *
   * @name Color#brightness
   * @property
   * @type Number
   */

  /**
   * {@grouptitle HSL Components}
   *
   * The lightness of the color as a value between {@code 0} and {@code 1}.
   *
   * @name Color#lightness
   * @property
   * @type Number
   */
}

/**
 * @name GrayColor
 * @class A GrayColor object is used to represent any gray color value.
 * @extends Color
 */
class GrayColor extends Color {
  /**
   * Creates a GrayColor object
   *
   * @name GrayColor#initialize
   * @param {Number} gray the amount of gray in the color as a value
   * between {@code 0} and {@code 1}
   * @param {Number} [alpha] the alpha of the color as a value between
   * {@code 0} and {@code 1}
   *
   * @example {@paperscript}
   * // Creating a GrayColor:
   *
   * // Create a circle shaped path at {x: 80, y: 50}
   * // with a radius of 30:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // Create a GrayColor with 50% gray:
   * circle.fillColor = new GrayColor(0.5);
   */
  GrayColor(/*num*/ gray, [num alpha])
    : super(gray is num ? {"gray": gray, "alpha": alpha} :
            gray is Color ? null : gray) {
    if(gray is Color) {
      setComponents(gray.convert("gray"));
      _type = "gray";
    }
  }

  /**
   * The amount of gray in the color as a value between {@code 0} and
   * {@code 1}.
   *
   * @name GrayColor#gray
   * @property
   * @type Number
   */

}

/**
 * @name RgbColor
 * @class An RgbColor object is used to represent any RGB color value.
 * @extends Color
 */
// RGBColor references RgbColor inside PaperScopes for backward compatibility
// TODO how about this RGB stuff?
class RgbColor extends Color {
  /**
   * Creates an RgbColor object
   *
   * @name RgbColor#initialize
   * @param {Number} red the amount of red in the color as a value
   * between {@code 0} and {@code 1}
   * @param {Number} green the amount of green in the color as a value
   * between {@code 0} and {@code 1}
   * @param {Number} blue the amount of blue in the color as a value
   * between {@code 0} and {@code 1}
   * @param {Number} [alpha] the alpha of the color as a value between
   * {@code 0} and {@code 1}
   *
   * @example {@paperscript}
   * // Creating an RgbColor:
   *
   * // Create a circle shaped path at {x: 80, y: 50}
   * // with a radius of 30:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // 100% red, 0% blue, 50% blue:
   * circle.fillColor = new RgbColor(1, 0, 0.5);
   */
   RgbColor(/*num*/ red, [num green, num blue, num alpha])
    : super(red is num ? {"red": red, "green": green, "blue": blue, "alpha": alpha} :
            red is Color ? null : red) {
     if(red is Color) {
       setComponents(red.convert("rgb"));
       _type = "rgb";
     }
   }

  /**
   * The amount of red in the color as a value between {@code 0} and
   * {@code 1}.
   *
   * @name RgbColor#red
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Changing the amount of red in a color:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   * circle.fillColor = 'blue';
   *
   * // Blue + red = purple:
   * circle.fillColor.red = 1;
   */

  /**
   * The amount of green in the color as a value between {@code 0} and
   * {@code 1}.
   *
   * @name RgbColor#green
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Changing the amount of green in a color:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // First we set the fill color to red:
   * circle.fillColor = 'red';
   *
   * // Red + green = yellow:
   * circle.fillColor.green = 1;
   */

  /**
   * The amount of blue in the color as a value between {@code 0} and
   * {@code 1}.
   *
   * @name RgbColor#blue
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Changing the amount of blue in a color:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // First we set the fill color to red:
   * circle.fillColor = 'red';
   *
   * // Red + blue = purple:
   * circle.fillColor.blue = 1;
   */

}

/**
 * @name HsbColor
 * @class An HsbColor object is used to represent any HSB color value.
 * @extends Color
 */
// HSBColor references HsbColor inside PaperScopes for backward compatibility
// TODO how about this HSBColor stuff?
class HsbColor extends Color {
  /**
   * Creates an HsbColor object
   *
   * @name HsbColor#initialize
   * @param {Number} hue the hue of the color as a value in degrees between
   * {@code 0} and {@code 360}.
   * @param {Number} saturation the saturation of the color as a value
   * between {@code 0} and {@code 1}
   * @param {Number} brightness the brightness of the color as a value
   * between {@code 0} and {@code 1}
   * @param {Number} [alpha] the alpha of the color as a value between
   * {@code 0} and {@code 1}
   *
   * @example {@paperscript}
   * // Creating an HsbColor:
   *
   * // Create a circle shaped path at {x: 80, y: 50}
   * // with a radius of 30:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // Create an HsbColor with a hue of 90 degrees, a saturation
   * // 100% and a brightness of 100%:
   * circle.fillColor = new HsbColor(90, 1, 1);
   */
  HsbColor(/*num*/ hue, [num saturation, num brightness, num alpha])
    : super(hue is num ? {"hue": hue, "saturation": saturation, "brightness": brightness, "alpha": alpha} :
            hue is List ? {"hue": hue[0], "saturation": hue[1], "brightness": hue[2], "alpha": hue.length > 3 ? hue[3] : null} :
            hue is Color ? null : hue) {
    if(hue is Color) {
      setComponents(hue.convert("hsb"));
      _type = "hsb";
    }
  }

  /**
   * The hue of the color as a value in degrees between {@code 0} and
   * {@code 360}.
   *
   * @name HsbColor#hue
   * @property
   * @type Number
   *
   * @example {@paperscript}
   * // Changing the hue of a color:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   * circle.fillColor = 'red';
   * circle.fillColor.hue += 30;
   *
   * @example {@paperscript}
   * // Hue cycling:
   *
   * // Create a rectangle shaped path, using the dimensions
   * // of the view:
   * var path = new Path.Rectangle(view.bounds);
   * path.fillColor = 'red';
   *
   * function onFrame(event) {
   *   path.fillColor.hue += 0.5;
   * }
   */

  /**
   * The saturation of the color as a value between {@code 0} and {@code 1}.
   *
   * @name HsbColor#saturation
   * @property
   * @type Number
   */

  /**
   * The brightness of the color as a value between {@code 0} and {@code 1}.
   *
   * @name HsbColor#brightness
   * @property
   * @type Number
   */

}


/**
 * @name HslColor
 * @class An HslColor object is used to represent any HSL color value.
 * @extends Color
 */
// HSLColor references HslColor inside PaperScopes for backward compatibility
// TODO how about this HSLColor stuff
class HslColor extends Color {
  /**
   * Creates an HslColor object
   *
   * @name HslColor#initialize
   * @param {Number} hue the hue of the color as a value in degrees between
   * {@code 0} and {@code 360}.
   * @param {Number} saturation the saturation of the color as a value
   * between {@code 0} and {@code 1}
   * @param {Number} lightness the lightness of the color as a value
   * between {@code 0} and {@code 1}
   * @param {Number} [alpha] the alpha of the color as a value between
   * {@code 0} and {@code 1}
   *
   * @example {@paperscript}
   * // Creating an HslColor:
   *
   * // Create a circle shaped path at {x: 80, y: 50}
   * // with a radius of 30:
   * var circle = new Path.Circle(new Point(80, 50), 30);
   *
   * // Create an HslColor with a hue of 90 degrees, a saturation
   * // 100% and a lightness of 50%:
   * circle.fillColor = new HslColor(90, 1, 0.5);
   */
  HslColor(/*num*/ hue, [num saturation, num lightness, num alpha])
    : super(hue is num ? {"hue": hue, "saturation": saturation, "lightness": lightness, "alpha": alpha} :
            hue is List ? {"hue": hue[0], "saturation": hue[1], "lightness": hue[2], "alpha": hue.length > 3 ? hue[3] : null} :
            hue is Color ? null : hue) {
    if(hue is Color) {
      setComponents(hue.convert("hsl"));
      _type = "hsl";
    }
  }

  /**
   * The hue of the color as a value in degrees between {@code 0} and
   * {@code 360}.
   *
   * @name HslColor#hue
   * @property
   * @type Number
   */

  /**
   * The saturation of the color as a value between {@code 0} and {@code 1}.
   *
   * @name HslColor#saturation
   * @property
   * @type Number
   */

  /**
   * The lightness of the color as a value between {@code 0} and {@code 1}.
   *
   * @name HslColor#lightness
   * @property
   * @type Number
   */

}