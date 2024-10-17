const React = require('react')
const InputResources = require('./input-resources.js')

class InputPeople extends React.Component {
  render() {
    const { metaKey } = this.props
    return (
      <InputResources
        {...this.props}
        resourceType="People"
        searchParams={{ meta_key_id: metaKey.uuid }}
        allowedTypes={metaKey.allowed_people_subtypes}
      />
    )
  }
}

module.exports = InputPeople
