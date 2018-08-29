import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import BoxPopup from './BoxPopup.jsx'
import BoxRenderLabel from './BoxRenderLabel.jsx'
import BoxPeopleNewWidget from './BoxPeopleNewWidget.jsx'



class BoxBatchDatumPeople extends React.Component {

  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    var l = require('lodash')
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  onChange(text) {
    this.props.trigger(this.props.metaKeyForm, {action: 'change-text', text: text})
  }

  onClose(event) {
    this.props.trigger(this.props.metaKeyForm, {action: 'close'})
  }

  removeKeywordById(k) {

    var event = () => {
      return {
        action: 'remove-keyword-by-id',
        id: k.id
      }
    }
    this.props.trigger(this.props.metaKeyForm, event())
  }

  removeKeywordByData(k) {
    this.props.trigger(
      this.props.metaKeyForm,
      {
        action: 'remove-keyword-by-data',
        keyword: k
      }
    )
  }

  renderKeyword(k, i) {

    if(k.id) {
      return (
        <span key={i} style={{fontStyle: 'normal', marginRight: '10px', color: '#000'}}>
          <span onClick={(e) => this.removeKeywordById(k)} style={{cursor: 'pointer'}}>
            <i className='icon-close' style={{position: 'relative', top: '1px', marginRight: '0px', fontSize: '12px'}}></i>
            {' '}
          </span>
          {k.label}
        </span>
      )
    } else if(k.subtype == 'Person') {

      var renderName = () => {
        var getFirstname = () => {
          return (k.first_name ? k.first_name : '')
        }
        var getLastname = () => {
          return (k.last_name ? k.last_name : '')
        }
        var getPseudonym = () => {
          return (k.pseudonym ? ' (' + k.pseudonym + ')' : '')
        }
        return getFirstname() + ' ' + getLastname() + getPseudonym()
      }

      return (
        <span key={i} style={{fontStyle: 'italic', marginRight: '10px', color: '#aaa'}}>
          <span onClick={(e) => this.removeKeywordByData(k)} style={{cursor: 'pointer'}}>
            <i className='icon-close' style={{position: 'relative', top: '1px', marginRight: '0px', fontSize: '12px'}}></i>
            {' '}
          </span>
          {renderName()}
        </span>
      )
    } else if(k.subtype == 'PeopleGroup') {
      return (
        <span key={i} style={{fontStyle: 'italic', marginRight: '10px', color: '#aaa'}}>
          <span onClick={(e) => this.removeKeywordByData(k)} style={{cursor: 'pointer'}}>
            <i className='icon-close' style={{position: 'relative', top: '1px', marginRight: '0px', fontSize: '12px'}}></i>
            {' '}
          </span>
          {k.first_name}
        </span>
      )
    } else {
      throw 'Unexpected: ' + JSON.stringify(k)
    }
  }

  renderKeywords() {
    return l.map(
      this.props.metaKeyForm.data.keywords,
      (k, i) => this.renderKeyword(k, i)
    )
  }

  onKeywordSelect(event, keywordId, keywordLabel) {
    this.props.trigger(this.props.metaKeyForm, {action: 'select-keyword', keywordId: keywordId, keywordLabel: keywordLabel})
  }

  onFocus(event) {
    this.props.trigger(this.props.metaKeyForm, {action: 'input-focus'})
  }

  onCloseProposals() {
    this.props.trigger(this.props.metaKeyForm, {action: 'close-proposals'})
  }

  renderKeywordProposal(k) {
    return (
      <div key={k.uuid} style={{cursor: 'pointer', borderBottom: '1px solid #eee'}} onClick={(e) => this.onKeywordSelect(e, k.uuid, k.label)}>
        {k.label}
      </div>
    )

  }

  renderKeywordProposals() {
    if(!this.props.metaKeyForm.data.keywordProposals) {
      return 'Loading...'
    }
    else {
      return l.map(
        this.props.metaKeyForm.data.keywordProposals,
        (k) => this.renderKeywordProposal(k)
      )
    }
  }

  renderPopup() {

    if(!this.props.metaKeyForm.data.showProposals) {
      return null
    }

    return (
      <div style={{position: 'relative'}}>
        <BoxPopup
          onClose={() => this.onCloseProposals()}
          style={{
            position: 'absolute',
            zIndex: '1000',
            backgroundColor: '#fff',
            borderRadius: '5px',
            padding: '0px 10px',
            marginRight: '5px',
            marginBottom: '5px',
            WebkitBoxShadow: '0px 0px 3px 0px rgba(0,0,0,0.5)',
            MozBoxShadow: '0px 0px 3px 0px rgba(0,0,0,0.5)',
            boxShadow: '0px 0px 3px 0px rgba(0,0,0,0.5)',
            maxHeight: '200px',
            overflowY: 'auto'
          }}
        >
          {this.renderKeywordProposals()}
        </BoxPopup>
      </div>
    )
  }

  renderNewWidget() {

    var newWidget = this.props.metaKeyForm.components.newWidget
    if(!newWidget) {
      return null
    }

    return (
      <BoxPeopleNewWidget trigger={this.props.trigger} component={this.props.metaKeyForm.components.newWidget} />
    )
  }

  renderValue() {

    if(!this.props.editable) {
      return (
        <div
          style={{
            display: 'inline-block',
            width: '70%',
            verticalAlign: 'top'
          }}
        >
          {
            l.join(l.map(
              this.props.metaKeyForm.data.keywords,
              (k, i) => k.label
            ), ', ')
          }
        </div>
      )
    }

    return (
      <div
        style={{
          display: 'inline-block',
          width: '70%',
          verticalAlign: 'top'
        }}
      >
        {this.renderKeywords()}
        <input
          placeholder={t('resources_box_batch_search_placeholder')}
          style={{
            borderRadius: '5px',
            border: '1px solid #ddd',
            padding: '5px',
            boxSizing: 'border-box',
            width: '100%',
            height: '30px',
            fontSize: '12px'
          }}
          value={this.props.metaKeyForm.data.text}
          onFocus={(e) => this.onFocus(e)}
          onChange={(e) => this.onChange(e.target.value)}
        />
        {' '}
        {this.renderPopup()}
        {this.renderNewWidget()}
      </div>
    )
  }

  render() {

    var metaKeyForm = this.props.metaKeyForm

    return (
      <div>
        <BoxRenderLabel
          trigger={this.props.trigger}
          metaKeyForm={this.props.metaKeyForm}
          editable={this.props.editable}
          vocabLabel={this.props.vocabLabel}
        />
        {this.renderValue()}
      </div>
    )
  }
}

module.exports = BoxBatchDatumPeople
