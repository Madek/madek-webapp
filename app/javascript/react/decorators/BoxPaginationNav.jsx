import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import ActionsBar from '../ui-components/ActionsBar.cjsx'
import Button from '../ui-components/Button.cjsx'
import ButtonGroup from '../ui-components/ButtonGroup.cjsx'
import Waypoint from 'react-waypoint'
import Preloader from '../ui-components/Preloader.cjsx'

class BoxPaginationNav extends React.Component {
  constructor(props) {
    super(props)
  }

  renderAutoscroll() {
    var isLoading = this.props.loadingNextPage

    var renderWaypoint = () => {
      if (isLoading) {
        return null
      }

      return (
        // NOTE: offset means trigger load when page is still *5 screens down*!
        // NOTE: set "random" key to force evaluation on every rerender
        <Waypoint
          onEnter={this.props.onFetchNextPage}
          bottomOffset="-500%"
          key={new Date().getTime()}
        />
      )
    }

    return (
      <div className="ui-actions">
        {renderWaypoint()}
        {isLoading ? (
          <Preloader />
        ) : (
          <Button onClick={this.props.onFetchNextPage}>{t('pagination_nav_loadnext')}</Button>
        )}
      </div>
    )
  }

  renderFallback() {
    var pagination = this.props.staticPagination

    var navLinks = {
      current: {
        href: this.props.permaLink
      },
      prev: pagination.prev
        ? { href: boxSetUrlParams(this.props.currentUrl, { list: pagination.prev }) }
        : null,
      next: pagination.next
        ? { href: boxSetUrlParams(this.props.currentUrl, { list: pagination.next }) }
        : null
    }

    return (
      <div className="no-js">
        <ActionsBar>
          <ButtonGroup mods="mbm">
            <Button {...navLinks.prev} mods="mhn" disabled={!navLinks.prev}>
              {t('pagination_nav_prevpage')}
            </Button>
            <Button {...navLinks.current} mods="mhn">
              {t('pagination_nav_thispage')}
            </Button>
            <Button {...navLinks.next} mods="mhn" disabled={!navLinks.next}>
              {t('pagination_nav_nextpage')}
            </Button>
          </ButtonGroup>
        </ActionsBar>
      </div>
    )
  }

  render() {
    var staticPagination = this.props.staticPagination
    var pageSize = this.props.perPage

    var page = Math.ceil(this.props.resources.length / pageSize)
    var totalPages = staticPagination.total_pages

    // autoscroll:
    if (this.props.isClient) {
      if (!(page - 1 < totalPages - 1)) {
        return null
      }
      return this.renderAutoscroll()
    } else {
      if (!(page - 1 < totalPages)) {
        return null
      }
      return this.renderFallback()
    }
  }
}

module.exports = BoxPaginationNav
