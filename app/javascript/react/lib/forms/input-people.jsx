import React from 'react'
import createReactClass from 'create-react-class'
import InputResources from './input-resources.jsx'
import jQuery from 'jquery'

const autoCompleteSuggestionRenderer = person => {
  return jQuery('<div>')
    .addClass('ui-autocomplete__person-suggestion')
    .append(jQuery('<div>').addClass('ui-autocomplete__person-suggestion__col1').text(person.name))
    .append(jQuery('<div>').addClass('ui-autocomplete__person-suggestion__col2').text(person.info))
}

module.exports = createReactClass({
  displayName: 'InputPeople',
  render() {
    const { metaKey } = this.props
    return (
      <InputResources
        {...this.props}
        resourceType="People"
        searchParams={{ meta_key_id: metaKey.uuid }}
        allowedTypes={metaKey.allowed_people_subtypes}
        autoCompleteSuggestionRenderer={autoCompleteSuggestionRenderer}
      />
    )
  }
})
