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

ProjectTests() {
  group("Project Tests", () {

    test('activate()', () {
      var project = new Project();
      var secondDoc = new Project();
      project.activate();
      var path = new Path();
      expect(project.activeLayer.children[0] == path, true);
      expect(secondDoc.activeLayer.children.length == 0, true);
    });
  });
}