library Change;

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

class ChangeFlag {
  // Anything affecting the appearance of an item, including GEOMETRY,
  // STROKE, STYLE and ATTRIBUTE (except for the invisible ones: locked, name)
  static final int APPEARANCE = 1;
  // Change in item hierarchy
  static final int HIERARCHY = 2;
  // Item geometry (path, bounds)
  static final int GEOMETRY = 4;
  // Stroke geometry (excluding color)
  static final int STROKE = 8;
  // Fill style or stroke color / dash
  static final int STYLE = 16;
  // Item attributes: visible, blendMode, locked, name, opacity, clipMask ...
  static final int ATTRIBUTE = 32;
  // Text content
  static final int CONTENT = 64;
  // Raster pixels
  static final int PIXELS = 128;
  // Clipping in one of the child items
  static final int CLIPPING = 256;
}

// Shortcuts to often used ChangeFlag values including APPEARANCE
class Change {
  static final int HIERARCHY = ChangeFlag.HIERARCHY | ChangeFlag.APPEARANCE;
  static final int GEOMETRY = ChangeFlag.GEOMETRY | ChangeFlag.APPEARANCE;
  static final int STROKE = ChangeFlag.STROKE | ChangeFlag.STYLE | ChangeFlag.APPEARANCE;
  static final int STYLE = ChangeFlag.STYLE | ChangeFlag.APPEARANCE;
  static final int ATTRIBUTE = ChangeFlag.ATTRIBUTE | ChangeFlag.APPEARANCE;
  static final int CONTENT = ChangeFlag.CONTENT | ChangeFlag.APPEARANCE;
  static final int PIXELS = ChangeFlag.PIXELS | ChangeFlag.APPEARANCE;
}