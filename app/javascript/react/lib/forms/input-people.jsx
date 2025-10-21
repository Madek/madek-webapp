import React from 'react'
import InputResources from './input-resources.jsx'
import jQuery from 'jquery'

const autoCompleteSuggestionRenderer = person => {
  const $nameDiv = jQuery('<div>')
    .addClass('ui-autocomplete__person-suggestion__col1')
    .text(person.name)

  const $infoDiv = jQuery('<div>').addClass('ui-autocomplete__person-suggestion__col2')
  const infos = person.info || []
  $.each(infos, function (index, value) {
    $infoDiv.append($('<span></span>').text(value))
    if (index < infos.length - 1) {
      $infoDiv.append(', ')
    }
  })
  return jQuery('<div>')
    .addClass('ui-autocomplete__person-suggestion')
    .append($nameDiv)
    .append($infoDiv)
}

const InputPeople = ({ metaKey, ...rest }) => {
  return (
    <InputResources
      {...rest}
      metaKey={metaKey}
      resourceType="People"
      searchParams={{ meta_key_id: metaKey.uuid }}
      allowedTypes={metaKey.allowed_people_subtypes}
      autoCompleteSuggestionRenderer={autoCompleteSuggestionRenderer}
    />
  )
}

export default InputPeople
module.exports = InputPeople
