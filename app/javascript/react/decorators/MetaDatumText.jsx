import React, { Component } from 'react'
import linkifyInnerHtml from '../lib/linkify-inner-html.js'
import cx from 'classnames'
import t from '../../lib/i18n-translate.js'

function estimateNumberOfLines(values) {
  const estimatedLineLength = 110
  const text = values.join(', ') || ['']
  const lines = text.split(/\r\n|\r|\n/g)
  return lines
    .map(paragraph => Math.ceil(paragraph.length / estimatedLineLength))
    .reduce((a, b) => a + b)
}

export default class MetaDatumText extends Component {
  constructor(props) {
    super(props)
    this.state = { isOpen: false }
  }

  toggleOpen() {
    this.setState(s => ({ isOpen: !s.isOpen }))
  }

  renderContent({ values, className }) {
    return (
      <ul className={cx('inline measure-double', className)}>
        {values.map(value => (
          <li key={value} dangerouslySetInnerHTML={linkifyInnerHtml(value)} />
        ))}
      </ul>
    )
  }

  render({ props, state } = this) {
    const { values = [], allowReadMore } = props
    const { isOpen } = state
    if (allowReadMore && estimateNumberOfLines(values) > 10) {
      return (
        <div
          className={cx('read-more__container', {
            'read-more__container--open': isOpen
          })}>
          {this.renderContent({ values, className: 'read-more__content' })}
          <div className={cx('read-more__toggler')} aria-hidden="true">
            <a onClick={() => this.toggleOpen()}>
              <div className={cx('read-more__dust')}></div>
              {isOpen ? t('read_less_button') : t('read_more_button')}
            </a>
          </div>
        </div>
      )
    } else {
      return this.renderContent({ values })
    }
  }
}
