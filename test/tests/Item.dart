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
      expect(secondDoc.activeLayer.children.indexOf(copy) != -1, true);
      expect(project.activeLayer.children.indexOf(copy) == -1, true);
      expect(copy != path, true);
    });

    test('copyTo(layer)', () {
      var project = paper.project;
      var path = new Path();

      var layer = new Layer();
      var copy = path.copyTo(layer);
      expect(layer.children.indexOf(copy) != -1, true);
      expect(project.layers[0].children.indexOf(copy) == -1, true);
    });

    test('clone()', () {
      var project = paper.project;
      var path = new Path();
      var copy = path.clone();
      expect(project.activeLayer.children.length, 2);
      expect(path != copy, true);
    });

    test('addChild(item)', () {
      var project = paper.project;
      var path = new Path();
      project.activeLayer.addChild(path);
      expect(project.activeLayer.children.length,  1);
    });

    test('item.parent / item.isChild / item.isParent / item.layer', () {
      var project = paper.project;
      var secondDoc = new Project();
      var path = new Path();
      project.activeLayer.addChild(path);
      expect(project.activeLayer.children.indexOf(path) != -1, true);
      expect(path.layer == project.activeLayer, true);
      secondDoc.activeLayer.addChild(path);
      expect(project.activeLayer.isChild(path), false);
      expect(path.layer == secondDoc.activeLayer, true);
      expect(path.isParent(project.activeLayer), false);
      expect(secondDoc.activeLayer.isChild(path), true);
      expect(path.isParent(secondDoc.activeLayer), true);
      expect(project.activeLayer.children.indexOf(path) == -1, true);
      expect(secondDoc.activeLayer.children.indexOf(path) == 0, true);
    });

    test('item.lastChild / item.firstChild', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      expect(project.activeLayer.firstChild == path, true);
      expect(project.activeLayer.lastChild == secondPath, true);
    });

    test('insertChild(0, item)', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      project.activeLayer.insertChild(0, secondPath);
      expect(secondPath.index < path.index, true);
    });

    test('insertAbove(item)', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      path.insertAbove(secondPath);
      expect(project.activeLayer.lastChild == path, true);
    });

    test('insertBelow(item)', () {
      var project = paper.project;
      var firstPath = new Path();
      var secondPath = new Path();
      expect(secondPath.index > firstPath.index, true);
      secondPath.insertBelow(firstPath);
      expect(secondPath.index < firstPath.index, true);
    });

    test('isDescendant(item) / isAncestor(item)', () {
      var project = paper.project;
      var path = new Path();
      expect(path.isDescendant(project.activeLayer), true);
      expect(project.activeLayer.isDescendant(path), false);
      expect(path.isAncestor(project.activeLayer), false);
      expect(project.activeLayer.isAncestor(path), true);

      // an item can't be its own descendant:
      expect(project.activeLayer.isDescendant(project.activeLayer), false);
      // an item can't be its own ancestor:
      expect(project.activeLayer.isAncestor(project.activeLayer), false);
    });

    test('isGroupedWith', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      var group = new Group([path]);
      var secondGroup = new Group([secondPath]);

      expect(path.isGroupedWith(secondPath), false);
      secondGroup.addChild(path);
      expect(path.isGroupedWith(secondPath), true);
      expect(path.isGroupedWith(group), false);
      expect(path.isDescendant(secondGroup), true);
      expect(secondGroup.isDescendant(path), false);
      expect(secondGroup.isDescendant(secondGroup), false);
      expect(path.isGroupedWith(secondGroup), false);
      paper.project.activeLayer.addChild(path);
      expect(path.isGroupedWith(secondPath), false);
      paper.project.activeLayer.addChild(secondPath);
      expect(path.isGroupedWith(secondPath), false);
    });

    test('getPreviousSibling() / getNextSibling()', () {
      var firstPath = new Path();
      var secondPath = new Path();
      expect(firstPath.nextSibling == secondPath, true);
      expect(secondPath.previousSibling == firstPath, true);
      expect(secondPath.nextSibling == null, true);
    });

    test('reverseChildren()', () {
      var project = paper.project;
      var path = new Path();
      var secondPath = new Path();
      var thirdPath = new Path();
      expect(project.activeLayer.firstChild == path, true);
      project.activeLayer.reverseChildren();
      expect(project.activeLayer.firstChild == path, false);
      expect(project.activeLayer.firstChild == thirdPath, true);
      expect(project.activeLayer.lastChild == path, true);
    });

    test('Check item#project when moving items across projects', () {
      var project = paper.project;
      var doc1 = new Project();
      var path = new Path();
      var group = new Group();
      group.addChild(new Path());

      expect(path.project == doc1, true);
      var doc2 = new Project();
      doc2.activeLayer.addChild(path);
      expect(path.project == doc2, true);

      doc2.activeLayer.addChild(group);
      expect(group.children[0].project == doc2, true);
    });

    test('group.selected', () {
      var path = new Path([0, 0]);
      var path2 = new Path([0, 0]);
      var group = new Group([path, path2]);
      path.selected = true;
      expect(group.selected, true);

      path.selected = false;
      expect(group.selected, false);

      group.selected = true;
      expect(path.selected, true);
      expect(path2.selected, true);

      group.selected = false;
      expect(path.selected, false);
      expect(path2.selected, false);
    });

    test('Check parent children object for named item', () {
      var path = new Path();
      path.name = 'test';
      expect(paper.project.activeLayer.children['test'] == path, true);

      var path2 = new Path();
      path2.name = 'test';

      expect(paper.project.activeLayer.children['test'] == path2, true);

      path2.remove();

      expect(paper.project.activeLayer.children['test'] == path, true);

      path.remove();

      expect(!paper.project.activeLayer.children['test'], true);
    });

    test('Named child access 1', () {
      var path = new Path();
      path.name = 'test';

      var path2 = new Path();
      path2.name = 'test';

      path.remove();

      expect(paper.project.activeLayer.children['test'] == path2, true);
    });

    test('Named child access 2', () {
      var path = new Path();
      path.name = 'test';

      var path2 = new Path();
      path2.name = 'test';

      path.remove();

      expect(paper.project.activeLayer.children['test'] == path2, true);

      expect(paper.project.activeLayer._namedChildren['test'].length == 1, true);

      path2.remove();

      expect(!paper.project.activeLayer._namedChildren['test'], true);

      expect(paper.project.activeLayer.children['test'] ==  null, true);
    });

    test('Named child access 3', () {
      var path = new Path();
      path.name = 'test';

      var path2 = new Path();
      path2.name = 'test';

      var group = new Group();

      group.addChild(path2);

      expect(paper.project.activeLayer.children['test'] == path, true);

      // TODO: Tests should not access internal properties
      expect(paper.project.activeLayer._namedChildren['test'].length, 1);

      expect(group.children['test'] == path2, true);

      expect(group._namedChildren['test'].length == 1, true);

      expect(paper.project.activeLayer._namedChildren['test'][0] == path, true);

      paper.project.activeLayer.appendTop(path2);

      expect(group.children['test'] == null, true);

      expect(group._namedChildren['test'] == null, true);

      expect(paper.project.activeLayer.children['test'] == path2, true);

      expect(paper.project.activeLayer._namedChildren['test'].length, 2);
    });

    test('Setting name of child back to null', () {
      var path = new Path();
      path.name = 'test';

      var path2 = new Path();
      path2.name = 'test';

      expect(paper.project.activeLayer.children['test'] == path2, true);

      path2.name = null;

      expect(paper.project.activeLayer.children['test'] == path, true);

      path.name = null;

      expect(paper.project.activeLayer.children['test'] == null, true);
    });

    test('Renaming item', () {
      var path = new Path();
      path.name = 'test';

      path.name = 'test2';

      expect(paper.project.activeLayer.children['test'] == null, true);

      expect(paper.project.activeLayer.children['test2'] == path, true);
    });

    test('Changing item#position.x', () {
      var path = new Path.Circle(new Point(50, 50), 50);
      path.position.x += 5;
      expect(path.position.toString(), '{ x: 55, y: 50 }', 'path.position.x += 5');
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
      expect(error == null, true, description);
    });
  });
}