React = require('react')
MadekPropTypes = require('../madek-prop-types.coffee')
Text = require('./input-text.cjsx')
InputResources = require('./input-resources.cjsx')

module.exports =
  Text: Text
  TextDate: Text

  People: React.createClass
    displayName: 'InputPeople'
    render: ()->
      <InputResources {...@props} resourceType='People'/>

  Licenses: React.createClass
    displayName: 'InputLicenses'
    render: ()->
      <InputResources {...@props} resourceType='Licenses'/>

  Keywords: React.createClass
    propTypes:
      metaKey: MadekPropTypes.metaKey.isRequired
    displayName: 'InputKeywords'
    render: ({metaKey} = @props)->
      params = {meta_key_id: metaKey.uuid}
      <InputResources {...@props} resourceType='Keywords' searchParams={params}/>
