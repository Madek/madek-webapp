/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const InputFieldText = require('../forms/input-field-text.jsx')

module.exports = React.createClass({
  displayName: 'InputTextAsync',
  propTypes: {
    name: React.PropTypes.string.isRequired,
    values: React.PropTypes.array.isRequired
  },

  getInitialState() {
    return {
      values: []
    }
  },

  componentWillMount() {
    return this.setState({ values: this.props.values })
  },

  _onChange(event) {
    const newValues = [event.target.value]
    this.setState({ values: newValues })

    if (this.props.onChange) {
      return this.props.onChange(newValues)
    }
  },

  render(param) {
    let value
    if (param == null) {
      param = this.props
    }
    const { metaKey, name, values } = param
    return (
      <div className="form-item">
        <div className="form-item-values">
          {
            (this.state.values.length === 0 ? (value = '') : (value = this.state.values[0]),
            (
              <InputFieldText
                onChange={this._onChange}
                name={name}
                value={value}
                key={metaKey.uuid}
                metaKey={metaKey}
              />
            ))
          }
        </div>
        {this.props.subForms}
      </div>
    )
  }
})
