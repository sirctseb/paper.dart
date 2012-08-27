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
 * @name Base
 * @class
 * @private
 */
// Extend Base with utility functions used across the library. Also set
// this.Base on the injection scope, since bootstrap.js ommits that.
// TODO I am just porting things we need as we go.
// I think a significant part of this will not be used
class Base {
  // Have generics versions of #clone() and #toString():
  //generics: true,

  /**
   * General purpose clone function that delegates cloning to the constructor
   * that receives the object to be cloned as the first argument.
   * Note: #clone() needs to be overridden in any class that requires other
   * cloning behavior.
   */
  /*clone: function() {
    return new this.constructor(this);
  },*/

  /**
   * Renders base objects to strings in object literal notation.
   */
  /*toString: function() {
    return '{ ' + Base.each(this, function(value, key) {
      // Hide internal properties even if they are enumerable
      if (key.charAt(0) != '_') {
        var type = typeof value;
        this.push(key + ': ' + (type === 'number'
            ? Base.formatNumber(value)
            : type === 'string' ? "'" + value + "'" : value));
      }
    }, []).join(', ') + ' }';
  },*/

  /**
   * Reads arguments of the type of the class on which it is called on
   * from the passed arguments list or array, at the given index, up to
   * the specified length. This is used in argument conversion, e.g. by
   * all basic types (Point, Size, Rectangle) and also higher classes such
   * as Color and Segment.
   */
  /*read: function(list, start, length) {
    var start = start || 0,
      length = length || list.length - start;
    var obj = list[start];
    if (obj instanceof this
        // If the class defines _readNull, return null when nothing
        // was provided
        || this.prototype._readNull && obj == null && length <= 1)
      return obj;
    obj = new this(this.dont);
    return obj.initialize.apply(obj, start > 0 || length < list.length
      ? Array.prototype.slice.call(list, start, start + length)
      : list) || obj;
  },*/

  /**
   * Reads all readable arguments from the list, handling nested arrays
   * seperately.
   */
  /*readAll: function(list, start) {
    var res = [], entry;
    for (var i = start || 0, l = list.length; i < l; i++) {
      res.push(Array.isArray(entry = list[i])
        ? this.read(entry, 0)
        : this.read(list, i, 1));
    }
    return res;
  },*/

  /**
   * Utility function for adding and removing items from a list of which
   * each entry keeps a reference to its index in the list in the private
   * _index property. Used for PaperScope#projects and Item#children.
   */
  static splice(list, items, index, remove) {
    int amount = items != null ? items.length : 0;
    bool append = index == null;
    index = append ? list.length : index;
    // Update _index on the items to be added first.
    for (var i = 0; i < amount; i++)
      items[i]._index = index + i;
    if (append) {
      // Append them all at the end by using push
      list.addAll(items);
      // Nothing removed, and nothing to adjust above
      return [];
    } else {
      // get and remove
      var removed = list.getRange(index, remove);
      list.removeRange(index, remove);

      // insert new items
      list.insertRange(index, items.length, null);
      for(int i = 0; i < items.length; i++) {
        list[index+i] = items[i];
      }

      // Adjust the indices of the items above.
      for (var i = index + amount, l = list.length; i < l; i++)
        list[i]._index = i;
      
      return removed;
    }
  }

  /**
   * Merge all passed hash objects into a newly creted Base object.
   */
  /*merge: function() {
    return Base.each(arguments, function(hash) {
      Base.each(hash, function(value, key) {
        this[key] = value;
      }, this);
    }, new Base(), true); // Pass true for asArray, as arguments is none
  },*/

  /**
   * Capitalizes the passed string: hello world -> Hello World
   */
  /*capitalize: function(str) {
    return str.replace(/\b[a-z]/g, function(match) {
      return match.toUpperCase();
    });
  },*/

  /**
   * Camelizes the passed hyphenated string: caps-lock -> capsLock
   */
  /*camelize: function(str) {
    return str.replace(/-(\w)/g, function(all, chr) {
      return chr.toUpperCase();
    });
  },*/

  /**
   * Converst camelized strings to hyphenated ones: CapsLock -> caps-lock
   */
  static String hyphenate(String str) {
    StringBuffer sb = new StringBuffer();
    int lastIndex = 0;
    RegExp transitions = new RegExp("([a-z])([A-Z0-9])|([0-9])([a-zA-Z])|([A-Z]{2})([a-z])");
    for(Match match in transitions.allMatches(str)) {
      // add stuff between last match and this
      sb.add(str.substring(lastIndex, match.start()));
      // add transition
      var ind = match[1] != null ? 1 : match[3] != null ? 3 : 5;
      sb.add("${match[ind]}-${match[ind+1]}");
      // update index
      lastIndex = match.end();
    }
    // add remaining
    sb.add(str.substring(lastIndex));
    return sb.toString().toLowerCase();
  }

  /**
   * Utility function for rendering numbers to strings at a precision of
   * up to 5 fractional digits.
   */
  static String formatNumber(num number) {
    String ret = ((number * 100000).round() / 100000).toString();
    // TODO do this better
    // hack for numbers that round to integers
    if(ret.endsWith(".0")) {
      return ret.substring(0, ret.length - 2);
    }
    return ret;
  }
}
