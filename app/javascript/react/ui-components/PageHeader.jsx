import React from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import SectionLabels from './SectionLabels.jsx'

const PageHeader = ({ icon, fa, title, actions, banner, sectionLabels }) => {
  return (
    <div>
      {sectionLabels && <SectionLabels items={sectionLabels} />}

      {banner}

      <div className="ui-body-title">
        <div className="ui-body-title-label">
          <h1 className="title-xl">
            {!!icon && (
              <span>
                <i className={'icon-' + icon} />{' '}
              </span>
            )}
            {!!fa && (
              <span>
                <span className={cx('fa fa-share', 'title-xl')} />{' '}
              </span>
            )}
            {title}
          </h1>
        </div>

        {!!actions && (
          <div className="ui-body-title-actions">
            <span data="spacer-gif">{'\u00a0'}</span>
            {actions}
          </div>
        )}
      </div>
    </div>
  )
}

PageHeader.propTypes = {
  title: PropTypes.string.isRequired,
  children: PropTypes.node,
  icon: PropTypes.string
}

module.exports = PageHeader
