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

void RectangleTests() {
  group('Rectangle Tests', () {
    test('new Rectangle(new Point(10, 20), new Size(30, 40));', () {
      var rect = new Rectangle(new Point(10, 20), new Size(30, 40));
      expect(rect.toString(), equals('{ x: 10, y: 20, width: 30, height: 40 }'));
    });

    test('new Rectangle([10, 20], [30, 40]);', () {
      var rect = new Rectangle([10, 20], [30, 40]);
      expect(rect.toString(), equals('{ x: 10, y: 20, width: 30, height: 40 }'));
    });

    test('new Rectangle(new Point(10, 20), new Point(30, 40));', () {
      var rect = new Rectangle(new Point(10, 20), new Point(30, 40));
      expect(rect.toString(), equals('{ x: 10, y: 20, width: 20, height: 20 }'));
    });

    test('new Rectangle(10, 20, 30, 40);', () {
      var rect = new Rectangle(10, 20, 30, 40);
      expect(rect.toString(), equals('{ x: 10, y: 20, width: 30, height: 40 }'));
    });

    test('new Rectangle({x: 10, y: 20, width: 30, height: 40});', () {
      var rect = new Rectangle({ "x":10, "y":20, "width":30, "height":40});
      expect(rect.toString(), equals('{ x: 10, y: 20, width: 30, height: 40 }'));
    });

    test('get size', () {
      var rect = new Rectangle(10, 10, 20, 30);
      expect(rect.size.equals([20, 30]));
    });

    test('set size', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.size = new Size(30, 30);
      expect(rect.toString(), equals('{ x: 10, y: 10, width: 30, height: 30 }'));
    });

    test('topLeft', () {
      var rect = new Rectangle(10, 10, 20, 20);
      var point = rect.topLeft;
      expect(point.toString(), equals('{ x: 10, y: 10 }'));
    });

    test('set topLeft', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.topLeft = [10, 15];
      var point = rect.topLeft;
      expect(point.toString(), equals('{ x: 10, y: 15 }'));
    });

    test('get topRight', () {
      var rect = new Rectangle(10, 10, 20, 20);
      var point = rect.topRight;
      expect(point.toString(), equals('{ x: 30, y: 10 }'));
    });

    test('set topRight', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.topRight = [10, 15];
      var point = rect.topRight;
      expect(point.toString(), equals('{ x: 10, y: 15 }'));
    });

    test('get bottomLeft', () {
      var rect = new Rectangle(10, 10, 20, 20);
      var point = rect.bottomLeft;
      expect(point.toString(), equals('{ x: 10, y: 30 }'));
    });

    test('set bottomLeft', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.bottomLeft = [10, 15];
      var point = rect.bottomLeft;
      expect(point.toString(), equals('{ x: 10, y: 15 }'));
    });

    test('get bottomRight', () {
      var rect = new Rectangle(10, 10, 20, 20);
      var point = rect.bottomRight;
      expect(point.toString(), equals('{ x: 30, y: 30 }'));
    });

    test('set bottomRight', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.bottomRight = [10, 15];
      var point = rect.bottomRight;
      expect(point.toString(), equals('{ x: 10, y: 15 }'));
    });

    test('get bottomCenter', () {
      var rect = new Rectangle(10, 10, 20, 20);
      var point = rect.bottomCenter;
      expect(point.toString(), equals('{ x: 20, y: 30 }'));
    });

    test('set bottomCenter', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.bottomCenter = [10, 15];
      var point = rect.bottomCenter;
      expect(point.toString(), equals('{ x: 10, y: 15 }'));
    });

    test('get topCenter', () {
      var rect = new Rectangle(10, 10, 20, 20);
      var point = rect.topCenter;
      expect(point.toString(), equals('{ x: 20, y: 10 }'));
    });

    test('set topCenter', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.topCenter = [10, 15];
      var point = rect.topCenter;
      expect(point.toString(), equals('{ x: 10, y: 15 }'));
    });

    test('get leftCenter', () {
      var rect = new Rectangle(10, 10, 20, 20);
      var point = rect.leftCenter;
      expect(point.toString(), equals('{ x: 10, y: 20 }'));
    });

    test('set leftCenter', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.leftCenter = [10, 15];
      var point = rect.leftCenter;
      expect(point.toString(), equals('{ x: 10, y: 15 }'));
    });

    test('get rightCenter', () {
      var rect = new Rectangle(10, 10, 20, 20);
      var point = rect.rightCenter;
      expect(point.toString(), equals('{ x: 30, y: 20 }'));
    });

    test('set rightCenter', () {
      var rect = new Rectangle(10, 10, 20, 20);
      rect.rightCenter = [10, 15];
      var point = rect.rightCenter;
      expect(point.toString(), equals('{ x: 10, y: 15 }'));
    });

    test('intersects(rect)', () {
      var rect1 = new Rectangle({ "x":160, "y":270, "width":20, "height":20 });
      var rect2 = { "x":195, "y":301, "width":19, "height":19 };
      expect(!rect1.intersects(rect2));
      rect1 = new Rectangle({ "x":160, "y":270, "width":20, "height":20 });
      rect2 = { "x":170.5, "y":280.5, "width":19, "height":19 };
      expect(rect1.intersects(rect2));
    });

    test('contains(rect)', () {
      var rect1 = new Rectangle({ "x":160, "y":270, "width":20, "height":20 });
      var rect2 = { "x":195, "y":301, "width":19, "height":19 };
      expect(!rect1.contains(rect2));
      rect1 = new Rectangle({ "x":160, "y":270, "width":20, "height":20 });
      rect2 = new Rectangle({ "x":170.5, "y":280.5, "width":19, "height":19 });
      expect(!rect1.contains(rect2));

      rect1 = new Rectangle({ "x":299, "y":161, "width":137, "height":129 });
      rect2 = new Rectangle({ "x":340, "y":197, "width":61, "height":61 });
      expect(rect1.contains(rect2));
      expect(!rect2.contains(rect1));
    });

    test('contains(point)', () {
      var rect = new Rectangle({ "x":160, "y":270, "width":20, "height":20 });
      var point = new Point(166, 280);
      expect(rect.contains(point));
      point = new Point(30, 30);
      expect(!rect.contains(point));
    });

    test('intersect(rect)', () {
      var rect1 = new Rectangle({ "x":160, "y":270, "width":20, "height":20 });
      var rect2 = { "x":170.5, "y":280.5, "width":19, "height":19 };
      var intersected = rect1.intersect(rect2);
      expect(intersected.equals({ "x":170.5, "y":280.5, "width":9.5, "height":9.5 }));
    });

    test('unite(rect)', () {
      var rect1 = new Rectangle({ "x":160, "y":270, "width":20, "height":20 });
      var rect2 = { "x":170.5, "y":280.5, "width":19, "height":19 };
      var united = rect1.unite(rect2);
      expect(united.equals({ "x":160, "y":270, "width":29.5, "height":29.5 }));
    });

    test('include(point)', () {
      var rect1 = new Rectangle({ "x":95, "y":151, "width":20, "height":20 });
      var included = rect1.include([50, 50]);
      expect(included.equals({ "x":50, "y":50, "width":65, "height":121 }));
    });

    test('toString()', () {
      var string = new Rectangle(10, 20, 30, 40).toString();
      expect(string, equals('{ x: 10, y: 20, width: 30, height: 40 }'));
    });
  });
}