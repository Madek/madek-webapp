$ = require('jquery')
React = require('react')
f = require('active-lodash')
url = require('url')
ReactDOM = require('react-dom')

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

    unless (MetaDatumClass = MetaDatum[f.last(data.metaDatumType.split('::'))])?
      throw new Error 'invalid MetaDatum subclass!'

    md = new MetaDatumClass(url: data.metaDatumUrl)
    md.fetch
      error: (model, response, options)->
        console.error("Could not fetch MetaDatum <#{model.url}>", response)
      success: (model, response, options)->
        callback(React.createElement(MetaDataEdit, metaDatum: md))

  RightsManagement: (data, callback)->
    router = require('../lib/router.coffee')
    Permissions = require('../models/media-entry/permissions.coffee')
    RightsManagement = require('../react/rights-management.cjsx')

    if ({permissions} = data.reactProps)
      model = new Permissions(permissions)
      edit_link = url.resolve(model.url, 'permissions/edit')
      callback React.createElement RightsManagement,
        permissions: model
        editUrl: edit_link
        router: router

  FormResourceMetaData: (data, callback)->
    FormResourceMetaData = require('../react/form-resource-meta-data.cjsx')
    callback React.createElement FormResourceMetaData, data.reactProps


module.exports = reactUjs=()->
  $('[data-react-class]').each ()->
    element = this
    data = $(element).data()
    if f.isFunction(init = initByClass[f.last(data.reactClass.split('UI.'))])
      init(data, (enhanced)-> ReactDOM.render(enhanced, element))
