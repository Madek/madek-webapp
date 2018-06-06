import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import Modal from '../ui-components/Modal.cjsx'
import ActionsBar from '../ui-components/ActionsBar.cjsx'
import Button from '../ui-components/Button.cjsx'
import ButtonGroup from '../ui-components/ButtonGroup.cjsx'
import Waypoint from 'react-waypoint'
import EditTransferResponsibility from '../views/Shared/EditTransferResponsibility.cjsx'

class BoxPaginationNav extends React.Component {

  constructor(props) {
    super(props)
  }


  renderAutoscroll() {
    var isLoading = this.props.loadingNextPage

    var renderWaypoint = () => {
      if(isLoading) {
        return null
      }

      return (
        // NOTE: offset means trigger load when page is still *5 screens down*!
        // NOTE: set "random" key to force evaluation on every rerender
        <Waypoint onEnter={this.props.onFetchNextPage} bottomOffset='-500%' key={(new Date()).getTime()}/>
      )
    }

    var renderLoading = () => {
      if(!isLoading) {
        return t('pagination_nav_loadnext')
      }
      else {
        return t('pagination_nav_nextloading')
      }
    }

    return (
      <div className='ui-actions'>
        {renderWaypoint()}
        <Button onClick={this.props.onFetchNextPage}>
          {renderLoading()}
        </Button>
      </div>
    )
  }

  renderFallback() {

    var pagination = this.props.staticPagination

    var navLinks = {
      current: {
        href: this.props.permaLink,
        onClick: this.props.handleChangeInternally
      },
      prev: (
        pagination.prev
        ? { href: boxSetUrlParams(this.props.currentUrl, {list: pagination.prev}) }
        : null
      ),
      next: (
        pagination.next
        ? { href: boxSetUrlParams(this.props.currentUrl, {list: pagination.next}) }
        : null
      )
    }

    return (
      <div className='no-js'>
        <ActionsBar>
          <ButtonGroup mods='mbm'>
            <Button {...navLinks.prev} mods='mhn' disabled={!navLinks.prev}>{t('pagination_nav_prevpage')}</Button>
            <Button {...navLinks.current} mods='mhn'>{t('pagination_nav_thispage')}</Button>
            <Button {...navLinks.next} mods='mhn' disabled={!navLinks.next}>{t('pagination_nav_nextpage')}</Button>
          </ButtonGroup>
        </ActionsBar>
      </div>
    )
  }

  render() {

    var staticPagination = this.props.staticPagination

    var pagination = f.get(f.last(this.props.resources.pages), 'pagination') || staticPagination

    if(!f.present(pagination)) {
      return null
    }


    // autoscroll:
    if(this.props.isClient) {
      if(pagination.page - 1 >= pagination.totalPages - 1) {
        return null
      }
      return this.renderAutoscroll()
    } else {
      if(pagination.page - 1 >= pagination.totalPages) {
        return null
      }
      return this.renderFallback()
    }

  }
}

module.exports = BoxPaginationNav
