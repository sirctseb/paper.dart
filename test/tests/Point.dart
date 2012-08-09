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

 void PointTests() {
  group('Point Tests', () {
    test('new Point(10, 20)', () {
      var point = new Point(10, 20);
      expect(point.toString(), equals('{ x: 10, y: 20 }'));
      });

    test('new Point.fromList([10, 20])', () {
      var point = new Point([10, 20]);
      expect(point.toString(), equals('{ x: 10, y: 20 }'));
      });

    test('new Point.fromMap({x: 10, y: 20})', () {
      var point = new Point({"x": 10, "y": 20});
      expect(point.toString(), equals('{ x: 10, y: 20 }'));
      });

    test('new Point(new Size(10, 20))', () {
      var point = new Size(10, 20));
      expect(point.toString(), equals('{ x: 10, y: 20 }'));
      });

    test('new Point.fromMap({ width: 10, height: 20})', () {
      var point = new Point({"width": 10, "height": 20});
      expect(point.toString(), equals('{ x: 10, y: 20 }'));
      });

    test('new Point.fromMap({ angle: 45, length: 20})', () {
      var point = new Point.fromMap({"angle": 40, "length": 20});
      expect(point.toString(), equals('{ x: 15.32089, y: 12.85575 }'));
      });

    // TODO make another group?
    //module('Point vector operations');

    test('normalize(length)', () {
      // TODO fix and submit pull request on paper.js for missing semicolon
      var point = new Point(0, 10).normalize(20);
      expect(point.toString(), equals('{ x: 0, y: 20 }'));
      });

    test('set length', () {
      var point = new Point(0, 10);
      point.length = 20;
      expect(point.toString(), equals('{ x: 0, y: 20 }'));
      });

    test('get angle', () {
      var angle = new Point(0, 10).angle;
      expect(angle, equals(90));
      });

    test('getAngle(point)', () {
      var angle = new Point(0, 10).getAngle([10, 10]);
      expect(angle.round(), equals(45));
      });

    test('rotate(degrees)', () {
      var point = new Point(100, 50).rotate(90);
      expect(point.toString(), equals('{ x: -50, y: 100 }'));
      });

    test('set angle', () {
      var point = new Point(10, 20);
      point.angle = 92;
      expect(point.angle, equals(92));
      });

    test('getDirectedAngle(point)', () {
      var angle = new Point(10, 10).getDirectedAngle(new Point(1, 0));
      expect(angle, equals(-45));

      angle = new Point(-10, 10).getDirectedAngle(new Point(1, 0));
      expect(angle, equals(-135));

      angle = new Point(-10, -10).getDirectedAngle(new Point(1, 0));
      expect(angle, equals(135));

      angle = new Point(10, -10).getDirectedAngle(new Point(1, 0));
      expect(angle, equals(45));
      });
    });
    // TODO submit for this semicolon also
}