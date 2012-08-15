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

PathStyleTests() {
  group("Path Style Tests", () {
    test('style defaults', () {
      var path = new Path();
      expect(path.strokeWidth, 1);
      expect(path.strokeCap, 'butt');
      expect(path.strokeJoin, 'miter');
      expect(path.miterLimit, 10);
      expect(path.dashOffset, 0);
      expect("${path.dashArray}", "${[]}");
    });

    test('currentStyle', () {
      paper.project.currentStyle.fillColor = 'black';
      var path = new Path();
      compareRgbColors(path.fillColor, 'black', 'path.fillColor');

      // When changing the current style of the project, the style of
      // paths created using project.currentStyle should not change.
      paper.project.currentStyle.fillColor = 'red';
      compareRgbColors(path.fillColor, 'black', 'path.fillColor');
    });

    test('setting currentStyle to an object', () {
      paper.project.currentStyle = {
        "fillColor": 'red',
        "strokeColor": 'green'
      };
      var path = new Path();
      compareRgbColors(path.fillColor, 'red', 'path.fillColor');
      compareRgbColors(path.strokeColor, 'green', 'path.strokeColor');
    });

    test('setting path styles to an object', () {
      var path = new Path();
      path.style = {
        "fillColor": 'red',
        "strokeColor": 'green'
      };
      compareRgbColors(path.fillColor, 'red', 'path.fillColor');
      compareRgbColors(path.strokeColor, 'green', 'path.strokeColor');
    });

    test('setting group styles to an object', () {
      var group = new Group();
      var path = new Path();
      group.addChild(path);
      group.style = {
        "fillColor": 'red',
        "strokeColor": 'green'
      };
      compareRgbColors(path.fillColor, 'red', 'path.fillColor');
      compareRgbColors(path.strokeColor, 'green', 'path.strokeColor');
    });

    test('getting group styles', () {
      var group = new Group();
      var path = new Path();
      path.fillColor = 'red';
      group.addChild(path);

      compareRgbColors(group.fillColor, 'red', 'group.fillColor');

      var secondPath = new Path();
      secondPath.fillColor = 'black';
      group.addChild(secondPath);

      // the group now contains two paths with different fillColors and therefore
      // should return "undefined":
      expect(group.fillColor, undefined);

      //If we remove the first path, it should now return 'black':
      group.children[0].remove();
      compareRgbColors(group.fillColor, 'black', 'group.fillColor');
    });

    test('setting group styles', () {
      var group = new Group();
      var path = new Path();
      path.fillColor = 'red';
      group.addChild(path);

      var secondPath = new Path();
      secondPath.fillColor = 'blue';
      secondPath.strokeColor = 'red';
      group.addChild(secondPath);

      // Change the fill color of the "group":
      group.fillColor = 'black';

      // the paths contained in the group should now both have their fillColor
      // set to "black":
      compareRgbColors(path.fillColor, 'black', 'path.fillColor');
      compareRgbColors(secondPath.fillColor, 'black', 'secondPath.fillColor');

      // The second path still has its strokeColor set to "red":
      compareRgbColors(secondPath.strokeColor, 'red', 'secondPath.strokeColor');
    });

    test('setting group styles 2', () {
      var group = new Group();
      var path = new Path();
      path.fillColor = 'red';
      group.addChild(path);

      compareRgbColors(group.fillColor, 'red', 'group.fillColor');

      var secondPath = new Path();
      secondPath.fillColor = 'blue';
      secondPath.strokeColor = 'red';
      group.addChild(secondPath);

      compareRgbColors(secondPath.fillColor, 'blue', 'secondPath.fillColor');
      compareRgbColors(secondPath.strokeColor, 'red', 'secondPath.strokeColor');

      // By appending a path with a different fillcolor,
      // the group's fillColor should return "undefined":
      expect(group.fillColor, undefined);

      // But, both paths have a red strokeColor, "so":
      compareRgbColors(group.strokeColor, 'red', 'group.strokeColor');

      // Change the fill color of the group's "style":
      group.style.fillColor = 'black';

      // the paths contained in the group should now both have their fillColor
      // set to "black":
      compareRgbColors(path.fillColor, 'black', 'path.fillColor');
      compareRgbColors(secondPath.fillColor, 'black', 'secondPath.fillColor');

      // The second path still has its strokeColor set to "red":
      compareRgbColors(secondPath.strokeColor, 'red', 'secondPath.strokeColor');
    });
  });
}