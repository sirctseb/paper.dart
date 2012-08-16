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

class Callback {
  Map _this_name;
  Map _handlers;
  Map _eventTypes;
  Map _events;

  Callback() {
    _this_name = {};
  }
  Callback attach(/*Map | String*/ type, [func]) {
    // If an object literal is passed, attach all callbacks defined in it
    if (type is! String) {
      return Base.each(type, (value, key) {
        attach(key, value);
      }, this);
    }
    var entry = _eventTypes[type];
    if (entry == null)
      return this;
    var handlers = _handlers != null ? _handlers : {};
    handlers = handlers[type] != null ? handlers[type] : [];
    if (handlers.indexOf(func) == -1) { // Not added yet, add it now
      handlers.add(func);
      // See if this is the first handler that we're attaching, and 
      // call install if defined.
      if (entry.install != null && handlers.length == 1)
        entry.install(type);
    }
    return this;
  }

  Callback detach(/*Map | String*/type, [func]) {
    // If an object literal is passed, detach all callbacks defined in it
    if (type is! String) {
      return Base.each(type, (value, key) {
        detach(key, value);
      }, this);
    }
    var entry = _eventTypes[type];
    var handlers = this._handlers != null ? this._handlers[type] : null;
    int index;
    if (entry != null && handlers != null) {
      // See if this is the last handler that we're detaching (or if we
      // are detaching all handlers), and call uninstall if defined.
      if (func== null || (index = handlers.indexOf(func)) != -1
          && handlers.length == 1) {
        if (entry.uninstall != null)
          entry.uninstall(type);
        _handlers.remove(type);
      } else if (index != -1) {
        // Just remove this one handler
        handlers.removeRange(index, 1);
      }
    }
    return this;
  }

  bool fire(type, event) {
    // Returns true if fired, false otherwise
    var handlers = _handlers != null ? _handlers[type] : null;
    if (handlers == null)
      return false;
    Base.each(handlers, (func) {
      // When the handler function returns false, prevent the default
      // behaviour of the event by calling stop() on it
      // PORT: Add to Sg
      if (func(event) == false && event != null && event.stop != null)
        event.stop();
    }, this);
    return true;
  }

  bool responds(type) {
    return _handlers != null && _handlers[type] != null;
  }

  // this installs set/get methods and properties on the object
  // for each event. this is not possible in dart, so instead,
  // we will define one method that takes the event name and
  // does the work, and the individual setter/getters will have
  // to be written individually and call these
  getEvent(String eventType) {
    return _this_name[eventType];
  }
  setEvent(String eventType, [func]) {
    if(funct != null) {
      attach(eventType, func);
    } else if(_this_name[eventType] != null) {
      detach(eventType, _this_name[eventType]);
    }
    _this_name[eventType] = func;
  }

  /*statics: {
    inject: function() {
      for (var i = 0, l = arguments.length; i < l; i++) {
        var src = arguments[i],
          events = src._events;
        if (events) {
          // events can either be an object literal or an array of
          // strings describing the on*-names.
          // We need to map lowercased event types to the event
          // entries represented by these on*-names in _events.
          var types = {};
          Base.each(events, function(entry, key) {
            var isString = typeof entry === 'string',
              name = isString ? entry : key,
              part = Base.capitalize(name),
              type = name.substring(2).toLowerCase();
            // Map the event type name to the event entry.
            types[type] = isString ? {} : entry;
            // Create getters and setters for the property
            // with the on*-name name:
            name = '_' + name;
            src['get' + part] = function() {
              return this[name];
            };
            src['set' + part] = function(func) {
              if (func) {
                this.attach(type, func);
              } else if (this[name]) {
                this.detach(type, this[name]);
              }
              this[name] = func;
            };
          });
          src._eventTypes = types;
        }
        this.base(src);
      }
      return this;
    }
  }*/
}
