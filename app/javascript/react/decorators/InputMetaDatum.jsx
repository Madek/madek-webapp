/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const MadekPropTypes = require('../lib/madek-prop-types.js')
const Text = require('../lib/forms/input-text-async.cjsx')
const InputTextDate = require('../lib/forms/InputTextDate.js').default
const InputKeywords = require('../lib/forms/input-keywords.cjsx')
const InputPeople = require('../lib/forms/input-people.jsx')
const InputJsonText = require('../lib/forms/InputJsonText.js').default
const InputMediaEntry = require('../lib/forms/InputMediaEntry').default

module.exports = React.createClass({
  displayName: 'InputMetaDatum',
  propTypes: {
    id: React.PropTypes.string.isRequired,
    name: React.PropTypes.string.isRequired
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { id, name, model } = param
    const resourceType = f.last(this.props.metaKey.value_type.split('::'))
    const multiple = (() => {
      switch (resourceType) {
        case 'Text':
        case 'TextDate':
        case 'JSON':
        case 'MediaEntry':
          return false
        case 'Keywords':
          return model.multiple
        default:
          return true
      }
    })()

    const values = f.map(model.values, value => value)

    if (resourceType === 'Text') {
      return (
        <Text
          metaKey={this.props.metaKey}
          name={name}
          values={values}
          onChange={this.props.onChange}
          subForms={this.props.subForms}
        />
      )
    } else if (resourceType === 'TextDate') {
      return (
        <InputTextDate
          onChange={this.props.onChange}
          id={id}
          name={name}
          values={values}
          subForms={this.props.subForms}
        />
      )
    } else if (resourceType === 'JSON') {
      return (
        <InputJsonText
          metaKey={this.props.metaKey}
          id={id}
          name={name}
          values={values}
          onChange={this.props.onChange}
          subForms={this.props.subForms}
        />
      )
    } else if (f.includes(['People', 'Roles'], resourceType)) {
      return (
        <InputPeople
          metaKey={this.props.metaKey}
          onChange={this.props.onChange}
          name={name}
          multiple={multiple}
          values={values}
          subForms={this.props.subForms}
          withRoles={resourceType === 'Roles'}
        />
      )
    } else if (resourceType === 'Keywords') {
      return (
        <InputKeywords
          meta_key={this.props.metaKey}
          keywords={this.props.metaKey.keywords}
          show_checkboxes={this.props.metaKey.show_checkboxes}
          onChange={this.props.onChange}
          id={id}
          name={name}
          multiple={multiple}
          values={values}
          metaKey={this.props.metaKey}
          contextKey={this.props.contextKey}
          subForms={this.props.subForms}
        />
      )
    } else if (resourceType === 'MediaEntry') {
      return (
        <InputMediaEntry
          meta_key={this.props.metaKey}
          onChange={this.props.onChange}
          id={id}
          name={name}
          values={values}
          subForms={this.props.subForms}
        />
      )
    } else {
      console.error('Unknown MetaDatum type!', resourceType)
      return null
    }
  }
})
