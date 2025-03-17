/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import Icon from './Icon.jsx'
import cx from 'classnames'

module.exports = createReactClass({
  displayName: 'VocabTitleLink',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { id, hi, text, href, separated, className } = param
    const H = hi ? hi : 'h3'
    const defaultClasses = cx('title-l', { separated, mbm: separated })
    const classes = className ? className : defaultClasses
    return (
      <H className={classes} id={id}>
        {text}
        {href ? ' ' : undefined}
        {href ? (
          <a href={href} style={{ textDecoration: 'none' }}>
            <Icon i="link" />
          </a>
        ) : undefined}
      </H>
    )
  }
})
