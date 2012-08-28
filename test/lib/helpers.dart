part of paper.dart.test;

// TODO I am just porting these as the other test files that I'm porting use them

// Override equals to convert functions to message and execute them as tests()
/*function equals(actual, expected, message) {
  if (typeof actual === 'function') {
    if (!message) {
      message = actual.toString().match(
        /^\s*function[^\{]*\{([\s\S]*)\}\s*$/)[1]
          .replace(/    /g, '')
          .replace(/^\s+|\s+$/g, '');
      if (/^return /.test(message)) {
        message = message
          .replace(/^return /, '')
          .replace(/;$/, '');
      }
    }
    actual = actual();
  }
  // Let's be strict
  return strictEqual(actual, expected, message);
}*/

/*function test(testName, expected) {
  return QUnit.test(testName, function() {
    var project = new Project();
    expected();
    project.remove();
  });
}*/

compareNumbers(num number1, num number2, [String message]) {
  if (number1 !== 0)
    number1 = (number1 * 100).round() / 100;
  if (number2 !== 0)
    number2 = (number2 * 100).round() / 100;
  expect(number1, equals(number2), message);
}

comparePoints(point1, point2, message) {
  compareNumbers(point1.x, point2.x,
      "$message x");
  compareNumbers(point1.y, point2.y,
      "$message y");
}

compareRectangles(rect1, rect2, message) {
  compareNumbers(rect1.x, rect2.x,
      "$message x");
  compareNumbers(rect1.y, rect2.y,
      "$message y");
  compareNumbers(rect1.width, rect2.width,
      "$message width");
  compareNumbers(rect1.height, rect2.height,
      "$message height");
}

compareRgbColors(/*Color*/ color1, /*Color*/ color2, [String message]) {
  color1 = new RgbColor(color1);
  color2 = new RgbColor(color2);

  compareNumbers(color1.red, color2.red, 
      '$message red');
  compareNumbers(color1.green, color2.green,
      '$message green');
  compareNumbers(color1.blue, color2.blue,
      '$message blue');
  compareNumbers(color1.alpha, color2.alpha,
      '$message alpha');
}

compareHsbColors(/*Color*/ color1, /*Color*/ color2, [message = ""]) {
  color1 = new HsbColor(color1);
  color2 = new HsbColor(color2);

  compareNumbers(color1.hue, color2.hue,
      '$message hue');
  compareNumbers(color1.saturation, color2.saturation,
      '$message saturation');
  compareNumbers(color1.brightness, color2.brightness,
      '$message brightness');
  compareNumbers(color1.alpha, color2.alpha,
      '$message alpha');
}

compareGrayColors(color1, color2, [message = ""]) {
  color1 = new GrayColor(color1);
  color2 = new GrayColor(color2);

  compareNumbers(color1.gray, color2.gray,
      '$message gray');
}

compareGradientColors(gradientColor, gradientColor2, checkIdentity) {
  for(var key in ['origin', 'destination', 'hilite']) {
    if (checkIdentity) {
      expect(gradientColor[key] != gradientColor2[key], true,
        'Strict compare GradientColor#$key');
    }
    equals(gradientColor[key].toString(), gradientColor2[key].toString(),
      'Compare GradientColor#$key');
  };
  expect(gradientColor.gradient.equals(gradientColor2.gradient), true);
}

comparePathStyles(style, style2, checkIdentity) {
  if (checkIdentity) {
    expect(style != style2, true);
  }
  for(var key in ['fillColor', 'strokeColor']) {
    if (style[key]) {
      // The color should not point to the same color object:
      if (checkIdentity) {
        expect(style[key] !== style2[key], true,
          'The $key should not point to the same color object:');
      }
      if (style[key] is GradientColor) {
        if (checkIdentity) {
          expect(style[key].gradient == style2[key].gradient, true,
            'The $key .gradient should point to the same object:');
        }
        compareGradientColors(style[key], style2[key], checkIdentity);
      } else {
        expect(style[key].toString(), style2[key].toString(),
            'Compare PathStyle#$key');
      }
    }
  };

  for(var key in ['strokeCap', 'strokeJoin', 'dashOffset', 'miterLimit',
      'strokeOverprint', 'fillOverprint']) {
    if (style[key]) {
      expect(style[key] == style2[key], true, 'Compare PathStyle#$key');
    }
  };

  if (style.dashArray) {
    equals(style.dashArray.toString(), style2.dashArray.toString(),
      'Compare CharacterStyle#dashArray');
  }
}

