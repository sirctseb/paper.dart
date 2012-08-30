part of Item;

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
 * @name Layer
 *
 * @class The Layer item represents a layer in a Paper.js project.
 *
 * The layer which is currently active can be accessed through
 * {@link Project#activeLayer}.
 * An array of all layers in a project can be accessed through
 * {@link Project#layers}.
 *
 * @extends Group
 */
class Layer extends Group {
  // DOCS: improve constructor code example.
  /**
   * Creates a new Layer item and places it at the end of the
   * {@link Project#layers} array. The newly created layer will be activated,
   * so all newly created items will be placed within it.
   *
   * @param {Item[]} [children] An array of items that will be added to the
   * newly created layer.
   *
   * @example
   * var layer = new Layer();
   */
  Layer(items) : super(items) {
    _project = paper.project;
    // Push it onto project.layers and set index:
    _index = this._project.layers.push(this) - 1;
    activate();
  }

  /**
  * Removes the layer from its project's layers list
  * or its parent's children list.
  */
  _remove(bool deselect, bool notify) {
    if (_parent != null)
      // TODO what does this base call do?
      return super._remove(deselect, notify);
    if (_index != null) {
      if (deselect)
        setSelected(false);
      Base.splice(_project.layers, null, _index, 1);
      // Tell project we need a redraw. This is similar to _changed()
      // mechanism.
      _project._needsRedraw();
      return true;
    }
    return false;
  }

  getNextSibling() {
    // TODO what does base() do?
    return _parent != null ? super.getNextSibling()
        : _project.layers[_index + 1] || null;
  }

  getPreviousSibling() {
    // TODO what does base() do?
    return _parent != null ? super.getPreviousSibling()
        : _project.layers[_index - 1] || null;
  }

  /**
   * Activates the layer.
   *
   * @example
   * var firstLayer = project.activeLayer;
   * var secondLayer = new Layer();
   * console.log(project.activeLayer == secondLayer); // true
   * firstLayer.activate();
   * console.log(project.activeLayer == firstLayer); // true
   */
  activate() {
    _project.activeLayer = this;
  }

  _insert(bool above, Item item) {
    // If the item is a layer and contained within Project#layers, use
    // our own version of move().
    if (item is Layer && item._parent == null
      && _remove(false, true)) {
      Base.splice(item._project.layers, [this],
        item._index + (above ? 1 : -1), 0);
      _setProject(item._project);
      return true;
    }
    if(above) super.insertAbove(item);
    else super.insertBelow(item);
  }

  insertAbove(Item item) {
    return _insert(true, item);
  }
  insertBelow(Item item) {
    return _insert(false, item);
  }
}
