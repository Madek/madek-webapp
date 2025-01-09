/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const ui = require('../../lib/ui.js')
const { t } = ui
const Tabs = require('react-bootstrap/lib/Tabs')
const Tab = require('react-bootstrap/lib/Tab')
const Nav = require('react-bootstrap/lib/Nav')
const NavItem = require('react-bootstrap/lib/NavItem')
const MadekPropTypes = require('../../lib/madek-prop-types.js')
const { Icon, Tooltipped } = require('../../ui-components/index.js')
const AutoComplete = null // only required client-side!

// NOTE: only used client-side!
// NOTE: "form-like" inside <form>, careful!
const { PEOPLE_SUBTYPES } = MadekPropTypes
const SUPPORTED_PEOPLE_SUBTYPES = ['Person', 'PeopleGroup']

module.exports = React.createClass({
  displayName: 'NewPersonWidget',

  propTypes: {
    id: React.PropTypes.string.isRequired,
    onAddValue: React.PropTypes.func.isRequired,
    allowedTypes: React.PropTypes.arrayOf(React.PropTypes.oneOf(PEOPLE_SUBTYPES).isRequired)
      .isRequired
  },

  // NOTE: no models needed here yet:
  _emptyPerson() {
    return { type: 'Person', subtype: PEOPLE_SUBTYPES[0] }
  },

  getInitialState() {
    return {
      isOpen: false,
      newPerson: this._emptyPerson()
    }
  },
  _toggleOpen() {
    return this.setState({ isOpen: !this.state.isOpen })
  },
  _onKeyPress(event) {
    // NEVER trigger (parent form!) submit on ENTER
    if (event.key === 'Enter') {
      return event.preventDefault()
    }
  },

  _onTabChange(eventKey) {
    return this.setState({ newPerson: { subtype: eventKey } })
  },

  _onUpdateField(key, event) {
    return this.setState({
      newPerson: f.extend(this.state.newPerson, f.set({}, key, event.target.value))
    })
  },

  _inputField(key) {
    return (
      <input
        type="text"
        className="block"
        name={key}
        value={this.state.newPerson[key] || ''}
        onChange={f.curry(this._onUpdateField)(key)}
      />
    )
  },

  _onSubmit(event) {
    // NEVER trigger (parent form!) submit on button click
    event.preventDefault()
    this.props.onAddValue(this.state.newPerson)

    return this.setState({ isOpen: false, newPerson: this._emptyPerson() })
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { id, allowedTypes } = param
    const supportsAnyAllowedType = f.any(allowedTypes, t =>
      f.includes(SUPPORTED_PEOPLE_SUBTYPES, t)
    )
    if (!supportsAnyAllowedType) {
      return false
    } else {
      const paneClass = 'ui-container pam bordered rounded-right rounded-bottom'
      return (
        <div onKeyPress={this._onKeyPress}>
          <a className="button small form-widget-toggle" onClick={this._toggleOpen}>
            <Icon i="privacy-private" mods="small" />
            {!this.state.isOpen ? ` ${t('meta_data_input_new_person_toggle')}` : undefined}
          </a>
          {this.state.isOpen ? (
            <Tab.Container
              id={id}
              className="form-widget"
              defaultActiveKey="Person"
              onSelect={this._onTabChange}>
              <div>
                <Nav className="ui-tabs ui-container">
                  <NavItem eventKey="Person" className="ui-tabs-item mll pls">{`\
Person\
`}</NavItem>
                  <NavItem eventKey="PeopleGroup" className="ui-tabs-item">{`\
Group\
`}</NavItem>
                </Nav>
                <Tab.Content animation={false} className="ui-tab-content mbs">
                  {allowedTypes.map(type => {
                    if (type === 'Person') {
                      return (
                        <Tab.Pane eventKey={type} className={paneClass} key={type}>
                          <div className="ui-form-group rowed pbx ptx">
                            <label className="form-label">
                              {t('meta_data_input_new_person_first_name')}
                            </label>
                            <div className="form-item">{this._inputField('first_name')}</div>
                          </div>
                          <div className="ui-form-group rowed pbx ptx">
                            <label className="form-label">
                              {t('meta_data_input_new_person_last_name')}
                            </label>
                            <div className="form-item">{this._inputField('last_name')}</div>
                          </div>
                          <div className="ui-form-group rowed pbx ptx">
                            <label className="form-label">
                              {t('meta_data_input_new_person_pseudonym')}
                            </label>
                            <div className="form-item">{this._inputField('pseudonym')}</div>
                          </div>
                          <div className="ui-form-group rowed ptm limited-width-s">
                            <button className="add-person button block" onClick={this._onSubmit}>
                              {t('meta_data_input_new_person_add')}
                            </button>
                          </div>
                        </Tab.Pane>
                      )
                    } else if (type === 'PeopleGroup') {
                      return (
                        <Tab.Pane eventKey={type} className={paneClass} key={type}>
                          <div className="ui-form-group rowed pbx ptx">
                            <label className="form-label">
                              {t('meta_data_input_new_group_name')}
                            </label>
                            <div className="form-item">{this._inputField('first_name')}</div>
                          </div>
                          <div className="ui-form-group rowed ptm limited-width-s">
                            <button className="add-group button block" onClick={this._onSubmit}>
                              {t('meta_data_input_new_group_add')}
                            </button>
                          </div>
                        </Tab.Pane>
                      )
                    }
                  })}
                </Tab.Content>
              </div>
            </Tab.Container>
          ) : (
            undefined
          )}
        </div>
      )
    }
  }
})
