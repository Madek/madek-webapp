import React from 'react'
import cx from 'classnames'

const PageHeader = ({ icon, fa, title, actions }) =>
  <div className='ui-body-title'>
    <div className='ui-body-title-label'>
      <h1 className='title-xl'>
        {!!icon &&
          <span>
            <i className={'icon-' + icon} />{' '}
          </span>}
        {!!fa &&
          <span>
            <span className={cx('fa fa-share', 'title-xl')} />{' '}
          </span>}
        {title}
      </h1>
    </div>

    {!!actions &&
      <div className='ui-body-title-actions'>
        <span data="spacer-gif">{"\u00a0"}</span>
        {actions}
      </div>}
  </div>

PageHeader.propTypes = {
  title: React.PropTypes.string.isRequired,
  children: React.PropTypes.node,
  icon: React.PropTypes.string
}

module.exports = PageHeader
