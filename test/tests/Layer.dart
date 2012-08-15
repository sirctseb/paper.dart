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
      equals(() {
        return secondLayer.previousSibling == firstLayer;
        }, true);
      equals(() {
        return secondLayer.nextSibling == null;
        }, true);

      // Move another layer into secondLayer and check nextSibling /
      // previousSibling:
      var path = new Path();
      var thirdLayer = new Layer();
      secondLayer.insertChild(0, thirdLayer);
      equals(() {
        return secondLayer.children.length;
        }, 2);
      equals(() {
        return thirdLayer.nextSibling == path;
        }, true);
      secondLayer.addChild(thirdLayer);
      equals(() {
        return thirdLayer.nextSibling == null;
        }, true);
      equals(() {
        return thirdLayer.previousSibling == path;
        }, true);
      equals(() {
        return project.layers.length == 2;
        }, true);

      firstLayer.addChild(secondLayer);
      equals(() {
        return project.layers.length == 1;
        }, true);
    });

    test('insertabove / insertbelow', () {
      var project = paper.project;
      var firstlayer = project.activelayer;
      var secondlayer = new layer();
      secondlayer.insertbelow(firstlayer);
      equals(() {
        return secondlayer.previoussibling == null;
        }, true);
      equals(() {
        return secondlayer.nextsibling == firstlayer;
        }, true);

      var path = new path();
      firstlayer.addchild(path);

      // move the layer above the path, inside the firstlayer:
      secondlayer.insertabove(path);
      equals(() {
        return secondlayer.nextsibling == path;
        }, true);
      equals(() {
        return secondlayer.parent == firstlayer;
        }, true);
      // there should now only be one layer left:
      equals(() {
        return project.layers.length;
        }, 1);
    });

    test('addchild / appendbottom / nesting', () {
      var project = paper.project;
      var firstlayer = project.activelayer;
      var secondlayer = new layer();
      // there should be two layers now in project.layers
      equals(() {
        return project.layers.length;
        }, 2);
      firstlayer.addchild(secondlayer);
      equals(() {
        return secondlayer.parent == firstlayer;
        }, true);
      // there should only be the firslayer now in project.layers
      equals(() {
        return project.layers.length;
        }, 1);
      equals(() {
        return project.layers[0] == firstlayer;
        }, true);
      // now move secondlayer bellow the first again, in which case it should
      // reappear in project.layers
      secondlayer.insertbelow(firstlayer);
      // there should be two layers now in project.layers again now
      equals(() {
        return project.layers.length;
        }, 2);
      equals(() {
        return project.layers[0] == secondlayer
        && project.layers[1] == firstlayer;
        }, true);
    });
  });
}