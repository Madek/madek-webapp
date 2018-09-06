import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import BoxBatchDatumText from './BoxBatchDatumText.jsx'
import BoxBatchDatumTextDate from './BoxBatchDatumTextDate.jsx'
import BoxBatchDatumKeywords from './BoxBatchDatumKeywords.jsx'
import BoxBatchDatumPeople from './BoxBatchDatumPeople.jsx'

class BoxBatchEditMetaKeyForm extends React.Component {

  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    var l = require('lodash')
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  renderText() {
    return (
      <BoxBatchDatumText
        trigger={this.props.trigger}
        metaKeyForm={this.props.metaKeyForm}
        editable={true}
        vocabLabel={this.props.vocabLabel}
      />
    )
  }

  renderTextDate() {
    return (
      <BoxBatchDatumTextDate
        trigger={this.props.trigger}
        metaKeyForm={this.props.metaKeyForm}
        editable={true}
        vocabLabel={this.props.vocabLabel}
      />
    )
  }

  renderKeywords() {
    return (
      <BoxBatchDatumKeywords
        trigger={this.props.trigger}
        metaKeyForm={this.props.metaKeyForm}
        editable={true}
        vocabLabel={this.props.vocabLabel}
      />
    )
  }

  renderPeople() {
    return (
      <BoxBatchDatumPeople
        trigger={this.props.trigger}
        metaKeyForm={this.props.metaKeyForm}
        editable={true}
        vocabLabel={this.props.vocabLabel}
      />
    )
  }

  renderers() {
    return {
      'MetaDatum::Text': () => this.renderText(),
      'MetaDatum::TextDate': () => this.renderTextDate(),
      'MetaDatum::Keywords': () => this.renderKeywords(),
      'MetaDatum::People': () => this.renderPeople()
    }
  }

  renderForm() {
    var type = this.props.metaKeyForm.props.metaKey.value_type
    var renderer = this.renderers()[type]
    if(!renderer) throw 'not implemented for ' + type
    return renderer()
  }

  renderMandatory() {

    var mandatoryForTypes = this.props.metaKeyForm.props.mandatoryForTypes

    if(mandatoryForTypes.length == 0) {
      return null
    }

    var mandatoryText = () => {
      if(mandatoryForTypes.length == 1 && mandatoryForTypes[0] == 'MediaEntry') {
        return t('resources_box_batch_mandatory_field_for_media_entry')
      }
      return t('resources_box_batch_mandatory_field')
    }

    return (
      <div style={{marginBottom: '10px', color: '#5982a7', textAlign: 'right'}}>
        <i
          className='icon-question'
          style={{
            display: 'inline-block',
            width: '20px',
            position: 'relative',
            top: '2px'
          }}
        />
        {' '}
        {mandatoryText()}
      </div>
    )
  }

  renderScope() {
    var metaKey = this.props.metaKeyForm.props.metaKey

    var renderDiv = (text) => {
      return (
        <div style={{marginBottom: '10px', color: '#b59d6e', textAlign: 'right'}}>
          <i
            className='icon-bang'
            style={{
              display: 'inline-block',
              width: '20px',
              position: 'relative',
              top: '2px'
            }}
          />
          {' '}
          {text}
        </div>
      )
    }

    if(l.includes(metaKey.scope, 'Entries') && l.includes(metaKey.scope, 'Sets')) {
      return renderDiv(t('resources_box_batch_field_only_for_entries_and_sets'))
    } else if(l.includes(metaKey.scope, 'Entries')) {
      return renderDiv(t('resources_box_batch_field_only_for_entries'))
    } else if(l.includes(metaKey.scope, 'Sets')) {
      return renderDiv(t('resources_box_batch_field_only_for_sets'))
    } else {
      return null
    }

  }


  render() {

    return (
      <div>
        {this.renderMandatory()}
        {this.renderScope()}
        {this.renderForm()}
      </div>
    )
  }
}

module.exports = BoxBatchEditMetaKeyForm
