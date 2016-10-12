import React from 'react'

const PageHeader = ({icon, title, actions}) =>
  <div className='ui-body-title'>
    <div className='ui-body-title-label'>
      <h1 className='title-xl'>
        {!!icon && <span><i className={'icon-' + icon}/> </span>}
        {title}
      </h1>
    </div>

    {!!actions && <div className='ui-body-title-actions'>{actions}</div>}
  </div>

PageHeader.propTypes = {
  title: React.PropTypes.string.isRequired,
  children: React.PropTypes.node,
  icon: React.PropTypes.string
}

module.exports = PageHeader
