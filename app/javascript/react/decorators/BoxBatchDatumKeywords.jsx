import React from 'react'
import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import BoxPopup from './BoxPopup.jsx'
import BoxRenderLabel from './BoxRenderLabel.jsx'

class BoxBatchDatumKeywords extends React.Component {
  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  onChange(text) {
    this.props.trigger(this.props.metaKeyForm, { action: 'change-text', text: text })
  }

  onKeyDown(event) {
    if (event.keyCode == 13) {
      this.props.trigger(this.props.metaKeyForm, { action: 'cursor-enter' })
    } else if (event.keyCode == 40) {
      this.props.trigger(this.props.metaKeyForm, { action: 'cursor-down' })
    } else if (event.keyCode == 38) {
      this.props.trigger(this.props.metaKeyForm, { action: 'cursor-up' })
    }
  }

  onClose() {
    this.props.trigger(this.props.metaKeyForm, { action: 'close' })
  }

  removeKeyword(k) {
    var event = () => {
      if (k.id) {
        return {
          action: 'remove-keyword-by-id',
          id: k.id
        }
      } else {
        return {
          action: 'remove-keyword-by-label',
          label: k.label
        }
      }
    }
    this.props.trigger(this.props.metaKeyForm, event())
  }

  renderKeyword(k, i) {
    return (
      <span
        key={i}
        style={{
          fontStyle: !k.id ? 'italic' : 'normal',
          marginRight: '10px',
          color: !k.id ? '#aaa' : '#000'
        }}>
        <span onClick={() => this.removeKeyword(k)} style={{ cursor: 'pointer' }}>
          <i
            className="icon-close"
            style={{
              position: 'relative',
              top: '1px',
              marginRight: '0px',
              fontSize: '12px'
            }}></i>{' '}
        </span>
        {k.label}
      </span>
    )
  }

  renderKeywords() {
    return l.map(this.props.metaKeyForm.data.keywords, (k, i) => this.renderKeyword(k, i))
  }

  onKeywordSelect(event, keywordId, keywordLabel) {
    this.props.trigger(this.props.metaKeyForm, {
      action: 'select-keyword',
      keywordId: keywordId,
      keywordLabel: keywordLabel
    })
  }

  onFocus() {
    this.props.trigger(this.props.metaKeyForm, { action: 'input-focus' })
  }

  onCloseProposals() {
    this.props.trigger(this.props.metaKeyForm, { action: 'close-proposals' })
  }

  renderKeywordProposal(k, i) {
    return (
      <div
        key={k.uuid}
        style={{
          cursor: 'pointer',
          backgroundColor: this.props.metaKeyForm.data.keyCursor == i ? '#d6d6d6' : null,
          padding: '0px 10px',
          borderBottom: '1px solid #eee'
        }}
        onClick={e => this.onKeywordSelect(e, k.uuid, k.label)}>
        {k.label}
      </div>
    )
  }

  renderKeywordProposals() {
    if (!this.props.metaKeyForm.data.keywordProposals) {
      return (
        <div
          style={{
            padding: '0px 10px'
          }}>
          {'Loading...'}
        </div>
      )
    } else {
      return l.map(this.props.metaKeyForm.data.keywordProposals, (k, i) =>
        this.renderKeywordProposal(k, i)
      )
    }
  }

  renderPopup() {
    if (!this.props.metaKeyForm.data.showProposals) {
      return null
    }

    return (
      <div style={{ position: 'relative' }}>
        <BoxPopup
          onClose={() => this.onCloseProposals()}
          style={{
            position: 'absolute',
            zIndex: '1000',
            backgroundColor: '#fff',
            borderRadius: '5px',
            marginRight: '5px',
            marginBottom: '5px',
            WebkitBoxShadow: '0px 0px 3px 0px rgba(0,0,0,0.5)',
            MozBoxShadow: '0px 0px 3px 0px rgba(0,0,0,0.5)',
            boxShadow: '0px 0px 3px 0px rgba(0,0,0,0.5)',
            maxHeight: '200px',
            overflowY: 'auto'
          }}>
          {this.renderKeywordProposals()}
        </BoxPopup>
      </div>
    )
  }

  renderValue() {
    if (!this.props.editable) {
      return (
        <div
          style={{
            display: 'inline-block',
            width: '70%',
            verticalAlign: 'top'
          }}>
          {l.join(
            l.map(this.props.metaKeyForm.data.keywords, k => k.label),
            ', '
          )}
        </div>
      )
    }

    return (
      <div
        style={{
          display: 'inline-block',
          width: '70%',
          verticalAlign: 'top'
        }}>
        {this.renderKeywords()}
        <input
          placeholder={
            this.props.metaKeyForm.props.metaKey.is_extensible
              ? ''
              : t('resources_box_batch_search_placeholder')
          }
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
          onFocus={e => this.onFocus(e)}
          onKeyDown={e => this.onKeyDown(e)}
          onChange={e => this.onChange(e.target.value)}
        />{' '}
        {this.renderPopup()}
        {this.renderOptions()}
      </div>
    )
  }

  onChangeOption(event) {
    this.props.trigger(this.props.metaKeyForm, {
      action: 'change-option',
      option: event.target.value
    })
  }

  renderOptions() {
    return (
      <div style={{ textAlign: 'right' }}>
        <select onChange={e => this.onChangeOption(e)}>
          {this.props.metaKeyForm.props.metaKey.multiple && (
            <option value={'add'}>zu bestehenden hinzufügen</option>
          )}
          <option value={'replace'}>bestehende ersetzen</option>
        </select>
      </div>
    )
  }

  render() {
    return (
      <div>
        <BoxRenderLabel
          showOptions={true}
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

module.exports = BoxBatchDatumKeywords
