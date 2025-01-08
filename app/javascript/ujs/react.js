/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let reactUjs;
const $ = require('jquery');
const React = require('react');
const ReactDOM = require('react-dom');
const f = require('active-lodash');
const url = require('url');
const UI = require('../react/index.js');

// UJS for React Views (and Decorators)
//
// Each Key in Map below defines a (self-contained) init function for a Component.
// Targets are DOM nodes with <data-react-class='ExampleComponent'>.
// Function recieves node data as first argument, second argument is a
// callback which can be called with a React Element replacing the targeted node.

const initByClass = {
  'Views.My.Uploader'(data, callback){
    const MediaEntries = require('../models/media-entries.js');
    const Uploader = require('../react/views/My/Uploader.cjsx');
    const props = f.set(data.reactProps, 'appCollection', (new MediaEntries()));
    return callback(React.createElement(Uploader, props));
  }
};


module.exports = (reactUjs=() => $('[data-react-class]').each(function(){
  const element = this;
  const data = $(element).data();
  const componentClass = (data.reactClass || '').replace(/^UI./, '');
  // use custom initializer, or…
  let init = initByClass[componentClass];
  // auto-init (for any components that simply render from props):
  if (!init) { init = function(data, callback){
    const component = f.get(UI, componentClass);
    if (!component) { throw new Error(`No such component: \`${componentClass}\`!`); }
    return callback(React.createElement(component, data.reactProps));
  }; }

  if (f.isFunction(init)) {
    return init(data, enhanced => ReactDOM.render(enhanced, element));
  }
}));
