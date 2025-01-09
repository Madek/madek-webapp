import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import setsFallbackUrl from '../../lib/sets-fallback-url.js'
import Preloader from '../ui-components/Preloader.jsx'
import ActionsDropdownHelper from './resourcesbox/ActionsDropdownHelper.jsx'
import ResourceThumbnail from './ResourceThumbnail.jsx'
import BoxRenderResource from './BoxRenderResource.jsx'
import l from 'lodash'

class BoxRenderResources extends React.Component {

  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  render() {

    var resources = this.props.resources
    var listClasses = this.props.listClasses
    var actionsDropdownParameters = this.props.actionsDropdownParameters
    var selectedResources = this.props.selectedResources
    var isClient = this.props.isClient
    var showSelectionLimit = this.props.showSelectionLimit
    var selectionLimit = this.props.selectionLimit
    var onSelectResource = this.props.onSelectResource
    var config = this.props.config
    var hoverMenuId = this.props.hoverMenuId
    var authToken = this.props.authToken
    var withActions = this.props.withActions
    var listMods = this.props.listMods
    const { positionProps } = this.props

    // fetching relations enabled by default if layout is grid + withActions + isClient
    var fetchRelations = isClient && withActions && f.includes(['grid', 'list'], config.layout)

    var renderPage = (page, i) => {

      var renderItem = (itemState) => {

        var resourceId = itemState.data.resource.uuid
        var job = this.props.applyJob
        var batchStatus = () => {

          if(!job || job.processing.length == 0 && job.failure.length == 0) {
            return null
          } else if(l.find(job.pending, (p) => p.uuid == resourceId)) {
            return 'pending'
          } else if(l.find(job.processing, (p) => p.uuid == resourceId)) {
            return 'processing'
          } else if(l.find(job.success, (p) => p.uuid == resourceId)) {
            return 'success'
          } else if(l.find(job.failure, (p) => p.uuid == resourceId)) {
            return 'failure'
          } else if(l.find(job.cancelled, (p) => p.uuid == resourceId)) {
            return 'cancelled'
          } else {
            return 'sleep'
          }
        }

        return (
          <BoxRenderResource
            resourceState={itemState}
            isClient={isClient}
            onSelectResource={onSelectResource}
            positionProps={positionProps}
            config={config}
            hoverMenuId={hoverMenuId}
            showBatchButtons={this.props.showBatchButtons}
            fetchRelations={fetchRelations}
            key={itemState.data.resource.uuid}
            trigger={this.props.trigger}
            isSelected={f.find(selectedResources, (sr) => sr.uuid == itemState.data.resource.uuid)}
            showActions={ActionsDropdownHelper.showActionsConfig(actionsDropdownParameters)}
            selectionMode={this.props.selectionMode}
            batchStatus={batchStatus()}
          />
        )
      }

      var renderItems = (page) => {
        return page.map((item) => {
          return renderItem(item)
        })
      }


      var renderCounter = () => {

        var pagination = this.props.pagination
        var pageSize = this.props.perPage

        var BoxPageCounter = require('./BoxPageCounter.jsx')
        return (
          <BoxPageCounter
            showActions={ActionsDropdownHelper.showActionsConfig(actionsDropdownParameters)}
            selectedResources={selectedResources}
            isClient={isClient}
            showSelectionLimit={showSelectionLimit}
            resources={resources}
            pageResources={f.map(page, (i) => i.data.resource)}
            selectionLimit={selectionLimit}
            pagination={pagination}
            perPage={this.props.perPage}
            pageIndex={i}
            unselectResources={this.props.unselectResources}
            selectResources={this.props.selectResources}
          />
        )
      }


      return (
        <li className='ui-resources-page' key={i}>
          {renderCounter()}
          <ul className='ui-resources-page-items'>
            {renderItems(page)}
          </ul>
        </li>
      )
    }


    var renderPages = () => {
      var pagination = this.props.pagination
      var pageSize = this.props.perPage

      return f.chunk(resources, pageSize).map((page, i) => {
        return renderPage(page, i)
      })
    }

    var listClasses = () => {
      return cx(
        config.layout, // base class like "list"
        {
          'vertical': config.layout == 'tiles',
          'active': withActions
        },
        listMods,
        'ui-resources'
      )
    }

    return (
      <ul className={listClasses()}>
        {renderPages()}
      </ul>
    )
  }
}

module.exports = BoxRenderResources
