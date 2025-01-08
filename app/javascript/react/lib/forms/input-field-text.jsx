/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const classNames = require('classnames')
const _ = require('lodash')
const jQuery = require('jquery')

module.exports = React.createClass({
  displayName: 'InputFieldText',
  propTypes: {
    name: React.PropTypes.string,
    type: React.PropTypes.string,
    value: React.PropTypes.string,
    placeholder: React.PropTypes.string,
    className: React.PropTypes.string,
    onChange: React.PropTypes.func
  },

  setInputRef(element) {
    return (this.inputRef = element)
  },

  componentDidMount() {
    if (this.inputRef) {
      return this.initSuggestions()
    }
  },

  initSuggestions() {
    require('@eins78/typeahead.js/dist/typeahead.jquery.js')

    const $input = jQuery(this.inputRef)
    $input.typeahead(
      {
        minLength: 0,
        highlight: true,
        classNames: {
          // madek style:
          wrapper: 'ui-autocomplete-holder ui-autocomplete-position-relative',
          input: 'ui-typeahead-input',
          hint: 'ui-autocomplete-hint',
          menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width',
          cursor: 'ui-autocomplete-cursor',
          suggestion: 'ui-menu-item'
        }
      },
      {
        name: 'templates',
        source: (query, syncResults, asyncResults) => {
          return syncResults(this.suggestions())
        }
      }
    )
    if (this.props.onChange) {
      return $input.on('typeahead:select', event => this.props.onChange(event))
    }
  },

  suggestions() {
    return _.compact(
      _.concat(
        _.get(this.props, 'metaKey.copyright_notice_default_text', ''),
        _.get(this.props, 'metaKey.copyright_notice_templates', [])
      )
    )
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { name, type, value, placeholder, className, metaKey } = param
    const Element =
      metaKey && metaKey.text_type && metaKey.text_type === 'block' ? 'textarea' : 'input'

    const style = {
      textIndent: '0em',
      paddingLeft: '8px'
    }

    const commonProps = {
      name,
      placeholder,
      className: classNames(className, 'block')
    }

    if (this.props.onChange) {
      _.set(commonProps, 'onChange', this.props.onChange)
    }

    if (_.get(metaKey, 'uuid') === 'madek_core:copyright_notice') {
      const defaultValue = _.get(this.props, 'metaKey.copyright_notice_default_text', '')

      return (
        <input
          {...Object.assign(
            {
              ref: this.setInputRef,
              type: 'text',
              defaultValue: value || defaultValue,
              'data-autocomplete-for': name
            },
            commonProps
          )}
        />
      )
    } else {
      return (
        <Element
          {...Object.assign(
            {
              type: type || 'text',
              defaultValue: value || '',
              style: style
            },
            commonProps
          )}
        />
      )
    }
  }
})
