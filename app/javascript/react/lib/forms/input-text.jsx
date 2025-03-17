/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import InputFieldText from '../forms/input-field-text.jsx'

module.exports = createReactClass({
  displayName: 'InputText',
  propTypes: {
    name: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
    active: PropTypes.bool.isRequired,
    multiple: PropTypes.bool.isRequired
  },

  render(param) {
    // always show current values first
    // if there aren't any OR multiple can be added, add an empty input
    if (param == null) {
      param = this.props
    }
    const { name, values, multiple } = param
    const shouldAddValue = f.isEmpty(values) || multiple

    return (
      <div className="form-item">
        <div className="form-item-values">
          {values.map((textValue, n) => (
            <InputFieldText name={name} value={textValue} key={n} />
          ))}
        </div>
        {shouldAddValue ? (
          <div className="form-item-add">
            <InputFieldText name={name} />
          </div>
        ) : undefined}
        {this.props.subForms}
      </div>
    )
  }
})
