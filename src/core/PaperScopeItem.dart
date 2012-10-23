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
 * @name PaperScopeItem
 *
 * @class A private base class for all classes that have lists and references in
 * the {@link PaperScope} ({@link Project}, {@link View}, {@link Tool}), so
 * functionality can be shared.
 *
 * @private
 */
class PaperScopeItem {
  
  PaperScope _scope;
  int _index;
  String _list;
  String _reference;

  /**
   * Creates a PaperScopeItem object.
   */  
  PaperScopeItem(bool activate) {
    // Store reference to the currently active global paper scope:
    _scope = paper;
    // Push it onto this._scope.projects and set index:
    _index = _scope[_list].push(this) - 1;
    // If the project has no active reference, activate this one
    if (activate || _scope[_reference] == null)
      activate();
  }

  bool activate() {
    if (_scope == null)
      return false;
    _scope[_reference] = this;
    return true;
  }

  bool remove() {
    if (_index == null)
      return false;
    Base.splice(_scope[_list], null, _index, 1);
    // Clear the active tool reference if it was pointint to this.
    if (_scope[_reference] == this)
      _scope[_reference] = null;
    _scope = null;
    return true;
  }
}
