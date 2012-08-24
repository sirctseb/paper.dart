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

LayerTests() {
  group("Layer Tests", () {
    test('previousSibling / nextSibling', () {
      var project = paper.project;
      var firstLayer = project.activeLayer;
      var secondLayer = new Layer();
      expect(secondLayer.previousSibling == firstLayer, true);
      expect(secondLayer.nextSibling == null, true);

      // Move another layer into secondLayer and check nextSibling /
      // previousSibling:
      var path = new Path();
      var thirdLayer = new Layer();
      secondLayer.insertChild(0, thirdLayer);
      expect(secondLayer.children.length, 2);
      expect(thirdLayer.nextSibling == path, true);
      secondLayer.addChild(thirdLayer);
      expect(thirdLayer.nextSibling == null, true);
      expect(thirdLayer.previousSibling == path, true);
      expect(project.layers.length == 2, true);

      firstLayer.addChild(secondLayer);
      expect(project.layers.length == 1, true);
    });

    test('insertabove / insertbelow', () {
      var project = paper.project;
      var firstlayer = project.activelayer;
      var secondlayer = new layer();
      secondlayer.insertbelow(firstlayer);
      expect(secondlayer.previoussibling == null, true);
      expect(secondlayer.nextsibling == firstlayer, true);

      var path = new path();
      firstlayer.addchild(path);

      // move the layer above the path, inside the firstlayer:
      secondlayer.insertabove(path);
      expect(secondlayer.nextsibling == path, true);
      expect(secondlayer.parent == firstlayer, true);
      // there should now only be one layer left:
      expect(project.layers.length, 1);
    });

    test('addchild / appendbottom / nesting', () {
      var project = paper.project;
      var firstlayer = project.activelayer;
      var secondlayer = new layer();
      // there should be two layers now in project.layers
      expect(project.layers.length, 2);
      firstlayer.addchild(secondlayer);
      expect(secondlayer.parent == firstlayer, true);
      // there should only be the firslayer now in project.layers
      expect(project.layers.length, 1);
      expect(project.layers[0] == firstlayer, true);
      // now move secondlayer bellow the first again, in which case it should
      // reappear in project.layers
      secondlayer.insertbelow(firstlayer);
      // there should be two layers now in project.layers again now
      expect(project.layers.length, 2);
      expect(project.layers[0] == secondlayer
        && project.layers[1] == firstlayer, true);
    });
  });
}