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
 * @name Group
 *
 * @class A Group is a collection of items. When you transform a Group, its
 * children are treated as a single unit without changing their relative
 * positions.
 *
 * @extends Item
 */
class Group extends Item {
  // DOCS: document new Group(item, item...);
  /**
   * Creates a new Group item and places it at the top of the active layer.
   *
   * @param {Item[]} [children] An array of children that will be added to the
   * newly created group.
   *
   * @example {@paperscript split=true height=200}
   * // Create a group containing two paths:
   * var path = new Path(new Point(100, 100), new Point(100, 200));
   * var path2 = new Path(new Point(50, 150), new Point(150, 150));
   *
   * // Create a group from the two paths:
   * var group = new Group([path, path2]);
   *
   * // Set the stroke color of all items in the group:
   * group.strokeColor = 'black';
   *
   * // Move the group to the center of the view:
   * group.position = view.center;
   *
   * @example {@paperscript split=true height=320}
   * // Click in the view to add a path to the group, which in turn is rotated
   * // every frame:
   * var group = new Group();
   *
   * function onMouseDown(event) {
   *   // Create a new circle shaped path at the position
   *   // of the mouse:
   *   var path = new Path.Circle(event.point, 5);
   *   path.fillColor = 'black';
   *
   *   // Add the path to the group's children list:
   *   group.addChild(path);
   * }
   *
   * function onFrame(event) {
   *   // Rotate the group by 1 degree from
   *   // the centerpoint of the view:
   *   group.rotate(1, view.center);
   * }
   */
  Group(List items) {
    // TODO look into what this does. superclass constructor probably
    //this.base();
    // Allow Group to have children and named children
    _children = [];
    _namedChildren = {};
    addChildren(items);
    // TODO below allows new Group(item1, item2, ...)
    //this.addChildren(!items || !Array.isArray(items)
    //    || typeof items[0] !== 'object' ? arguments : items);
  }
  
  Item _clipItem;

  _changed(int flags) {
    // Don't use base() for reasons of performance.
    super._changed(flags);
    if ((flags & (ChangeFlag.HIERARCHY | ChangeFlag.CLIPPING)) != 0) {
      // Clear cached clip item whenever hierarchy changes
      _clipItem = null;
    }
  }

  Item _getClipItem() {
    // Allow us to set _clipItem to null when none is found and still return
    // it as a defined value without searching again
    if (_clipItem != null)
      return _clipItem;
    for (Item child in _children) {
      if (child._clipMask != null) {
        return _clipItem = child;
      }
    }
    // Make sure we're setting _clipItem to null so it won't be searched for
    // nex time.
    return _clipItem = null;
  }

  /**
   * Specifies whether the group item is to be clipped.
   * When setting to {@code true}, the first child in the group is
   * automatically defined as the clipping mask.
   *
   * @type Boolean
   * @bean
   */
  bool isClipped() {
    return _getClipItem != null;
  }
  bool get clipped => isClipped();

  setClipped(bool clipped) {
    var child = this.getFirstChild();
    if (child != null)
      child.setClipMask(clipped);
    return this;
  }
  set clipped(bool value) => setClipped(value);

  draw(ctx, param) {
    var clipItem = _getClipItem();
    if (clipItem != null) {
      param.clipping = true;
      Item.draw(clipItem, ctx, param);
      param.clipping = null;
    }
    for (Item item in _children) {
      if(item !== clipItem) {
        Item.draw(item, ctx, param);
      }
    }
  }
}
