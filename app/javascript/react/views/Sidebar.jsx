/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const cx = require('classnames')
const libUrl = require('url')
const qs = require('qs')

module.exports = React.createClass({
  displayName: 'Sidebar',

  _endsWith(string, suffix) {
    return string.indexOf(suffix, string.length - suffix.length) !== -1
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { sections, for_url } = param
    const show_beta = false

    return (
      <ul className="ui-side-navigation">
        {f.flatten(
          f.map(f.keys(sections), section_id => {
            const section = sections[section_id]
            const link = section.href

            if (!link) {
              throw new Error(`Missing href attribute for '${section_id}' section!`)
            }

            const link_active = this._endsWith(libUrl.parse(for_url).pathname, section_id)

            const classes = cx('ui-side-navigation-item', { active: link_active })

            return f.compact([
              <li key={section_id + 'key1'} className={classes} key={section_id}>
                <a className="strong" href={link}>
                  {section.is_beta && show_beta ? (
                    <em style={{ fontStyle: 'italic', fontWeight: 'normal' }}>Beta: </em>
                  ) : (
                    undefined
                  )}
                  {section.title}
                  {section.counter ? (
                    <span
                      style={{ marginLeft: '4px', color: 'grey', fontWeight: 'normal' }}
                      id={`side-navigation-${section_id}-counter`}>
                      ({section.counter})
                    </span>
                  ) : (
                    undefined
                  )}
                </a>
              </li>,
              section_id !== f.last(f.keys(sections)) ? (
                <li key={section_id + 'key2'} className="separator mini" />
              ) : (
                undefined
              )
            ])
          })
        )}
      </ul>
    )
  }
})
