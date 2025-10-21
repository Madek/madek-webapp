import React from 'react'
import Icon from './Icon.jsx'
import cx from 'classnames'

const VocabTitleLink = ({ id, hi, text, href, separated, className }) => {
  const H = hi || 'h3'
  const defaultClasses = cx('title-l', { separated, mbm: separated })
  const classes = className || defaultClasses

  return (
    <H className={classes} id={id}>
      {text}
      {href && ' '}
      {href && (
        <a href={href} style={{ textDecoration: 'none' }}>
          <Icon i="link" />
        </a>
      )}
    </H>
  )
}

export default VocabTitleLink
module.exports = VocabTitleLink
