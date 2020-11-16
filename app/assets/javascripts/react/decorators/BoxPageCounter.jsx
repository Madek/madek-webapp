import React from 'react'
import ReactDOM from 'react-dom'
import f from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import Icon from '../ui-components/Icon.cjsx'

class BoxPageCounter extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    var resources = this.props.resources

    var pageResources = this.props.pageResources

    var pagination = this.props.pagination
    var perPage = this.props.perPage

    var totalPages = pagination.total_pages
    var totalCount = pagination.total_count
    var page = this.props.pageIndex + 1

    var onSelectPage = null
    var checkState = 'unchecked'

    var showActions = this.props.showActions
    var selection = this.props.selectedResources

    if (this.props.isClient && selection && !f.isEmpty(f.values(showActions))) {
      var selectionCountOnPage = selection
        ? f.size(
            pageResources.filter(item => {
              return f.find(selection, sr => sr.uuid == item.uuid)
            })
          )
        : 0

      var fullPageCount =
        totalPages == page
          ? totalCount < perPage * totalPages
            ? totalCount - (totalPages - 1) * perPage
            : perPage
          : perPage

      if (selectionCountOnPage > 0) {
        checkState = 'checked'
        if (selectionCountOnPage < fullPageCount) {
          checkState = 'partial'
        }
      }

      onSelectPage = event => {
        event.preventDefault()
        if (selectionCountOnPage > 0) {
          this.props.unselectResources(pageResources)
          // pageResources.forEach((item) => selection.remove(item))
        } else {
          if (selection.length > this.props.selectionLimit - pageResources.length)
            this.props.showSelectionLimit('page-selection')
          else this.props.selectResources(pageResources)
          // pageResources.forEach((item) => selection.add(item))
        }
      }
    }

    // TMP: this link causes to view to start loading at page Nr. X
    //      it's ONLY needed for some edge cases (viewing page N + 1),
    //      where N = number of pages the browser can handle (memory etc)
    //      BUT the UI is unfinished in this case (no way to scroll "backwards")
    //      SOLUTION: disable the link-click so it is not clicked accidentally
    var checkBoxStyle = { position: 'absolute', right: '0px', top: '0px' }

    var determineIcon = () => {
      if (checkState == 'checked') {
        return <Icon style={checkBoxStyle} i="checkbox-active" />
      } else if (checkState == 'partial') {
        return <Icon style={checkBoxStyle} i="checkbox-mixed" />
      } else {
        return <Icon style={checkBoxStyle} i="checkbox" />
      }
    }

    var showSelectPage = () => {
      if (!onSelectPage) {
        return
      }

      return (
        <div style={{ float: 'right', position: 'relative' }} onClick={onSelectPage}>
          <span style={{ marginRight: '20px' }}>{t('pagination_selection_label')}</span>
          {determineIcon()}
        </div>
      )
    }

    return (
      <div className="ui-resources-page-counter ui-pager small">
        <div style={{ display: 'inline-block' }}>
          {t('pagination_prefix')}
          {page}
          {t('pagination_infix')}
          {totalPages}
          {t('pagination_postfix')}
        </div>
        {showSelectPage()}
      </div>
    )
  }
}

module.exports = BoxPageCounter
