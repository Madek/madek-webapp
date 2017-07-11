React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../madek-prop-types.coffee')
InputResources = require('./input-resources.cjsx')

module.exports = React.createClass
  displayName: 'InputPeople'
  render: ({metaKey} = @props)->
    <InputResources {...@props}
      resourceType='People'
      searchParams={{meta_key_id: metaKey.uuid}}
      allowedTypes={metaKey.allowed_people_subtypes}
    />
