import React from 'react'

const Keyword = ({ label, count, hrefUrl }) => {
  return (
    <li className="ui-tag-cloud-item">
      <a className="ui-tag-button" href={hrefUrl} title={label}>
        <i className="icon-tag-mini ui-tag-icon" />
        {label}
        <small className="ui-tag-counter">{count}</small>
      </a>
    </li>
  )
}

export default Keyword
module.exports = Keyword
