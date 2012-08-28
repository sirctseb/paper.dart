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

/**
 * @name PlacedItem
 *
 * @class The PlacedItem class is the base for any items that have a matrix
 * associated with them, describing their placement in the project, such as
 * {@link Raster} and {@link PlacedSymbol}.
 *
 * @extends Item
 */
class PlacedItem extends Item {
  PlacedItem() {
  	_boundsType = {"bounds": "strokeBounds"};
  }
}
