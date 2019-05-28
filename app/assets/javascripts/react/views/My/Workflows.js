import React from 'react'
import PropTypes from 'prop-types'
import Link from '../../ui-components/Link.cjsx'
import ResourceThumbnail from '../../decorators/ResourceThumbnail.cjsx'
import f from 'lodash'
// import setUrlParams from '../../../lib/set-params-for-url.coffee'
// import AppRequest from '../../../lib/app-request.coffee'
// import { parse as parseUrl } from 'url'
// import { parse as parseQuery } from 'qs'
// import Moment from 'moment'
// import currentLocale from '../../../lib/current-locale'

const WORKFLOW_STATES = { IN_PROGRESS: 'IN_PROGRESS', FINISHED: 'FINISHED' }

class MyWorkflows extends React.Component {
  render({ props } = this) {
    const workflows = props.get.list
    const labelStyle = {
      backgroundColor: '#666',
      color: '#fff',
      display: 'inline-block',
      borderRadius: '3px'
    }

    return (
      <div className="ui-resources-holder pal">
        {f.map(workflows, (workflow, i) => {
          return (
            <div key={i}>
              <div className="ui-resources-header">
                <h1 className="title-l ui-resources-title">{workflow.name}</h1>
                <label style={labelStyle} className="phs mls">
                  {workflow.status}
                </label>

                <IfLet editUrl={f.get(workflow, 'actions.edit.url')}>
                  {editUrl => (
                    <Link href={editUrl} mods="strong">
                      {workflow.status === WORKFLOW_STATES.IN_PROGRESS ? 'Edit' : 'Show details'}
                    </Link>
                  )}
                </IfLet>
              </div>
              <ul className="grid ui-resources">
                {f.map(workflow.associated_collections, (collection, ci) => (
                  <div key={ci}>
                    <ResourceThumbnail get={collection} />
                  </div>
                ))}
              </ul>
              <hr className="separator mbm" />
            </div>
          )
        })}
      </div>
    )
  }
}

module.exports = MyWorkflows

const IfLet = ({ children, ...bindings }) => {
  const keys = Object.keys(bindings)
  if (keys.length > 1) throw new TypeError('IfLet requires 0 or 1 bindings!')
  const binding = bindings[keys[0]]
  return binding ? children(binding) : null
}
IfLet.propTypes = {
  children: PropTypes.func.isRequired
}
