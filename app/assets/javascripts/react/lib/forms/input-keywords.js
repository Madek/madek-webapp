const React = require('react')
const f = require('active-lodash')
const MadekPropTypes = require('../madek-prop-types.coffee')
const InputResources = require('./input-resources.js')

class InputKeywords extends React.Component {
  static displayName = 'InputKeywords'

  static propTypes = {
    name: React.PropTypes.string.isRequired,
    values: React.PropTypes.array.isRequired,
    meta_key: MadekPropTypes.metaKey.isRequired,
    show_checkboxes: React.PropTypes.bool.isRequired,
    keywords: React.PropTypes.arrayOf(MadekPropTypes.keyword)
  }

  _onChange = event => {
    if (this.props.onChange) {
      const uuid = event.target.value
      const checked = event.target.checked
      let values

      if (this.props.multiple) {
        // In any case remove the element first.
        values = f.filter(this.props.values, value => value.uuid !== uuid)
        // Then add it again if needed.
        if (checked) {
          values.push({ uuid: uuid })
        }
      } else {
        if (this.props.values.length > 0 && this.props.values[0].uuid === uuid) {
          values = []
        } else {
          values = [{ uuid: uuid }]
        }
      }

      this.props.onChange(values)
    }
  }

  render() {
    const { name, values, meta_key, keywords, show_checkboxes, multiple } = this.props

    // - "keywords" might be given as possible values
    // - for fixed selections show checkboxes (with possible values)
    //   otherwise the show autocompleter (prefilled with pos. values if given)

    // show an autocomplete:
    if (!show_checkboxes) {
      const params = { meta_key_id: meta_key.uuid }
      let autocompleteConfig
      // prefill the autocomplete if data was given:
      if (keywords) {
        autocompleteConfig = { minLength: 0, localData: keywords }
      }

      return (
        <InputResources
          {...this.props}
          resourceType="Keywords"
          searchParams={params}
          extensible={meta_key.is_extensible}
          autocompleteConfig={autocompleteConfig}
        />
      )
    } else {
      // is show_checkboxes — checkboxes:
      return (
        <div className="form-item">
          {/* hidden field needed for broken Rails form serialization */}
          <input type="hidden" name={name} value="" />

          {keywords.map(kw => {
            // determine initial checked status according to current values:
            const isInitiallySelected = f.any(values, { uuid: kw.uuid })

            return (
              <label className="col2of6" key={kw.uuid}>
                <input
                  type={multiple ? 'checkbox' : 'radio'}
                  onChange={this.props.onChange ? this._onChange : null}
                  onClick={this.props.onChange && !multiple ? this._onChange : null}
                  name={name}
                  checked={isInitiallySelected}
                  value={kw.uuid}
                />
                {kw.label}
              </label>
            )
          })}
          {this.props.subForms}
        </div>
      )
    }
  }
}

module.exports = InputKeywords
