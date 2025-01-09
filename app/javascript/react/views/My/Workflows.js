import React from 'react'
import Link from '../../ui-components/Link.jsx'
import ResourceThumbnail from '../../decorators/ResourceThumbnail.jsx'
import f from 'lodash'
// import setUrlParams from '../../../lib/set-params-for-url.js'
// import AppRequest from '../../../lib/app-request.js'
// import { parse as parseUrl } from 'url'
// import { parse as parseQuery } from 'qs'
// import Moment from 'moment'
// import currentLocale from '../../../lib/current-locale'

const WORKFLOW_STATES = { IN_PROGRESS: 'IN_PROGRESS', FINISHED: 'FINISHED' }

class MyWorkflows extends React.Component {
  render({ props } = this) {
    const workflowsByStatus = props.get.by_status
    const inProgresss = workflowsByStatus[WORKFLOW_STATES.IN_PROGRESS]
    const finisheds = workflowsByStatus[WORKFLOW_STATES.FINISHED]

    return (
      <div className="ui-resources-holder pal">
        <WorkflowList list={inProgresss} />
        {!f.isEmpty(finisheds) && <h4 className="title-s mtl mbm">{'Abgeschlossene Workflows'}</h4>}
        {!f.isEmpty(finisheds) && <WorkflowList list={finisheds} withThumbnail={false} />}
      </div>
    )
  }
}

const WorkflowList = ({ list, withThumbnail = true }) => {
  const labelStyle = {
    backgroundColor: '#666',
    color: '#fff',
    display: 'inline-block',
    borderRadius: '3px'
  }

  return (
    <div>
      {f.map(list, (workflow, i) => {
        const editUrl = f.get(workflow, 'actions.edit.url')
        const linkLabel = workflow.status === WORKFLOW_STATES.IN_PROGRESS ? 'Edit' : 'Show details'

        return (
          <div key={i}>
            <div className="ui-resources-header">
              <h1 className="title-l ui-resources-title">{workflow.name}</h1>
              <label style={labelStyle} className="phs mls">
                {workflow.status}
              </label>
              {!!editUrl && (
                <Link href={editUrl} mods="strong">
                  {linkLabel}
                </Link>
              )}
            </div>
            {!!withThumbnail && (
              <ul className="grid ui-resources">
                {f.map(workflow.associated_collections, (collection, ci) => (
                  <div key={ci}>
                    <ResourceThumbnail get={{ ...collection, url: editUrl }} />
                  </div>
                ))}
              </ul>
            )}
            <hr className="separator mbm" />
          </div>
        )
      })}
    </div>
  )
}

module.exports = MyWorkflows
