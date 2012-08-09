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

void LineTests() {
  group('Line Tests', () {
    test('new Line(new Point(10,10), [20,40], true)', () {
      var line = new Line(new Point(10,10), [20, 40], true);
      expect(line.point.toString(), '{ x: 10, y: 10 }', ' get point');
      expect(line.vector.toString(), '{ x: 10, y: 30 }', ' get vector');
    });

    test('new Line([10,10], [20, 20]).intersect(new Line([14, 15], [21, 10]))', () {
      Point intersection = new Line([10, 10], [20, 20]).intersect(new Line([14, 15], [21, 10]));
      expect(intersection.toString(), '{ x: 15.90909, y: 15.90909 }');
    });

    test('new Line([10, 10], [20, 20]).getSide(new Point(15, 15))', () {
      num side = new Line([10, 10], [20, 20]).getSide(new Point(15, 15));
      expect(side, 0);
    });

    test('new Line([10,10], [20, 20]).getDistance(new Point(64, 21))', () {
      num dist = new Line([10,10], [20, 20]).getDistance(new Point(64, 21));
      expect(dist, 30.40559159102154);
    });
  });
}