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

PlacedSymbolTests() {
  group("Placed Symbol Tests", () {

    test('placedSymbol bounds', () {
      var path = new Path.Circle([50, 50], 50);
      path.strokeColor = 'black';
      path.strokeWidth = 1;
      path.strokeCap = 'round';
      path.strokeJoin = 'round';
      compareRectangles(path.strokeBounds,
        { "x": -0.5, "y": -0.5, "width": 101, "height": 101 },
        'Path initial bounds');
      var symbol = new Symbol(path);
      var placedSymbol = new PlacedSymbol(symbol);

      compareRectangles(placedSymbol.bounds,
        new Rectangle(-50.5, -50.5, 101, 101),
        'PlacedSymbol initial bounds');

      placedSymbol.scale(1, 0.5);
      compareRectangles(placedSymbol.bounds,
        { "x": -50.5, "y": -25.25, "width": 101, "height": 50.5 },
        'Bounds after scale');

      placedSymbol.rotate(40);
      compareRectangles(placedSymbol.bounds,
        { "x": -41.96283, "y": -37.79252, "width": 83.92567, "height": 75.58503 },
        'Bounds after rotation');
    });

    test('bounds of group of symbol instances', () {
      var path = new Path.Circle(new Point(), 10);
      var symbol = new Symbol(path);
      var instances = [];
      for (var i = 0; i < 10; i++) {
        var instance = symbol.place(new Point(i * 20, 20));
        instances.push(instance);
      }
      var group = new Group(instances);
      compareRectangles(group.bounds,
        { "x": -10, "y": 10, "width": 200, "height": 20 },
        'Group bounds');
    });

    test('bounds of a symbol that contains a group of items', () {
      var path = new Path.Circle(new Point(), 10);
      var path2 = path.clone();
      path2.position.x += 20;
      compareRectangles(path.bounds,
        { "x": -10, "y": -10, "width": 20, "height": 20 },
        'path bounds');
      compareRectangles(path2.bounds,
        { "x": 10, "y": -10, "width": 20, "height": 20 },
        'path2 bounds');
      var group = new Group(path, path2);
      compareRectangles(group.bounds,
        { "x": -10, "y": -10, "width": 40, "height": 20 },
        'Group bounds');
      var symbol = new Symbol(group);
      var instance = symbol.place(new Point(50, 50));
      compareRectangles(instance.bounds,
        { "x": 30, "y": 40, "width": 40, "height": 20 },
        'Instance bounds');
    });

    test('Changing the definition of a symbol should change the bounds of all instances of it.', () {
      var path = new Path.Circle(new Point(), 10);
      var path2 = new Path.Circle(new Point(), 20);
      var symbol = new Symbol(path);
      var instance = symbol.place(new Point(0, 0));
      compareRectangles(instance.bounds,
        { "x": -10, "y": -10, "width": 20, "height": 20 },
        'Initial bounds');
      symbol.definition = path2;
      compareRectangles(instance.bounds,
        { "x": -20, "y": -20, "width": 40, "height": 40 },
        'Bounds after changing symbol definition');
      symbol.definition.scale(0.5, 0.5);
      compareRectangles(instance.bounds,
        { "x": -10, "y": -10, "width": 20, "height": 20 },
        'Bounds after modifying symbol definition');
    });

    test('Symbol definition selection', () {
      var path = new Path.Circle([50, 50], 50);
      path.selected = true;
      var symbol = new Symbol(path);
      expect(symbol.definition.selected == false, true);
      expect(paper.project.selectedItems.length == 0, true);
    });

    test('Symbol#place()', () {
      var path = new Path.Circle([50, 50], 50);
      var symbol = new Symbol(path);
      var placedSymbol = symbol.place();
      expect(placedSymbol.parent == paper.project.activeLayer, true);

      expect(placedSymbol.symbol == symbol, true);

      expect(placedSymbol.position.toString(), '{ x: 0, y: 0 }');
    });

    test('Symbol#place(position)', () {
      var path = new Path.Circle([50, 50], 50);
      var symbol = new Symbol(path);
      var placedSymbol = symbol.place(new Point(100, 100));
      expect(placedSymbol.position.toString(), '{ x: 100, y: 100 }');
    });

  });
}