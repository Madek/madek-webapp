import React from 'react'
import ReactDOM from 'react-dom'
import f from 'lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import Modal from '../ui-components/Modal.cjsx'
import Icon from '../ui-components/Icon.cjsx'
import EditTransferResponsibility from '../views/Shared/EditTransferResponsibility.cjsx'

class BoxPageCounter extends React.Component {

  constructor(props) {
    super(props)
  }


  render() {


    var page = this.props.page
    var resources = this.props.resources

    var pagination = page.pagination


    var onSelectPage = null
    var checkState = 'unchecked'

    var showActions = this.props.showActions
    var selection = this.props.selectedResources

    if(this.props.isClient && selection && !f.isEmpty(f.values(showActions))) {
      var selectionCountOnPage = (
        selection
        ?
          f.size(
            page.resources.filter((item) => selection.contains(item.serialize()))
          )
        :
          0
      )

      var fullPageCount = (
        page.pagination.totalPages == page.pagination.page
        ?
          (
            page.pagination.totalCount < resources.perPage * page.pagination.totalPages
            ?
              page.pagination.totalCount - (page.pagination.totalPages - 1) * resources.perPage
            :
              resources.perPage
          )
        :
          resources.perPage
      )

      if(selectionCountOnPage > 0) {
        checkState = 'checked'
        if(selectionCountOnPage < fullPageCount) {
          checkState = 'partial'
        }
      }

      onSelectPage = (event) => {
        event.preventDefault()
        if(selectionCountOnPage > 0) {
          page.resources.forEach((item) => selection.remove(item.serialize()))
        }
        else {
          if(selection.length() > this.props.selectionLimit - page.resources.length)
            this.props.showSelectionLimit('page-selection')
          else
            page.resources.forEach((item) => selection.add(item.serialize()))
        }
      }
    }





    // TMP: this link causes to view to start loading at page Nr. X
    //      it's ONLY needed for some edge cases (viewing page N + 1),
    //      where N = number of pages the browser can handle (memory etc)
    //      BUT the UI is unfinished in this case (no way to scroll "backwards")
    //      SOLUTION: disable the link-click so it is not clicked accidentally
    var checkBoxStyle = {position: 'absolute', right: '0px', top: '0px'}

    var determineIcon = () => {
      if(checkState == 'checked') {
        return <Icon style={checkBoxStyle} i='checkbox-active' />
      }
      else if(checkState == 'partial') {
        return <Icon style={checkBoxStyle} i='checkbox-mixed' />
      }
      else {
        return <Icon style={checkBoxStyle} i='checkbox' />
      }
    }

    var showSelectPage = () => {
      if(!onSelectPage) {
        return
      }

      return (
        <div style={{float: 'right', position: 'relative'}} onClick={onSelectPage}>
          <span style={{marginRight: '20px'}}>Seite auswählen</span>
          {determineIcon()}
        </div>
      )
    }

    return (
      <div className='ui-resources-page-counter ui-pager small'>
        <div style={{display: 'inline-block'}}>Seite {pagination.page} von {pagination.totalPages}</div>
        {showSelectPage()}
      </div>
    )


  }
}

module.exports = BoxPageCounter
