import React from 'react'
import f from 'active-lodash'
import cx from 'classnames/dedupe'
import ActionsDropdownHelper from './resourcesbox/ActionsDropdownHelper.jsx'
import BoxRenderResource from './BoxRenderResource.jsx'
import l from 'lodash'
import BoxPageCounter from './BoxPageCounter.jsx'

class BoxRenderResources extends React.Component {
  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  render() {
    var resources = this.props.resources
    var actionsDropdownParameters = this.props.actionsDropdownParameters
    var selectedResources = this.props.selectedResources
    var isClient = this.props.isClient
    var showSelectionLimit = this.props.showSelectionLimit
    var selectionLimit = this.props.selectionLimit
    var onSelectResource = this.props.onSelectResource
    var config = this.props.config
    var hoverMenuId = this.props.hoverMenuId
    var withActions = this.props.withActions
    var listMods = this.props.listMods
    const { positionProps } = this.props

    // fetching relations enabled by default if layout is grid + withActions + isClient
    var fetchRelations = isClient && withActions && f.includes(['grid', 'list'], config.layout)

    var renderPage = (page, i) => {
      var renderItem = itemState => {
        return (
          <BoxRenderResource
            resourceState={itemState}
            isClient={isClient}
            onSelectResource={onSelectResource}
            positionProps={positionProps}
            config={config}
            hoverMenuId={hoverMenuId}
            fetchRelations={fetchRelations}
            key={itemState.data.resource.uuid}
            trigger={this.props.trigger}
            isSelected={f.find(selectedResources, sr => sr.uuid == itemState.data.resource.uuid)}
            showActions={ActionsDropdownHelper.showActionsConfig(actionsDropdownParameters)}
          />
        )
      }

      var renderItems = page => {
        return page.map(item => {
          return renderItem(item)
        })
      }

      var renderCounter = () => {
        var pagination = this.props.pagination
        return (
          <BoxPageCounter
            showActions={ActionsDropdownHelper.showActionsConfig(actionsDropdownParameters)}
            selectedResources={selectedResources}
            isClient={isClient}
            showSelectionLimit={showSelectionLimit}
            resources={resources}
            pageResources={f.map(page, i => i.data.resource)}
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
        <li className="ui-resources-page" key={i}>
          {renderCounter()}
          <ul className="ui-resources-page-items">{renderItems(page)}</ul>
        </li>
      )
    }

    var renderPages = () => {
      var pageSize = this.props.perPage

      return f.chunk(resources, pageSize).map((page, i) => {
        return renderPage(page, i)
      })
    }

    var getListClasses = () => {
      return cx(
        config.layout, // base class like "list"
        {
          vertical: config.layout == 'tiles',
          active: withActions
        },
        listMods,
        'ui-resources'
      )
    }

    return <ul className={getListClasses()}>{renderPages()}</ul>
  }
}

module.exports = BoxRenderResources
