const React = require('react')
const InputResources = require('./input-resources.jsx')
const jQuery = require('jquery')

const autoCompleteSuggestionRenderer = person => {
  return jQuery('<div>')
    .addClass('ui-autocomplete__person-suggestion')
    .append(
      jQuery('<div>')
        .addClass('ui-autocomplete__person-suggestion__col1')
        .text(person.name)
    )
    .append(
      jQuery('<div>')
        .addClass('ui-autocomplete__person-suggestion__col2')
        .text(person.info)
    )
}

// eslint-disable-next-line react/no-deprecated
module.exports = React.createClass({
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
