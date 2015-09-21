$ = require('jquery')
React = require('react')
f = require('../lib/fun.coffee')

# UJS for Models with React Views
#
# Each Key in Map below defines a (self-contained) init function for a Component.
# Targets are DOM nodes with <data-react-class='ExampleComponent'>.
# Function recieves node data as first argument, second argument is a
# callback which can be called with a React Element replacing the targeted node.

initByClass =
  # TMP: for every single md. will get list from entry later
  MetaDatumEdit: (data, callback)->
    MetaDatum = require('../models/meta-datum.coffee')
    MetaDataEdit = require('../react/meta-datum-edit.cjsx')

    md = new MetaDatum(url: data.metaDatumUrl)
    md.fetch
      error: (model, response, options)->
        console.error("Could not fetch MetaDatum <#{url}>", response)
      success: (model, response, options)->
        callback(React.createElement(MetaDataEdit, metaDatum: md))

  RightsManagement: (data, callback)->
    history = require('../lib/history.coffee')
    Permissions = require('../models/media-entry/permissions.coffee')
    RightsManagement = require('../react/rights-management.cjsx')

    if ({permissions} = data.reactProps)
      model = new Permissions(permissions)
      window.perm = model # TMP: dev

      callback React.createElement RightsManagement,
        permissions: model
        callbacks:
          onStartEditing: ()->
            history.goTo f.url.resolve(model.url, 'permissions/edit')
          onStopEditing: ()->
            history.goTo model.url

module.exports = reactUjs=()->
  $('[data-react-class]').each ()->
    element = this
    data = $(element).data()
    if f.isFunction(init = initByClass[f.last(data.reactClass.split('UI.'))])
      init(data, (enhanced)-> React.render(enhanced, element))
