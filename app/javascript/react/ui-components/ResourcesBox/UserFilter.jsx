import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import cx from 'classnames'

let jQuery = null

class UserFilter extends React.Component {
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
              return f.sortBy(
                f.filter(this.props.node.children, user => !user.selected),
                'label'
              )
            }
          })()

          return callback(result)
        }
      }
    )

    const onSelect = value => {
      return this.props.userChanged(value, 'add')
    }

    return typeahead.on('typeahead:select typeahead:autocomplete', function (event, item) {
      event.preventDefault()
      jNode.typeahead('val', '')
      return onSelect(item)
    })
  }

  render() {
    const { node, placeholder } = this.props
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
              className: cx('ui-side-filter-lvl3-item', { active: true })
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
              ) : undefined
            )
          )
        )}
        {hasMore && (
          <li key="input" className={cx('ui-side-filter-lvl3-item', { mtx: selection.length > 0 })}>
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
}

export default UserFilter
module.exports = UserFilter
