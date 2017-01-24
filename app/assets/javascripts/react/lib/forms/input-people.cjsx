React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../madek-prop-types.coffee')
Text = require('./input-text-async.cjsx')
InputResources = require('./input-resources.cjsx')

module.exports = React.createClass
  displayName: 'InputPeople'
  render: ({get} = @props)->
    {meta_key} = get
    <InputResources {...@props}
      resourceType='People'
      searchParams={{meta_key_id: meta_key.uuid}}
      allowedTypes={meta_key.allowed_people_subtypes}
    />
