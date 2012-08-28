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
library CanvasProvider;
import "../basic/Basic.dart";
import "dart:html" as HTML;

// TODO: It might be better to make a ContextProvider class, since you
// can always find the canvas through context.canvas. This saves code and
// speed by not having to do canvas.getContext('2d')
// TODO: Run through the canvas array to find a canvas with the requested
// width / height, so we don't need to resize it?
class CanvasProvider {
  static var canvases = const [];
  static getCanvas(Size size) {
    if (canvases.length > 0) {
      var canvas = canvases.pop();
      // If they are not the same size, we don't need to clear them
      // using clearRect and visa versa.
      if ((canvas.width != size.width)
          || (canvas.height != size.height)) {
        canvas.width = size.width;
        canvas.height = size.height;
      } else {
        // +1 is needed on some browsers to really clear the borders
        canvas.getContext('2d').clearRect(0, 0,
            size.width + 1, size.height + 1);
      }
      return canvas;
    } else {
      var canvas = new HTML.CanvasElement();
      canvas.width = size.width;
      canvas.height = size.height;
      return canvas;
      // TODO what about this stuff below?
///*#*/ if (options.browser) {
//      var canvas = document.createElement('canvas');
//      canvas.width = size.width;
//      canvas.height = size.height;
//      return canvas;
///*#*/ } else { // !options.browser
//      return new Canvas(size.width, size.height);
///*#*/ } // !options.browser
    }
  }

  void returnCanvas(canvas) {
    canvases.add(canvas);
  }
}
