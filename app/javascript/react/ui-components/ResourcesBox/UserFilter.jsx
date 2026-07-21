import { filter, map, size, sortBy } from 'lodash-es';
import React from 'react'
import cx from 'classnames'
import TypeaheadInput from '../../lib/typeahead-input.jsx'

class UserFilter extends React.Component {
  _source = (term, callback) => {
    const children = this.props.node.children
    if (term.length > 0) {
      const termLower = term.toLowerCase()
      callback(
        sortBy(
          filter(children, user => !user.selected && user.label.toLowerCase().includes(termLower))
        )
      )
    } else {
      callback(
        sortBy(
          filter(children, user => !user.selected),
          'label'
        )
      )
    }
  }

  render() {
    const { node, placeholder } = this.props
    const selection = filter(node.children, 'selected')
    const hasMore = size(selection) < size(node.children)

    const clear = (selected, event) => {
      event.preventDefault()
      this.props.userChanged(selected, 'remove')
    }

    return (
      <ul className={this.props.togglebodyClass}>
        {map(selection, selected => (
          <li
            key={`uuid_${selected.uuid}`}
            className={cx('ui-side-filter-lvl3-item', { active: true })}>
            <a className="link weak ui-link" onClick={event => clear(selected, event)}>
              {selected.label}
              {selected.label && <span className="ui-lvl3-item-count">{selected.count}</span>}
            </a>
          </li>
        ))}
        {hasMore && (
          <li key="input" className={cx('ui-side-filter-lvl3-item', { mtx: selection.length > 0 })}>
            <TypeaheadInput
              source={this._source}
              onSelect={item => this.props.userChanged(item, 'add')}
              placeholder={placeholder}
              classNames={{
                wrapper: 'ui-autocomplete-holder',
                input: 'ui-typeahead-input block',
                hint: 'ui-autocomplete-hint',
                menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width ui-autocomplete-top-margin-2',
                cursor: 'ui-autocomplete-cursor',
                suggestion: 'ui-autocomplete-override-sidebar ui-menu-item'
              }}
            />
          </li>
        )}
      </ul>
    );
  }
}

export default UserFilter
