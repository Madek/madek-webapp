React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../madek-prop-types.coffee')
Text = require('./input-text-async.cjsx')
InputResources = require('./input-resources.cjsx')

module.exports = React.createClass
  displayName: 'InputLicenses'
  render: ()->
    <InputResources {...@props} resourceType='Licenses'/>
