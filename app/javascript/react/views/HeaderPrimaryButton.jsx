import React from 'react'

const HeaderPrimaryButton = ({ href, text, icon, onClick }) => {
  return (
    <a className="button-primary primary-button" href={href} onClick={onClick}>
      {icon && (
        <span>
          <i className={`icon-${icon}`} />{' '}
        </span>
      )}
      {text}
    </a>
  )
}

export default HeaderPrimaryButton
module.exports = HeaderPrimaryButton
