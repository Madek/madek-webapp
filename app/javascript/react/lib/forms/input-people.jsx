import React from 'react'
import InputResources from './input-resources.jsx'
import { markMatchingFragment } from '../typeahead-utils.js'

const autoCompleteSuggestionRenderer = (person, { /*isHighlighted, */ inputValue }) => {
  const infos = person.info || []
  return (
    <div className="ui-autocomplete__person-suggestion">
      <div className="ui-autocomplete__person-suggestion__col1">
        {markMatchingFragment(person.name, inputValue)}
      </div>
      <div className="ui-autocomplete__person-suggestion__col2">
        {infos.map((value, index) => (
          <React.Fragment key={index}>
            <span>{value}</span>
            {index < infos.length - 1 && ', '}
          </React.Fragment>
        ))}
      </div>
    </div>
  )
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
