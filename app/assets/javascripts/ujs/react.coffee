$ = require('jquery')
React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
url = require('url')
UI = require('../react/index.coffee')

# UJS for React Views (and Decorators)
#
# Each Key in Map below defines a (self-contained) init function for a Component.
# Targets are DOM nodes with <data-react-class='ExampleComponent'>.
# Function recieves node data as first argument, second argument is a
# callback which can be called with a React Element replacing the targeted node.

initByClass =
  # # TMP: for every single md. will get list from entry later
  # MetaDatumEdit: (data, callback)->
  #   MetaDatum = require('../models/meta-datum.coffee')
  #   MetaDataEdit = require('../react/meta-datum-edit.cjsx')
  #
  #   unless (MetaDatumClass = MetaDatum[f.last(data.metaDatumType.split('::'))])?
  #     throw new Error 'invalid MetaDatum subclass!'
  #
  #   md = new MetaDatumClass(url: data.metaDatumUrl)
  #   md.fetch
  #     error: (model, response, options)->
  #       console.error("Could not fetch MetaDatum <#{model.url}>", response)
  #     success: (model, response, options)->
  #       callback(React.createElement(MetaDataEdit, metaDatum: md))

  'Views.My.Uploader': (data, callback)->
    MediaEntries = require('../models/media-entries.coffee')
    Uploader = require('../react/views/My/Uploader.cjsx')
    props = f.set(data.reactProps, 'appCollection', (new MediaEntries()))
    callback(React.createElement(Uploader, props))


module.exports = reactUjs=()->
  $('[data-react-class]').each ()->
    element = this
    data = $(element).data()
    componentClass = f.last(data.reactClass.split('UI.'))
    # use custom initializer, or…
    init = initByClass[componentClass]
    # auto-init (for any components that simply render from props):
    init ||= (data, callback)->
      component = f.get(UI, componentClass)
      throw new Error "No such component: `#{componentClass}`!" unless component
      callback(React.createElement(component, data.reactProps))

    if f.isFunction(init)
      return init(data, (enhanced)-> ReactDOM.render(enhanced, element))
