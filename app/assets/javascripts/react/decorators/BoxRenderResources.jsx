import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import setsFallbackUrl from '../../lib/sets-fallback-url.coffee'
import Preloader from '../ui-components/Preloader.cjsx'
import ActionsDropdown from './resourcesbox/ActionsDropdown.cjsx'
import ResourceThumbnail from './ResourceThumbnail.cjsx'

class BoxRenderResources extends React.Component {

  constructor(props) {
    super(props)
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
    var fetchRelations = this.props.fetchRelations
    var authToken = this.props.authToken

    var renderPage = (page, i) => {

      var renderItem = (item) => {
        if(!item.uuid) {
          // should not be the case anymore after uploader is not using this box anymore
          throw new Error('no uuid')
        }

        var key = item.uuid // or item.cid

        var style = null
        var selection = selectedResources
        // selection defined means selection is enabled
        var showActions = ActionsDropdown.showActionsConfig(actionsDropdownParameters)
        if(isClient && selection && f.any(f.values(showActions))) {
          var isSelected = selectedResources.contains(item.serialize())
          var onSelect = f.curry(onSelectResource)(item)
          // if in selection mode, intercept clicks as 'select toggle'
          var onClick = null
          if(config.layout == 'miniature' && !selection.empty()) {
            onClick = onSelect
          }

          //  when hightlighting editables, we just dim everything else:
          if(ActionsDropdown.isResourceNotInScope(item, isSelected, hoverMenuId)) {
            style = {opacity: 0.35}
          }

        }


        // TODO: get={model}
        return (
          <ResourceThumbnail elm='div'
            style={style}
            get={item}
            isClient={isClient} fetchRelations={fetchRelations}
            isSelected={isSelected} onSelect={onSelect} onClick={onClick}
            authToken={authToken} key={key}
            pinThumb={config.layout == 'tiles'}
            listThumb={config.layout == 'list'}
          />
        )
      }

      var renderItems = (page) => {
        return page.resources.map((item) => {
          return renderItem(item)
        })
      }


      var renderCounter = () => {
        var pagination = f.presence(page.pagination)
        if(!pagination) {
          return null
        }
        var BoxPageCounter = require('./BoxPageCounter.jsx')
        return (
          <BoxPageCounter
            showActions={ActionsDropdown.showActionsConfig(actionsDropdownParameters)}
            selectedResources={selectedResources}
            isClient={isClient}
            showSelectionLimit={showSelectionLimit}
            page={page}
            resources={resources}
            selectionLimit={selectionLimit}
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
      return (resources.pages || [{resources}]).map((page, i) => {
        return renderPage(page, i)
      })
    }


    return (
      <ul className={listClasses}>
        {renderPages()}
      </ul>
    )
  }
}

module.exports = BoxRenderResources
