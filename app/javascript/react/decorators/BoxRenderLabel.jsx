import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import Tooltipped from '../ui-components/Tooltipped.jsx'
import Icon from '../ui-components/Icon.jsx'



class BoxRenderLabel extends React.Component {

  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    var l = require('lodash')
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  onClose(event) {
    this.props.trigger(this.props.metaKeyForm, {action: 'close'})
  }

  renderCross() {

    if(!this.props.editable) {
      return null
    }

    return (


      <span
        className='ui-form-ui-ttip-toggle ui-ttip-toggle'
        style={{
          marginRight: '20px',
          marginTop: '5px',
          float: 'right'
        }}
        onClick={(e) => this.onClose(e)}
      >
        <Icon i='close'/>
      </span>
    )
  }

  render() {

    var contextOrMetaKey = () => {
      if(this.props.metaKeyForm.props.contextKey) {
        return this.props.metaKeyForm.props.contextKey
      } else {
        return this.props.metaKeyForm.props.metaKey
      }

    }


    var renderLabel = () => {
      return contextOrMetaKey().label
    }

    var renderVocabLabel = () => {
      if(!this.props.vocabLabel) {
        return null
      }

      return (
        <span style={{color: '#aaa', fontSize: '11px'}}>{this.props.metaKeyForm.props.metaKey.hint}</span>
      )
    }

    var renderHint = () => {

      var id = this.props.metaKeyForm.props.metaKey.uuid
      var hint = contextOrMetaKey().description

      if(!hint) {
        return null
      }

      return (
        <Tooltipped text={hint} id={id}>
          <span
            className='ui-form-ui-ttip-toggle ui-ttip-toggle'
            style={{
              marginRight: '20px',
              marginTop: '5px',
              float: 'right'
            }}
          >
            <Icon i='question'/>
          </span>
        </Tooltipped>
      )
    }

    return (
      <div
        style={{
          display: 'inline-block',
          width: '30%',
          verticalAlign: 'top',
          color: (this.props.metaKeyForm.props.invalid ? '#f00' : null)
        }}
      >
        <div style={{
            display: 'table',
            width: '100%'
          }}
        >
          <div
            style={{
              width: '30px',
              display: 'table-cell',
              verticalAlign: 'top'
            }}
          >
            {this.renderCross()}
          </div>
          <div
            style={{
              paddingTop: '4px',
              display: 'table-cell',
              verticalAlign: 'top'
            }}
          >
            {renderLabel()}
            <br />
            {renderVocabLabel()}
          </div>
          <div
            style={{
              width: '50px',
              display: 'table-cell',
              verticalAlign: 'top'
            }}
          >
            {renderHint()}
          </div>
        </div>
      </div>

    )
  }
}

module.exports = BoxRenderLabel
