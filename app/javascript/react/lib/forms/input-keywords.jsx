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
import MadekPropTypes from '../madek-prop-types.js'
import InputResources from './input-resources.jsx'

module.exports = createReactClass({
  displayName: 'InputKeywords',
  propTypes: {
    name: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
    meta_key: MadekPropTypes.metaKey.isRequired,
    show_checkboxes: PropTypes.bool.isRequired,
    keywords: PropTypes.arrayOf(MadekPropTypes.keyword)
  },

  _onChange(event) {
    if (this.props.onChange) {
      let values
      const uuid = event.target.value
      const { checked } = event.target

      if (this.props.multiple) {
        // In any case remove the element first.
        values = f.filter(this.props.values, value => value.uuid !== uuid)
        // Then add it again if needed.
        if (checked) {
          values.push({ uuid })
        }
      } else {
        if (this.props.values.length > 0 && this.props.values[0].uuid === uuid) {
          values = []
        } else {
          values = [{ uuid }]
        }
      }

      return this.props.onChange(values)
    }
  },

  render(param) {
    // - "keywords" might be given as possible values
    // - for fixed selections show checkboxes (with possible values)
    //   otherwise the show autocompleter (prefilled with pos. values if given)

    // show an autocomplete:
    if (param == null) {
      param = this.props
    }
    const { name, values, meta_key, keywords, show_checkboxes, multiple } = param
    if (!show_checkboxes) {
      let autocompleteConfig
      const params = { meta_key_id: meta_key.uuid }
      // prefill the autocomplete if data was given:
      if (keywords) {
        autocompleteConfig = { minLength: 0, localData: keywords }
      }

      return (
        <InputResources
          {...Object.assign({}, this.props, {
            resourceType: 'Keywords',
            searchParams: params,
            extensible: meta_key.is_extensible,
            autocompleteConfig: autocompleteConfig
          })}
        />
      )
    } else {
      // is show_checkboxes — checkboxes:
      return (
        <div className="form-item">
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
})
