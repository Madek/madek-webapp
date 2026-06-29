/*
 * ujs/react.js
 * UJS for React Views (and Decorators)
 *
 * Each Key in Map below defines a (self-contained) init function for a Component.
 * Targets are DOM nodes with <data-react-class='ExampleComponent'>.
 * Function receives node data as first argument, second argument is a
 * callback which can be called with a React Element replacing the targeted node.
 */
import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import UI from '../react/index.js'

const initByClass = {
  'Views.My.Uploader'(data, callback) {
    const MediaEntries = require('../models/media-entries.js').default
    const Uploader = require('../react/views/My/Uploader.jsx').default

    const props = f.set(data.reactProps, 'appCollection', new MediaEntries())
    return callback(React.createElement(Uploader, props))
  }
}

export default () => {
  document.querySelectorAll('[data-react-class]').forEach(element => {
    // Read data-* attributes. Values are JSON-encoded by Rails.
    const data = {}
    for (const key of Object.keys(element.dataset)) {
      try {
        data[key] = JSON.parse(element.dataset[key])
      } catch (_) {
        data[key] = element.dataset[key]
      }
    }

    const componentClass = (data.reactClass || '').replace(/^UI./, '')
    // use custom initializer, or…
    let init = initByClass[componentClass]
    // auto-init (for any components that simply render from props):
    if (!init) {
      init = function (data, callback) {
        const component = f.get(UI, componentClass)
        if (!component) {
          throw new Error(`No such component: \`${componentClass}\`!`)
        }
        return callback(React.createElement(component, data.reactProps))
      }
    }

    if (f.isFunction(init)) {
      // eslint-disable-next-line react/no-render-return-value
      return init(data, enhanced => ReactDOM.render(enhanced, element))
    }
  })
}
