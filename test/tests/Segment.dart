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

SegmentTests() {
  group("Segment Tests", () {
    test('new Segment(point)', () {
      var segment = new Segment(new Point(10, 10));
      equals(segment.toString(), '{ point: { x: 10, y: 10 } }');
    });
    
    test('new Segment(x, y)', () {
      var segment = new Segment(10, 10);
      equals(segment.toString(), '{ point: { x: 10, y: 10 } }');
    });
    
    test('new Segment(object)', () {
      var segment = new Segment({ "point": { "x": 10, "y": 10 }, "handleIn": { "x": 5, "y": 5 }, "handleOut": { "x": 15, "y": 15 } });
      equals(segment.toString(), '{ point: { x: 10, y: 10 }, handleIn: { x: 5, y: 5 }, handleOut: { x: 15, y: 15 } }');
    });
    
    test('new Segment(point, handleIn, handleOut)', () {
      var segment = new Segment(new Point(10, 10), new Point(5, 5), new Point(15, 15));
      equals(segment.toString(), '{ point: { x: 10, y: 10 }, handleIn: { x: 5, y: 5 }, handleOut: { x: 15, y: 15 } }');
    });
    
    test('new Segment(x, y, inX, inY, outX, outY)', () {
      var segment = new Segment(10, 10, 5, 5, 15, 15);
      equals(segment.toString(), '{ point: { x: 10, y: 10 }, handleIn: { x: 5, y: 5 }, handleOut: { x: 15, y: 15 } }');
    });
    
    test('new Segment(size)', () {
      var segment = new Segment(new Size(10, 10));
      equals(segment.toString(), '{ point: { x: 10, y: 10 } }');
    });
    
    test('segment.reverse()', () {
      var segment = new Segment(new Point(10, 10), new Point(5, 5), new Point(15, 15));
      segment = segment.reverse();
      equals(segment.toString(), '{ point: { x: 10, y: 10 }, handleIn: { x: 15, y: 15 }, handleOut: { x: 5, y: 5 } }');
    });
    
    test('segment.clone()', () {
      var segment = new Segment(new Point(10, 10), new Point(5, 5), new Point(15, 15));
      var clone = segment.clone();
      equals(() {
        return segment == clone;
      }, false);
    
      equals(() {
        return segment.toString();
      }, clone.toString());
    });
    
    test('segment.remove()', () {
      var path = new Path([10, 10], [5, 5], [10, 10]);
      path.segments[1].remove();
      equals(path.segments.toString(), '{ point: { x: 10, y: 10 } },{ point: { x: 10, y: 10 } }');
    });
    
    test('segment.selected', () {
      var path = new Path([10, 20], [50, 100]);
      path.segments[0].point.selected = true;
      equals(() {
        return path.segments[0].point.selected;
      }, true);
      path.segments[0].point.selected = false;
      equals(() {
        return path.segments[0].point.selected;
      }, false);});
  });
}