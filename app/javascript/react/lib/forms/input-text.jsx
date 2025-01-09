/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const InputFieldText = require('../forms/input-field-text.cjsx')

module.exports = React.createClass({
  displayName: 'InputText',
  propTypes: {
    name: React.PropTypes.string.isRequired,
    values: React.PropTypes.array.isRequired,
    active: React.PropTypes.bool.isRequired,
    multiple: React.PropTypes.bool.isRequired
  },

  render(param) {
    // always show current values first
    // if there aren't any OR multiple can be added, add an empty input
    if (param == null) {
      param = this.props
    }
    const { get, name, values, active, multiple } = param
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
        ) : (
          undefined
        )}
        {this.props.subForms}
      </div>
    )
  }
})
