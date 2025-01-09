/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const css = require('classnames')
const ui = require('../../lib/ui.js')
const MadekPropTypes = require('../../lib/madek-prop-types.js')

const loadXhr = require('../../../lib/load-xhr.js')

const Icon = require('../Icon.cjsx')
const Link = require('../Link.cjsx')
const Preloader = require('../Preloader.cjsx')

let jQuery = null

module.exports = React.createClass({
  displayName: 'UserFilter',

  componentDidMount() {
    jQuery = require('jquery')
    require('@eins78/typeahead.js/dist/typeahead.jquery.js')

    const domNode = ReactDOM.findDOMNode(this.refs.testInput)
    const jNode = jQuery(domNode)
    const typeahead = jNode.typeahead(
      {
        hint: false,
        highlight: true,
        minLength: 0,
        classNames: {
          wrapper: 'ui-autocomplete-holder',
          input: 'ui-typeahead-input',
          hint: 'ui-autocomplete-hint',
          menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width ui-autocomplete-top-margin-2',
          cursor: 'ui-autocomplete-cursor',
          suggestion: 'ui-menu-item'
        }
      },
      {
        name: 'users',
        templates: {
          suggestion(value) {
            return `<div class="ui-autocomplete-override-sidebar">${value.label}</div>`
          }
        },
        limit: Number.MAX_SAFE_INTEGER,
        source: (term, callback) => {
          const result = (() => {
            if (term.length > 0) {
              const termLower = term.toLowerCase()

              return f.sortBy(
                f.filter(
                  this.props.node.children,
                  user => !user.selected && user.label.toLowerCase().indexOf(termLower) >= 0
                )
              )
            } else {
              return f.sortBy(f.filter(this.props.node.children, user => !user.selected), 'label')
            }
          })()

          return callback(result)
        }
      }
    )

    const onSelect = value => {
      return this.props.userChanged(value, 'add')
    }

    return typeahead.on('typeahead:select typeahead:autocomplete', function(event, item) {
      event.preventDefault()
      jNode.typeahead('val', '')
      return onSelect(item)
    })
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { node, placeholder } = param
    const selection = f.filter(node.children, 'selected')

    const hasMore = f.size(selection) < f.size(node.children)

    const clear = (selected, event) => {
      event.preventDefault()
      return this.props.userChanged(selected, 'remove')
    }

    return (
      <ul className={this.props.togglebodyClass}>
        {f.map(selection, selected =>
          React.createElement(
            'li',
            {
              key: `uuid_${selected.uuid}`,
              className: css('ui-side-filter-lvl3-item', { active: true })
            },
            React.createElement(
              'a',
              {
                className: 'link weak ui-link',
                onClick(event) {
                  return clear(selected, event)
                }
              },
              selected.label,
              selected.label ? (
                <span className="ui-lvl3-item-count">{selected.count}</span>
              ) : (
                undefined
              )
            )
          )
        )}
        {hasMore && (
          <li
            key="input"
            className={css('ui-side-filter-lvl3-item', { mtx: selection.length > 0 })}>
            <div style={{ position: 'relative' }}>
              <input
                ref="testInput"
                type="text"
                placeholder={placeholder}
                className="typeahead block"
              />
            </div>
          </li>
        )}
      </ul>
    )
  }
})
