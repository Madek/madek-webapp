import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import BoxPopup from './BoxPopup.jsx'
import BoxRenderLabel from './BoxRenderLabel.jsx'



class BoxPeopleNewWidget extends React.Component {

  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    var l = require('lodash')
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }


  renderNewButton() {
    return (
      <div className='mts'>
        <a
          className='button small form-widget-toggle'
          onClick={(e) => this.props.trigger(this.props.component, {action: 'open'})}
        >
          <i className='small icon-privacy-private'></i>
          {' '}
          Neue Person oder Gruppe anlegen
        </a>
      </div>
    )
  }




  renderTabs() {

    var newWidget = this.props.component.data
    var metaKey = this.props.component.props.metaKey
    var personSupported = l.includes(metaKey.allowed_people_subtypes, 'Person')
    var groupSupported = l.includes(metaKey.allowed_people_subtypes, 'PeopleGroup')

    var renderPersonTab = () => {
      if(!personSupported) {
        return null
      }
      return (
        <li className={cx('ui-tabs-item mll pls', {active: newWidget.selected == 'person'})}>
          <a
            onClick={(e) => this.props.trigger(this.props.component, {action: 'select-tab', tab: 'person'})}
          >
            {t('resources_box_batch_person_widget_tab_person')}
          </a>
        </li>
      )
    }

    var renderGroupTab = () => {
      if(!groupSupported) {
        return null
      }
      return (
        <li className={cx('ui-tabs-item', {active: newWidget.selected == 'group'})}>
          <a
            onClick={(e) => this.props.trigger(this.props.component, {action: 'select-tab', tab: 'group'})}
          >
            {t('resources_box_batch_person_widget_tab_group')}
          </a>
        </li>
      )
    }

    return (
      <ul className='ui-tabs ui-container nav'>
        {renderPersonTab()}
        {renderGroupTab()}
      </ul>
    )
  }


  inputTrigger(event) {
    this.props.trigger(this.props.component, event)
  }

  renderTabContentPerson() {
    var newWidget = this.props.component.data
    return (
      <div className='ui-container pam bordered rounded-right rounded-bottom tab-pane active'>
        <div className='ui-form-group rowed pbx ptx'>
          <label className='form-label' style={{width: '50%', display: 'inline-block'}}>
            {t('resources_box_batch_person_widget_firstname')}
          </label>
          <div className='form-item' style={{width: '50%', display: 'inline-block'}}>
            <input
              type='text'
              className='block'
              value={newWidget.person.firstname}
              onChange={(e) => this.inputTrigger({action: 'person-firstname', text: e.target.value})}
            >
            </input>
          </div>
        </div>
        <div className='ui-form-group rowed pbx ptx'>
          <label className='form-label' style={{width: '50%', display: 'inline-block'}}>
            {t('resources_box_batch_person_widget_lastname')}
          </label>
          <div className='form-item' style={{width: '50%', display: 'inline-block'}}>
            <input
              type='text'
              className='block'
              value={newWidget.person.lastname}
              onChange={(e) => this.inputTrigger({action: 'person-lastname', text: e.target.value})}
            >
            </input>
          </div>
        </div>
        <div className='ui-form-group rowed pbx ptx'>
          <label className='form-label' style={{width: '50%', display: 'inline-block'}}>
            {t('resources_box_batch_person_widget_pseudonym')}
          </label>
          <div className='form-item' style={{width: '50%', display: 'inline-block'}}>
            <input
              type='text'
              className='block'
              value={newWidget.person.pseudonym}
              onChange={(e) => this.inputTrigger({action: 'person-pseudonym', text: e.target.value})}
            >
            </input>
          </div>
        </div>
        <div className='ui-form-group rowed ptm limited-width-s'>
          <button
            className='add-person button block'
            onClick={(e) => this.props.trigger(this.props.component, {action: 'add-person'})}
          >
            {t('resources_box_batch_person_widget_add_person')}
          </button>
        </div>
      </div>
    )
  }

  renderTabContentGroup() {
    var newWidget = this.props.component.data
    return (
      <div className='ui-container pam bordered rounded-right rounded-bottom tab-pane active'>
        <div className='ui-form-group rowed pbx ptx'>
          <label className='form-label' style={{width: '50%', display: 'inline-block'}}>
            {t('resources_box_batch_person_widget_name')}
          </label>
          <div className='form-item' style={{width: '50%', display: 'inline-block'}}>
            <input
              type='text'
              className='block'
              value={newWidget.group.name}
              onChange={(e) => this.inputTrigger({action: 'group-name', text: e.target.value})}
            >
            </input>
          </div>
        </div>
        <div className='ui-form-group rowed ptm limited-width-s'>
          <button
            className='add-group button block'
            onClick={(e) => this.props.trigger(this.props.component, {action: 'add-group'})}
          >
            {t('resources_box_batch_person_widget_add_group')}
          </button>
        </div>
      </div>
    )
  }

  renderTabContent() {
    var newWidget = this.props.component.data
    if(newWidget.selected == 'person') {
      return this.renderTabContentPerson()
    } else if(newWidget.selected == 'group') {
      return this.renderTabContentGroup()
    } else {
      throw 'Unexpected: ' + newWidget.selected
    }
  }

  render() {

    var newWidget = this.props.component.data

    if(!newWidget.open) {
      return this.renderNewButton()
    }

    return (
      <div className='mts'>
        <a
          className='button small form-widget-toggle'
          onClick={(e) => this.props.trigger(this.props.component, {action: 'close'})}
        >
          <i className='small icon-privacy-private'></i>
        </a>
        <div className='form-widget'>
          {this.renderTabs()}
          <div className='ui-tab-content mbs tab-content'>
            {this.renderTabContent()}
          </div>
        </div>
      </div>

    )
  }
}

module.exports = BoxPeopleNewWidget