// TODO this is not going to work in dart
compareObjects(name, keys, obj, obj2, checkIdentity) {
  if (checkIdentity) {
    expect(obj != obj2, true);
  }
  for(var key in keys) {
    equals(obj[key], obj2[key], 'Compare $name#$key');
  };
}

compareCharacterStyles(characterStyle, characterStyle2, checkIdentity) {
  compareObjects('CharacterStyle', ['fontSize', 'font'],
      characterStyle, characterStyle2, checkIdentity);
}

compareParagraphStyles(paragraphStyle, paragraphStyle2, checkIdentity) {
  compareObjects('ParagraphStyle', ['justification'],
      paragraphStyle, paragraphStyle2, checkIdentity);
}

compareSegmentPoints(segmentPoint, segmentPoint2, checkIdentity) {
  compareObjects('SegmentPoint', ['x', 'y', 'selected'],
      segmentPoint, segmentPoint2, checkIdentity);
}

compareSegments(segment, segment2, checkIdentity) {
  if (checkIdentity) {
    expect(segment !== segment2, true);
  }
  expect(segment.selected == segment2.selected, true);
  for(var key in ['handleIn', 'handleOut', 'point']) {
    compareSegmentPoints(segment[key], segment2[key]);
  }
}

compareSegmentLists(segmentList, segmentList2, checkIdentity) {
  if (checkIdentity) {
    expect(segmentList !== segmentList2, true);
  }
  expect(segmentList.toString(), segmentList2.toString(),
      'Compare Item#segments');
  if (checkIdentity) {
    for (var i = 0, l = segmentList.length; i < l; i++) {
      var segment = segmentList[i],
        segment2 = segmentList2[i];
      compareSegments(segment, segment2, checkIdentity);
    }
  }
}

compareItems(item, item2, checkIdentity) {
  if (checkIdentity) {
    expect(item != item2, true);

    expect(item.id != item2.id, true);
  }

  expect(item.constructor == item2.constructor, true);

  var itemProperties = ['opacity', 'locked', 'visible', 'blendMode', 'name',
       'selected', 'clipMask'];
  for(var key in itemProperties) {
    expect(item[key], item2[key], 'compare Item#' + key);
  }

  if (checkIdentity) {
    expect(item.bounds != item2.bounds, true);
  }

  expect(item.bounds.toString(), item2.bounds.toString(),
      'Compare Item#bounds');

  if (checkIdentity) {
    expect(item.position != item2.position, true);
  }

  expect(item.position.toString(), item2.position.toString(),
      'Compare Item#position');

  if (item.matrix != null) {
    if (checkIdentity) {
      expect(item.matrix != item2.matrix, true);
    }
    expect(item.matrix.toString(), item2.matrix.toString(),
        'Compare Item#matrix');
  }

  // Path specific
  if (item2 is Path) {
    var keys = ['closed', 'fullySelected', 'clockwise', 'length'];
    for(var key in keys) {
      equals(item[key], item2[key], 'Compare Path#' + key);
    }
    compareSegmentLists(item.segments, item2.segments, checkIdentity);
  }

  // Group specific
  if (item is Group) {
    expect(item.clipped == item2.clipped, true);
  }

  // Layer specific
  if (item is Layer) {
    expect(item.project == item2.project, true);
  }

  // PlacedSymbol specific
  if (item is PlacedSymbol) {
    expect(item.symbol == item2.symbol, true);
  }

  // Raster specific
  if (item is Raster) {
    // TODO: remove access of private fields:
    if (item._canvas != null) {
      if (checkIdentity) {
        expect(item._canvas != item2._canvas, true);
      }
    }
    if (item._image != null) {
      expect(item._image == item2._image, true);
    }
    expect(item._size.toString(), item2._size.toString(),
        'Compare Item#size');
  }

  // TextItem specific:
  if (item is TextItem) {
    expect(item.content, item2.content, 'Compare Item#content');
    compareCharacterStyles(item.characterStyle, item2.characterStyle,
        checkIdentity);
  }

  // PointText specific:
  if (item is PointText) {
    if (checkIdentity) {
      expect(item.point != item2.point, true);
    }
    expect(item.point.toString(), item2.point.toString(),
        'Compare Item#point');
  }

  if (item.style != null) {
    // Path Style
    comparePathStyles(item.style, item2.style, checkIdentity);
  }

  // Check length of children and recursively compare them:
  if (item.children != null) {
    expect(item.children.length == item2.children.length, true);
    for (var i = 0, l = item.children.length; i < l; i++) {
      compareItems(item.children[i], item2.children[i], checkIdentity);
    }
  }
}
