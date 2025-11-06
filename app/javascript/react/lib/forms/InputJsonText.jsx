// Input for MetaDatum::JSON.
// * Internally we handle it as normal text, so while editing everything stays as the user entered it, including whitespace etc.
// * Parsing/Formatting is only done
//    a) when the value comes as an object from DB and
//    b) to check for errors

import React, { Component } from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import first from 'lodash/first'
import isString from 'lodash/isString'
import isPlainObject from 'lodash/isPlainObject'
import t from '../../../lib/i18n-translate.js'

class InputJsonText extends Component {
  constructor(props) {
    super(props)
    const value = ensureText(first(props.values))
    const jsonError = findJSONError(value)
    this.state = { isClient: true, jsonError, value }
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    const value = ensureText(first(nextProps.values))
    const jsonError = findJSONError(value)
    this.setState({ value, jsonError })
  }

  _onInputChange(string) {
    const jsonError = findJSONError(string)
    this.setState({ value: string, jsonError })
    this.props.onChange([string])
  }

  render({ props, state } = this) {
    const { id, name } = props
    const { value, jsonError } = state
    const stringifiedValue = formatValue(value)

    return (
      <div className="form-item">
        <textarea
          id={id}
          name={name}
          className={cx('block code', { error: !!jsonError })}
          style={{ textIndent: 0, paddingLeft: '0.5rem' }}
          onChange={e => this._onInputChange(e.target.value)}
          value={stringifiedValue || ''}
        />
        {!!jsonError && (
          <p className="ui-alert error">
            {t('meta_data_input_json_err_prefix')}
            {jsonError}
          </p>
        )}
      </div>
    )
  }
}

InputJsonText.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  value: PropTypes.arrayOf(
    PropTypes.oneOfType([PropTypes.string.isRequired, PropTypes.object.isRequired])
  ),
  onChange: PropTypes.func.isRequired
}

InputJsonText.defaultProps = {
  onChange: () => {}
}

export default InputJsonText

function formatValue(value) {
  if (isString(value)) return value
  try {
    return JSON.stringify(value)

    // eslint-disable-next-line no-unused-vars
  } catch (e) {
    return String(value)
  }
}

function findJSONError(val) {
  if (!val || !isString(val)) return false
  let parsed
  try {
    parsed = JSON.parse(val)
  } catch (e) {
    return String(e).replace('SyntaxError: JSON.parse: ', '')
  }
  if (!isPlainObject(parsed)) {
    return t('meta_data_input_json_err_no_object')
  }
}

// only used for data that is passed to us, we dont expect errors then.
function ensureText(value) {
  if (!value || isString(value)) return value
  try {
    return JSON.stringify(value, 0, 2)
    // eslint-disable-next-line no-unused-vars
  } catch (e) {
    return String(value)
  }
}
