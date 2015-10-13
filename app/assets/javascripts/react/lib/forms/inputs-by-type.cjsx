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

  # Keywords: React.createClass
  #   propTypes:
  #     metaKey: MadekPropTypes.metaKey.isRequired
  #   displayName: 'InputKeywords'
  #   render: ()->
  #     <MultiSelectInput {...@props} resourceType='Keywords'/>
