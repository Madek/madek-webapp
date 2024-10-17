React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../madek-prop-types.coffee')
InputResources = require('./input-resources.cjsx')
jQuery = require('jquery')

autoCompleteSuggestionRenderer = (person) ->
  jQuery("<div>")
    .addClass("ui-autocomplete__person-suggestion")
    .append($("<div>").addClass("ui-autocomplete__person-suggestion__col1").text(person.name))
    .append($("<div>").addClass("ui-autocomplete__person-suggestion__col2").text(person.identification_info))

module.exports = React.createClass
  displayName: 'InputPeople'
  render: ({metaKey} = @props)->
    <InputResources {...@props}
      resourceType='People'
      searchParams={{meta_key_id: metaKey.uuid}}
      allowedTypes={metaKey.allowed_people_subtypes}
      autoCompleteSuggestionRenderer={autoCompleteSuggestionRenderer}
    />
