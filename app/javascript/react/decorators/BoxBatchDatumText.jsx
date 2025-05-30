import React from 'react'
import BoxRenderLabel from './BoxRenderLabel.jsx'
import l from 'lodash'

class BoxBatchDatumText extends React.Component {
  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  onChange(text) {
    this.props.trigger(this.props.metaKeyForm, { action: 'change-text', text: text })
  }

  renderValueText() {
    if (!this.props.editable) {
      return this.props.metaKeyForm.data.text
    }

    var determineElement = () => {
      if (this.props.metaKeyForm.props.metaKey.text_type == 'block') {
        return 'textarea'
      } else {
        return 'input'
      }
    }

    var Element = determineElement()
    return (
      <Element
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
        onChange={e => this.onChange(e.target.value)}
      />
    )
  }

  renderValue() {
    return (
      <div
        style={{
          display: 'inline-block',
          width: '70%',
          verticalAlign: 'top'
        }}>
        {this.renderValueText()}
      </div>
    )
  }

  render() {
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

module.exports = BoxBatchDatumText
