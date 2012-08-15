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

PathTests() {
  group("Path Tests", () {
    test('path.join(path)', () {
      var path = new Path();
      path.add(0, 0);
      path.add(10, 0);

      var path2 = new Path();
      path2.add(10, 0);
      path2.add(20, 10);

      path.join(path2);
      expect(path.segments.toString(), '{ point: { x: 0, y: 0 } },{ point: { x: 10, y: 0 } },{ point: { x: 20, y: 10 } }');
      expect(paper.project.activeLayer.children.length, 1);

      var path = new Path();
      path.add(0, 0);
      path.add(10, 0);

      var path2 = new Path();
      path2.add(20, 10);
      path2.add(10, 0);
      path.join(path2);
      expect(path.segments.toString(), '{ point: { x: 0, y: 0 } },{ point: { x: 10, y: 0 } },{ point: { x: 20, y: 10 } }');

      var path = new Path();
      path.add(0, 0);
      path.add(10, 0);

      var path2 = new Path();
      path2.add(30, 10);
      path2.add(40, 0);
      path.join(path2);
      expect(path.segments.toString(), '{ point: { x: 0, y: 0 } },{ point: { x: 10, y: 0 } },{ point: { x: 30, y: 10 } },{ point: { x: 40, y: 0 } }');

      var path = new Path();
      path.add(0, 0);
      path.add(10, 0);
      path.add(20, 10);

      var path2 = new Path();
      path2.add(0, 0);
      path2.add(10, 5);
      path2.add(20, 10);

      path.join(path2);

      expect(path.segments.toString(), '{ point: { x: 0, y: 0 } },{ point: { x: 10, y: 0 } },{ point: { x: 20, y: 10 } },{ point: { x: 10, y: 5 } }');
      expect(path.closed, true);
    });

    test('path.remove()', () {
      var path = new Path();
      path.add(0, 0);
      path.add(10, 0);
      path.add(20, 0);
      path.add(30, 0);

      path.removeSegment(0);
      expect(path.segments.length, 3);

      path.removeSegment(0);
      expect(path.segments.length, 2);

      path.removeSegments(0, 1);
      expect(path.segments.length, 1);

      path.remove();

      expect(paper.project.activeLayer.children.length, 0);
    });

    test('path.removeSegments()', () {
      var path = new Path();
      path.add(0, 0);
      path.add(10, 0);
      path.add(20, 0);
      path.add(30, 0);

      path.removeSegments();
      expect(path.segments.length, 0);
    });

    test('Is the path deselected after setting a new list of segments?', () {
      var path = new Path([0, 0]);
      path.selected = true;
      expect(path.selected, true);
      expect(paper.project.selectedItems.length, 1);

      path.segments = [[0, 10]];
      expect(path.selected, true);
      expect(paper.project.selectedItems.length, 1);
    });

    test('After setting Path#fullySelected=true on an empty path, subsequent segments should be selected', () {
      var path = new Path();
      path.fullySelected = true;
      expect(path.fullySelected, true);
      path.add([10, 10]);
      expect(path.fullySelected, true);
      expect(path.firstSegment.selected, true);
    });

    test('After removing all segments of a fully selected path, it should still be fully selected.', () {
      var path = new Path([10, 20], [30, 40]);
      path.fullySelected = true;
      path.removeSegments();
      expect(path.fullySelected, true);
    });

    test('After removing all segments of a selected path, it should still be selected.', () {
      var path = new Path([10, 20], [30, 40]);
      path.selected = true;
      path.removeSegments();
      expect(path.selected, true);
    });


    test('After simplifying a path using #simplify(), the path should stay fullySelected', () {
      var path = new Path();
      for (var i = 0; i < 30; i++) {
        path.add(i * 10, 10);
      };
      path.fullySelected = true;
      expect(path.selected, true);

      path.simplify();

      expect(path.selected, true);
      expect(path.fullySelected, true);
    });

    test('After simplifying a path using #simplify(), the path should stay fullySelected', () {
      var path = new Path();
      for (var i = 0; i < 30; i++) {
        path.add(i * 10, 10);
      };
      path.fullySelected = true;
      expect(path.selected, true);

      path.simplify();

      expect(path.selected, true);
      expect(path.fullySelected, true);
    });

    test('After cloning a selected item, it should be added to the Project#selectedItems array', () {
      var path = new Path.Circle(new Size(80, 50), 35);
      path.selected = true;
      var copy = path.clone();

      expect(paper.project.selectedItems.length, 2);
    });

    test('After simplifying a path using #simplify(), the path should stay selected', () {
      var path = new Path();
      for (var i = 0; i < 30; i++) {
        path.add(i * 10, (i % 2 ? 20 : 40));
      };
      path.selected = true;
      path.simplify();
      expect(path.selected, true);
    });

    test('After smoothing a path using #smooth(), the path should stay fullySelected', () {
      var path = new Path();
      for (var i = 0; i < 30; i++) {
        path.add(i * 10, (i % 2 ? 20 : 40));
      };
      path.fullySelected = true;
      path.smooth();
      expect(path.fullySelected, true);
    });

    test('After smoothing a path using #smooth(), the path should stay selected', () {
      var path = new Path();
      for (var i = 0; i < 30; i++) {
        path.add(i * 10, (i % 2 ? 20 : 40));
      };
      path.selected = true;
      path.smooth();
      expect(path.selected, true);
    });

    test('After selecting a segment, Path#selected should return true', () {
      var path = new Path();
      path.add([10, 10]);
      path.firstSegment.selected = true;
      expect(path.selected, true);
    });

    test('Path#reverse', () {
      var path = new Path.Circle([100, 100], 30);
      path.reverse();
      expect(path.segments.toString(), '{ point: { x: 100, y: 130 }, handleIn: { x: -16.56854, y: 0 }, handleOut: { x: 16.56854, y: 0 } },{ point: { x: 130, y: 100 }, handleIn: { x: 0, y: 16.56854 }, handleOut: { x: 0, y: -16.56854 } },{ point: { x: 100, y: 70 }, handleIn: { x: 16.56854, y: 0 }, handleOut: { x: -16.56854, y: 0 } },{ point: { x: 70, y: 100 }, handleIn: { x: 0, y: -16.56854 }, handleOut: { x: 0, y: 16.56854 } }');
    });

    test('Path#reverse should adjust segment indices', () {
      var path = new Path([[0, 0], [10, 10], [20, 20]]);
      path.reverse();
      expect(path.segments[0].index, 0);
      expect(path.segments[1].index, 1);
      expect(path.segments[2].index, 2);
    });

    test('Path#fullySelected', () {
      var path = new Path.Circle([100, 100], 10);
      path.fullySelected = true;
      path.segments[1].selected = false;
      expect(path.fullySelected, false);
    });
  });
}