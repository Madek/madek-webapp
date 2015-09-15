$ = require('jquery')
React = require('react')
isFunction = require('lodash/lang/isFunction')

MetaDatum = require('../models/meta-datum.coffee')
MetaDataEdit = require('../react/meta-datum-edit.cjsx')

# TODO: init by (ampersand-)model, not by (react-)component (they have vendor ujs)
module.exports = reactUjs=()->
  $('[data-react-elm]').each ->
    element = this
    data = $(element).data()

    if isFunction(init = initByClass[data.reactElm])
      init(data, (enhanced)-> React.render(enhanced, element))

initByClass =
  # TMP: for every single md. will get list from entry later
  MetaDatumEdit: (data, callback)->
    md = new MetaDatum(url: data.metaDatumUrl)
    md.fetch
      error: (model, response, options)->
        console.error("Could not fetch MetaDatum <#{url}>", response)
      success: (model, response, options)->
        callback(React.createElement(MetaDataEdit, metaDatum: md))
