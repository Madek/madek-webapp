React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../madek-prop-types.coffee')
Text = require('./input-text-async.cjsx')
InputResources = require('./input-resources.cjsx')
InputTextDate = require('./InputTextDate.js').default
InputKeywords = require('./input-keywords.cjsx')

module.exports =
  Text: Text
  TextDate: InputTextDate

  People: React.createClass
    displayName: 'InputPeople'
    render: ({get} = @props)->
      {meta_key} = get
      <InputResources {...@props}
        resourceType='People'
        searchParams={{meta_key_id: meta_key.uuid}}
        allowedTypes={meta_key.allowed_people_subtypes}
      />

  Licenses: React.createClass
    displayName: 'InputLicenses'
    render: ()->
      <InputResources {...@props} resourceType='Licenses'/>

  Keywords: InputKeywords
