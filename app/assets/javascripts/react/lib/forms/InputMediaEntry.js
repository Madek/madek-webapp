import React from 'react'
import PropTypes from 'prop-types'
import f from 'lodash'
import t from '../../../lib/i18n-translate.js'

class InputMediaEntry extends React.Component {
  constructor(props) {
    super(props)

    const uuid = f.get(props.values, '0.0.uuid', '')
    const description = f.get(props.values, '0.1')
    const uuidError = !this.isValidUuid(uuid)

    this.state = {
      values: { uuid, description },
      uuidError
    }

    this.handleResourceIdChange = this.handleResourceIdChange.bind(this)
    this.handleDescriptionChange = this.handleDescriptionChange.bind(this)
  }

  prepareValue() {
    const { values } = this.state
    return `${values.uuid || ''};${values.description || ''}`
  }

  isValidUuid(uuid) {
    return (
      (f.isString(uuid) && uuid.length === 0) ||
      /^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{2})([0-9a-f]{2})-([0-9a-f]{12})$/.test(
        uuid
      )
    )
  }

  handleResourceIdChange(e) {
    const values = f.extend({}, this.state.values, { uuid: e.target.value })
    const uuidError = !this.isValidUuid(values.uuid)

    this.setState({ values, uuidError })
    this.props.onChange([[{ uuid: values.uuid }, values.description]])
  }

  handleDescriptionChange(e) {
    const values = f.extend({}, this.state.values, { description: e.target.value })

    this.setState({ values })
    this.props.onChange([[{ uuid: values.uuid }, values.description]])
  }

  render({ name, isPersisted } = this.props) {
    const {
      uuidError,
      values: { uuid, description }
    } = this.state

    return (
      <div className="form-item">
        <input type="hidden" name={name} value={this.prepareValue()} />
        <label>
          {t('meta_datum_media_entry_label_id')}
          <input
            type="text"
            value={uuid || ''}
            className="block"
            onChange={this.handleResourceIdChange}
          />
        </label>
        {uuidError && (
          <p className="ui-alert error">{t('meta_datum_media_entry_err_uuid_invalid')}</p>
        )}
        <label>
          {t('meta_datum_media_entry_label_string')}
          <input
            type="text"
            value={description || ''}
            className="block"
            onChange={this.handleDescriptionChange}
          />
        </label>
      </div>
    )
  }
}

InputMediaEntry.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  values: PropTypes.arrayOf(PropTypes.array).isRequired,
  onChange: PropTypes.func.isRequired
}

export default InputMediaEntry
