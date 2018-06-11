import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'



class BoxTitlebar extends React.Component {

  constructor(props) {
    super(props)
  }

  getHeading() {
    var heading = this.props.heading
    if(heading) {
      return heading
    } else {

      var totalCount = this.props.totalCount
      if(totalCount) {
        return totalCount + ' ' + t('resources_box_title_count_post')
      } else {
        return null
      }
    }
  }

  getDropdownItems() {
    var currentUrl = this.props.currentUrl
    return f.compact([
      {
        label: t('collection_sorting_created_at_asc'),
        key: 'created_at ASC',
        href: boxSetUrlParams(currentUrl, {list: {order: 'created_at ASC'}})
      },
      {
        label: t('collection_sorting_created_at_desc'),
        key: 'created_at DESC',
        href: boxSetUrlParams(currentUrl, {list: {order: 'created_at DESC'}})
      },

      (
        this.props.enableOrderByTitle ?
          {
            label: t('collection_sorting_title_asc'),
            key: 'title ASC',
            href: boxSetUrlParams(currentUrl, {list: {order: 'title ASC'}})
          }
        :
          null
      ),
      {
        label: t('collection_sorting_last_change'),
        key: 'last_change',
        href: boxSetUrlParams(currentUrl, {list: {order: 'last_change'}})
      }
    ])
  }


  getCenterDisabled() {
    if(!this.getLayoutChanged()) {
      return 'disabled'
    } else {
      return null
    }
  }

  getLayoutChanged() {
    return (this.props.savedLayout !== this.props.layout || this.props.savedOrder !== this.props.order)
  }

  getCenterActions() {

    if(!this.props.collectionData || !this.props.collectionData.editable) {
      return []
    }

    var layoutChanged = this.getLayoutChanged()
    var text = (layoutChanged ? t('collection_layout_save') : t('collection_layout_saved'))

    return [
      <a key='collection_layout' disabled={this.getCenterDisabled()}
        className={cx('small ui-toolbar-vis-button button', {active: !layoutChanged})}
        title={text}
        onClick={(layoutChanged ? (e) => {this.props.layoutSave(e)} : null)}>
        <i className='icon-fixed-width icon-eye bright'></i>
        <span className='text'>
          {' ' + text}
        </span>
      </a>
    ]
  }

  toolbarClasses() {
    var BoxUtil = require('./BoxUtil.js')
    var boxClasses = BoxUtil.boxClasses(this.props.mods)

    if(f.includes(boxClasses, 'rounded-right')) {
      return 'rounded-top-right'
    }
    else if(f.includes(boxClasses, 'rounded-left')) {
      return 'rounded-top-left'
    }
    else if(f.includes(boxClasses, 'rounded-bottom')) {
      return null
    }
    else if(f.includes(boxClasses, 'rounded')) { // also for 'rounded-top'…
      return 'rounded-top'
    } else {
      return null
    }
  }

  render() {

    return (
      <BoxTitlebarRender
        heading={this.getHeading()}
        mods={this.toolbarClasses()}
        layouts={this.props.layouts}
        centerActions={this.getCenterActions()}
        onSortItemClick={this.props.onSortItemClick}
        dropdownItems={this.getDropdownItems()}
        selectedSort={this.props.order}
        enableOrdering={this.props.enableOrdering} />
    )
  }
}

module.exports = BoxTitlebar
