import React from 'react'
import ReactDOM from 'react-dom'
import f from 'lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'


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

  render() {

    return (
      <BoxTitlebarRender
        heading={this.getHeading()}
        mods={this.props.toolbarClasses}
        layouts={this.props.layouts}
        centerActions={this.getCenterActions()}
        onSortItemClick={this.props.onSortItemClick}
        dropdownItems={this.props.dropdownItems}
        selectedSort={this.props.order}
        enableOrdering={this.props.enableOrdering} />
    )
  }
}

module.exports = BoxTitlebar
