import React from 'react'
import RailsForm from '../lib/forms/rails-form.jsx'

const HeaderButton = ({ authToken, href, method = 'post', icon, fa, title, onClick, children }) => {
  const handleClick = event => {
    event.preventDefault()
    if (onClick) {
      onClick(event)
    }
    return false
  }

  return (
    <RailsForm className="button_to" name="" method={method} action={href} authToken={authToken}>
      <button
        className="button"
        type="submit"
        title={title}
        onClick={onClick ? handleClick : undefined}>
        {icon && <i className={`icon-${icon}`} />}
        {fa && <span className={fa} />}
      </button>
      {children}
    </RailsForm>
  )
}

export default HeaderButton
module.exports = HeaderButton
