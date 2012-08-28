part of paper_dart_test;

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

CompoundPathTests() {
  group("CompoundPath Tests", () {
    test('moveTo / lineTo', () {
      var path = new CompoundPath();

      var lists = [
        [new Point(279, 151), new Point(149, 151), new Point(149, 281), new Point(279, 281)],
        [new Point(319, 321), new Point(109, 321), new Point(109, 111), new Point(319, 111)]
      ];

      for (var i = 0; i < lists.length; i++) {
        var list = lists[i];
        for (var j = 0; j < list.length; j++) {
          path[j == 0 ? 'moveTo' : 'lineTo'](list[j]);
        }
      }

      path.fillColor = 'black';

      expect(path.children.length, 2);
    });

    test('clockwise', () {
      var path1 = new Path.Rectangle([200, 200], [100, 100]);
      var path2 = new Path.Rectangle([50, 50], [200, 200]);
      var path3 = new Path.Rectangle([0, 0], [400, 400]);

      expect(path1.clockwise);
      expect(path2.clockwise);
      expect(path3.clockwise);

      var compound = new CompoundPath(path1, path2, path3);

      expect(compound.lastChild === path3);
      expect(compound.firstChild === path1);
      expect(path1.clockwise);
      expect(!path2.clockwise);
      expect(!path3.clockwise);
    });
  });
}