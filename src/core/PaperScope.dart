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
 * @name PaperScope
 *
 * @class The {@code PaperScope} class represents the scope associated with a
 * Paper context. When working with PaperScript, these scopes are automatically
 * created for us, and through clever scoping the properties and methods of the
 * active scope seem to become part of the global scope.
 *
 * When working with normal JavaScript code, {@code PaperScope} objects need to
 * be manually created and handled.
 *
 * Paper classes can only be accessed through {@code PaperScope} objects. Thus
 * in PaperScript they are global, while in JavaScript, they are available on
 * the global {@link paper} object. For JavaScript you can use
 * {@link PaperScope#install(scope) } to install the Paper classes and objects
 * on the global scope. Note that when working with more than one scope, this
 * still works for classes, but not for objects like {@link PaperScope#project},
 * since they are not updated in the injected scope if scopes are switched.
 *
 * The global {@link paper} object is simply a reference to the currently active
 * {@code PaperScope}.
 */
class PaperScope {

  /**
   * Creates a PaperScope object.
   *
   * @name PaperScope#initialize
   * @function
   */
  PaperScope(script) {
    // script is only used internally, when creating scopes for PaperScript.
    // Whenever a PaperScope is created, it automatically becomes the active
    // one.
    paper = this;
    // Assign an id to this canvas that's either extracted from the script
    // or automatically generated.
    _id = script && (script.getAttribute('id') || script.src)
        || ('paperscope-' + (PaperScope._id++));
    // Make sure the script tag also has this id now. If it already had an
    // id, we're not changing it, since it's the first option we're
    // trying to get an id from above.
    if (script)
      script.setAttribute('id', _id);
    PaperScope._scopes[_id] = this;
  }

  /**
   * The version of Paper.js, as a float number.
   *
   * @type Number
   */
  version: /*#=*/ options.version,

  /**
   * The currently active project.
   * @name PaperScope#project
   * @type Project
   */
  Project project = null;

  /**
   * The list of all open projects within the current Paper.js context.
   * @name PaperScope#projects
   * @type Project[]
   */
  List<Project> projects = [];

  /**
   * The reference to the active project's view.
   * @type View
   * @bean
   */
  View getView() {
    return project.view;
  }

  /**
   * The reference to the active tool.
   * @type Tool
   * @bean
   */
  Tool _tool = null;
  Tool getTool() {
    // If no tool exists yet but one is requested, produce it now on the fly
    // so it can be used in PaperScript.
    if (_tool == null)
      _tool = new Tool();
    return _tool;
   }
  Tool get tool => getTool();

  /**
   * The list of available tools.
   * @name PaperScope#tools
   * @type Tool[]
   */
  List<Tool> tools = [];

  evaluate(code) {
    var res = PaperScript.evaluate(code, this);
    View.updateFocus();
    return res;
  }

  /**
   * Injects the paper scope into any other given scope. Can be used for
   * examle to inject the currently active PaperScope into the window's global
   * scope, to emulate PaperScript-style globally accessible Paper classes and
   * objects:
   *
   * @example
   * paper.install(window);
   */
  install(scope) {
    // Define project, view and tool as getters that redirect to these
    // values on the PaperScope, so they are kept up to date
    var that = this;
    Base.each(['project', 'view', 'tool'], function(key) {
      Base.define(scope, key, {
        configurable: true,
        writable: true,
        get: function() {
          return that[key];
        }
      });
    });
    // Copy over all fields from this scope to the destination.
    // Do not use Base.each, since we also want to enumerate over
    // fields on PaperScope.prototype, e.g. all classes
    for (var key in this) {
      if (!/^(version|_id|load)/.test(key) && !(key in scope))
        scope[key] = this[key];
    }
  }

  /**
   * Sets up an empty project for us. If a canvas is provided, it also creates
   * a {@link View} for it, both linked to this scope.
   *
   * @param {HTMLCanvasElement} canvas The canvas this scope should be
   * associated with.
   */
  setup(canvas) {
    // Create an empty project for the scope.
    // Make sure this is the active scope, so the created project and view
    // are automatically associated with it.
    paper = this;
    project = new Project(canvas);
  }

  clear() {
    // Remove all projects, views and tools.
    // This also removes the installed event handlers.
    for (var i = this.projects.length - 1; i >= 0; i--)
      this.projects[i].remove();
    for (var i = this.tools.length - 1; i >= 0; i--)
      this.tools[i].remove();
  }

  remove() {
    clear();
    delete PaperScope._scopes[_id];
  }
  
  static Map _scopes = {};
  static int id = 0;

  /**
   * Retrieves a PaperScope object with the given id or associated with
   * the passed canvas element.
   *
   * @param id
   */  
  static PaperScope get(id) {
    // If a script tag is passed, get the id from it
    if(id is Element) {
      id = id.attributes["id"];
    }
    return _scopes[id];
  }
}
