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

ItemOrderTests() {
  group("Item Order Tests", () {

    test('Item Order', () {
      var line = new Path();
      line.add([0, 0], [100, 100]);
      line.name = 'line';

      var circle = new Path.Circle([50, 50], 50);
      circle.name = 'circle';

      var group = new Group([circle]);
      group.name = 'group';

      expect(circle.isAbove(line), true);
      expect(line.isBelow(circle), true);

      expect(group.isAbove(line), true);
      expect(line.isBelow(group), true);


      expect(group.isAncestor(circle), true);

      expect(circle.isDescendant(group), true);


      expect(group.isAbove(circle), false);

      expect(group.isBelow(circle), false);
    });

    test('Item#moveAbove(item) / Item#moveBelow(item)', () {
      var item0, item1, item2;
      var testMove = (command, indexes) {
        paper.project.activeLayer.remove();
        new Layer();
        item0 = new Group();
        item1 = new Group();
        item2 = new Group();
        command();
        expect(item0.index, indexes[0], command.toString());
        expect(item1.index, indexes[1]);
        expect(item2.index, indexes[2]);
      };

      testMove(() { item0.moveBelow(item0) }, [0,1,2]);
      testMove(() { item0.moveBelow(item1) }, [0,1,2]);
      testMove(() { item0.moveBelow(item2) }, [1,0,2]);
      testMove(() { item1.moveBelow(item0) }, [1,0,2]);
      testMove(() { item1.moveBelow(item1) }, [0,1,2]);
      testMove(() { item1.moveBelow(item2) }, [0,1,2]);

      testMove(() { item2.moveBelow(item0) }, [1,2,0]);
      testMove(() { item2.moveBelow(item1) }, [0,2,1]);
      testMove(() { item2.moveBelow(item2) }, [0,1,2]);

      testMove(() { item0.moveAbove(item0) }, [0,1,2]);
      testMove(() { item0.moveAbove(item1) }, [1,0,2]);
      testMove(() { item0.moveAbove(item2) }, [2,0,1]);
      testMove(() { item1.moveAbove(item0) }, [0,1,2]);
      testMove(() { item1.moveAbove(item1) }, [0,1,2]);
      testMove(() { item1.moveAbove(item2) }, [0,2,1]);
      testMove(() { item2.moveAbove(item0) }, [0,2,1]);
      testMove(() { item2.moveAbove(item1) }, [0,1,2]);
      testMove(() { item2.moveAbove(item2) }, [0,1,2]);
    });
  });
}