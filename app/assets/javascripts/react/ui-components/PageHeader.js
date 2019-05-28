import React from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import Link from './Link.cjsx'
import Icon from './Icon.cjsx'

const WORKFLOW_STATES = { IN_PROGRESS: 'IN_PROGRESS', FINISHED: 'FINISHED' }

const WorkflowBanner = ({ workflow, icon }) => {
  if(workflow.status === WORKFLOW_STATES.FINISHED) { return null }

  const linkStyle = {
    color: '#adc671',
    textDecoration: 'underline'
  }
  const bannerStyle = {
    // backgroundColor: '#505050'
    // color: '#fff',
    // display: 'inline-block',
    // borderRadius: '3px',
    // position: 'relative',
    // top: '-7px'
  }

  return (
    <div style={bannerStyle} className="ui-alert XXXsuccess ui-container inverted paragraph-l mbm">
      <Icon i="madek-workflow" /> This {icon === 'set' ? 'Set' : 'Media Entry'}
      {' is part of the Workflow "'}
      <Link href={workflow.actions.edit.url} mods="strong" style={linkStyle}>
        {workflow.name}
      </Link>
      {'"'}
    </div>
  )
}

const PageHeader = ({ icon, fa, title, actions, workflow }) => {
  return (
    <div>
      {!!workflow && <WorkflowBanner workflow={workflow} icon={icon} />}
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
