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

ItemTests() {
  group("Item Tests", () {
    test('copyTo(project)', () {
      var project = paper.project;
      var path = new Path();
      var secondDoc = new Project();
      var copy = path.copyTo(secondDoc);
      equals(() {
        return secondDoc.activeLayer.children.indexOf(copy) != -1;
      }, true);
      equals(() {
        return project.activeLayer.children.indexOf(copy) == -1;
      }, true);
      equals(() {
        return copy != path;
      }, true);
    });

    test('copyTo(layer)', () {
      var project = paper.project;
      var path = new Path();

      var layer = new Layer();
      var copy = path.copyTo(layer);
      equals(() {
        return layer.children.indexOf(copy) != -1;
      }, true);
      equals(() {
        return project.layers[0].children.indexOf(copy) == -1;
      }, true);
    });

    test('clone()', () {
      var project = paper.project;
      var path = new Path();
      var copy = path.clone();
      equals(() {
        return project.activeLayer.children.length;
      }, 2);
      equals(() {
        return path != copy;
      }, true);
    });

    test('addChild(item)', () {
      var project = paper.project;
      var path = new Path();
      project.activeLayer.addChild(path);
      equals(() {
        return project.activeLayer.children.length;
      },  1);
    });

    test('item.parent / item.isChild / item.isParent / item.layer', () {
      var project = paper.project;
      var secondDoc = new Project();
      var path = new Path();
      project.activeLayer.addChild(path);
      equals(() {
        return project.activeLayer.children.indexOf(path) != -1;
      }, true);
        equals(() {
        return path.layer == project.activeLayer;
      }, true);
      secondDoc.activeLayer.addChild(path);
      equals(() {
        return project.activeLayer.isChild(path);
      }, false);
      equals(() {
        return path.layer == secondDoc.activeLayer;
      }, true);
      equals(() {
        return path.isParent(project.activeLayer);
      }, false);
      equals(() {
        return secondDoc.activeLayer.isChild(path);
      }, true);
      equals(() {
        return path.isParent(secondDoc.activeLayer);
      }, true);
      equals(() {
        return project.activeLayer.children.indexOf(path) == -1;
      }, true);
      equals(() {
        return secondDoc.activeLayer.children.indexOf(path) == 0;
      }, true);
    });

    test('item.lastChild / item.firstChild', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      equals(() {
        return project.activeLayer.firstChild == path;
      }, true);
      equals(() {
        return project.activeLayer.lastChild == secondPath;
      }, true);
    });

    test('insertChild(0, item)', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      project.activeLayer.insertChild(0, secondPath);
      equals(() {
        return secondPath.index < path.index;
      }, true);
    });

    test('insertAbove(item)', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      path.insertAbove(secondPath);
      equals(() {
        return project.activeLayer.lastChild == path;
      }, true);
    });

    test('insertBelow(item)', () {
      var project = paper.project;
      var firstPath = new Path();
      var secondPath = new Path();
      equals(() {
        return secondPath.index > firstPath.index;
      }, true);
      secondPath.insertBelow(firstPath);
      equals(() {
        return secondPath.index < firstPath.index;
      }, true);
    });

    test('isDescendant(item) / isAncestor(item)', () {
      var project = paper.project;
      var path = new Path();
      equals(() {
        return path.isDescendant(project.activeLayer);
      }, true);
      equals(() {
        return project.activeLayer.isDescendant(path);
      }, false);
      equals(() {
        return path.isAncestor(project.activeLayer);
      }, false);
      equals(() {
        return project.activeLayer.isAncestor(path);
      }, true);

      // an item can't be its own descendant:
      equals(() {
        return project.activeLayer.isDescendant(project.activeLayer);
      }, false);
      // an item can't be its own ancestor:
      equals(() {
        return project.activeLayer.isAncestor(project.activeLayer);
      }, false);
    });

    test('isGroupedWith', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      var group = new Group([path]);
      var secondGroup = new Group([secondPath]);

      equals(() {
        return path.isGroupedWith(secondPath);
      }, false);
      secondGroup.addChild(path);
      equals(() {
        return path.isGroupedWith(secondPath);
      }, true);
      equals(() {
        return path.isGroupedWith(group);
      }, false);
      equals(() {
        return path.isDescendant(secondGroup);
      }, true);
      equals(() {
        return secondGroup.isDescendant(path);
      }, false);
      equals(() {
        return secondGroup.isDescendant(secondGroup);
      }, false);
      equals(() {
        return path.isGroupedWith(secondGroup);
      }, false);
      paper.project.activeLayer.addChild(path);
      equals(() {
        return path.isGroupedWith(secondPath);
      }, false);
      paper.project.activeLayer.addChild(secondPath);
      equals(() {
        return path.isGroupedWith(secondPath);
      }, false);
    });

    test('getPreviousSibling() / getNextSibling()', () {
      var firstPath = new Path();
      var secondPath = new Path();
      equals(() {
        return firstPath.nextSibling == secondPath;
      }, true);
      equals(() {
        return secondPath.previousSibling == firstPath;
      }, true);
      equals(() {
        return secondPath.nextSibling == null;
      }, true);
    });

    test('reverseChildren()', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      var thirdPath = new Path();
      equals(() {
        return project.activeLayer.firstChild == path;
      }, true);
      project.activeLayer.reverseChildren();
      equals(() {
        return project.activeLayer.firstChild == path;
      }, false);
      equals(() {
        return project.activeLayer.firstChild == thirdPath;
      }, true);
      equals(() {
        return project.activeLayer.lastChild == path;
      }, true);
    });

    test('Check item#project when moving items across projects', () {
      var project = paper.project;
      var doc1 = new Project();
      var path = new Path();
      var group = new Group();
      group.addChild(new Path());

      equals(() {
        return path.project == doc1;
      }, true);
      var doc2 = new Project();
      doc2.activeLayer.addChild(path);
      equals(() {
        return path.project == doc2;
      }, true);

      doc2.activeLayer.addChild(group);
      equals(() {
        return group.children[0].project == doc2;
      }, true);
    });

    test('group.selected', () {
      var path = new Path([0, 0]);
      var path2 = new Path([0, 0]);
      var group = new Group([path, path2]);
      path.selected = true;
      equals(() {
        return group.selected;
      }, true);

      path.selected = false;
      equals(() {
        return group.selected;
      }, false);

      group.selected = true;
      equals(() {
        return path.selected;
      }, true);
      equals(() {
        return path2.selected;
      }, true);

      group.selected = false;
      equals(() {
        return path.selected;
      }, false);
      equals(() {
        return path2.selected;
      }, false);
    });

    test('Check parent children object for named item', () {
      var path = new Path();
      path.name = 'test';
      equals(() {
        return paper.project.activeLayer.children['test'] == path;
      }, true);

      var path2 = new Path();
      path2.name = 'test';

      equals(() {
        return paper.project.activeLayer.children['test'] == path2;
      }, true);

      path2.remove();

      equals(() {
        return paper.project.activeLayer.children['test'] == path;
      }, true);

      path.remove();

      equals(() {
        return !paper.project.activeLayer.children['test'];
      }, true);
    });

    test('Named child access 1', () {
      var path = new Path();
      path.name = 'test';

      var path2 = new Path();
      path2.name = 'test';

      path.remove();

      equals(() {
        return paper.project.activeLayer.children['test'] == path2;
      }, true);
    });

    test('Named child access 2', () {
      var path = new Path();
      path.name = 'test';

      var path2 = new Path();
      path2.name = 'test';

      path.remove();

      equals(() {
        return paper.project.activeLayer.children['test'] == path2;
      }, true);

      equals(() {
        return paper.project.activeLayer._namedChildren['test'].length == 1;
      }, true);

      path2.remove();

      equals(() {
        return !paper.project.activeLayer._namedChildren['test'];
      }, true);

      equals(() {
        return paper.project.activeLayer.children['test'] === undefined;
      }, true);
    });

    test('Named child access 3', () {
      var path = new Path();
      path.name = 'test';

      var path2 = new Path();
      path2.name = 'test';

      var group = new Group();

      group.addChild(path2);

      equals(() {
        return paper.project.activeLayer.children['test'] == path;
      }, true);

      // TODO: Tests should not access internal properties
      equals(() {
        return paper.project.activeLayer._namedChildren['test'].length;
      }, 1);

      equals(() {
        return group.children['test'] == path2;
      }, true);

      equals(() {
        return group._namedChildren['test'].length == 1;
      }, true);

      equals(() {
        return paper.project.activeLayer._namedChildren['test'][0] == path;
      }, true);

      paper.project.activeLayer.appendTop(path2);

      equals(() {
        return group.children['test'] == null;
      }, true);

      equals(() {
        return group._namedChildren['test'] === undefined;
      }, true);

      equals(() {
        return paper.project.activeLayer.children['test'] == path2;
      }, true);

      equals(() {
        return paper.project.activeLayer._namedChildren['test'].length;
      }, 2);
    });

    test('Setting name of child back to null', () {
      var path = new Path();
      path.name = 'test';

      var path2 = new Path();
      path2.name = 'test';

      equals(() {
        return paper.project.activeLayer.children['test'] == path2;
      }, true);

      path2.name = null;

      equals(() {
        return paper.project.activeLayer.children['test'] == path;
      }, true);

      path.name = null;

      equals(() {
        return paper.project.activeLayer.children['test'] === undefined;
      }, true);
    });

    test('Renaming item', () {
      var path = new Path();
      path.name = 'test';

      path.name = 'test2';

      equals(() {
        return paper.project.activeLayer.children['test'] === undefined;
      }, true);

      equals(() {
        return paper.project.activeLayer.children['test2'] == path;
      }, true);
    });

    test('Changing item#position.x', () {
      var path = new Path.Circle(new Point(50, 50), 50);
      path.position.x += 5;
      equals(path.position.toString(), '{ x: 55, y: 50 }', 'path.position.x += 5');
    });

    test('Naming a removed item', () {
      var path = new Path();
      path.remove();
      path.name = 'test';
    });

    test('Naming a layer', () {
      var layer = new Layer();
      layer.name = 'test';
    });

    test('Cloning a linked size', () {
      var path = new Path([40, 75], [140, 75]);
      var error = null;
      try {
        var cloneSize = path.bounds.size.clone();
      } catch (e) {
        error = e;
      }
      var description = 'Cloning a linked size should not throw an error';
      if (error)
        description += ': ' + error;
      equals(error == null, true, description);
    });
  });
}