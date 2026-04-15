import React from 'react'
import InputResources from './input-resources.jsx'

const autoCompleteSuggestionRenderer = person => {
  const infos = person.info || []
  return (
    <div className="ui-autocomplete__person-suggestion">
      <div className="ui-autocomplete__person-suggestion__col1">{person.name}</div>
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
module.exports = InputPeople
