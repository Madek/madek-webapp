import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import BoxBatchEditMetaKeyForm from './BoxBatchEditMetaKeyForm.jsx'
import BoxBatchEditFormKeyBubbles from './BoxBatchEditFormKeyBubbles.jsx'
import BoxMetaKeySelector from './BoxMetaKeySelector.jsx'
import Preloader from '../ui-components/Preloader.cjsx'

class BoxBatchEditForm extends React.Component {

  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    var l = require('lodash')
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  renderMetaKeyForm(metaKeyForm, resourceStates) {

    var vocabLabel = () => {
      var metaMetaData = this.props.stateBox.components.batch.components.loadMetaMetaData.data.metaMetaData
      var mmd = l.find(
        metaMetaData,
        (mmd) => mmd.data.vocabularies_by_vocabulary_id[metaKeyForm.props.metaKey.vocabulary_id]
      )
      if(mmd) {
        return mmd.data.vocabularies_by_vocabulary_id[metaKeyForm.props.metaKey.vocabulary_id].label
      } else {
        return null
      }
    }

    return (
      <div key={metaKeyForm.props.metaKeyId} style={{backgroundColor: '#fff', borderRadius: '5px', border: '1px solid #cccccc', padding: '10px', marginBottom: '5px'}}>
        <BoxBatchEditMetaKeyForm
          trigger={this.props.trigger}
          metaKeyForm={metaKeyForm}
          resourceStates={resourceStates}
          editable={!this.showProgressBar()}
          vocabLabel={vocabLabel()}
        />
      </div>
    )
  }

  stateBox() {
    return this.props.stateBox
  }

  stateBatch() {
    return this.stateBox().components.batch
  }

  toApplyCount() {
    if(!this.applyJob()) {
      return 0
    } else {
      return this.applyJob().processing.length
    }
  }

  totalCount() {
    return this.stateBox().components.resources.length
  }

  renderKeyForms() {
    let {components} = this.stateBatch()

    return l.map(
      components.metaKeyForms,
      (metaKeyForm) => this.renderMetaKeyForm(metaKeyForm, this.stateBox().components.resources)
    )
  }

  renderHint() {

    if(this.toApplyCount() == 0) {
      return null
    }

    return (
      <div
        style={{
          textAlign: 'center',
          fontSize: '16px',
          color: '#b59d6e',
          marginBottom: '20px',
          marginTop: '40px'
        }}
      >
        <i
          className='icon-bang'
          style={{
            display: 'inline-block',
            width: '40px',
            position: 'relative',
            top: '2px',
            fontSize: '24px'
          }}
        />
        {t('resources_box_batch_please_wait_and_done_leave')}
      </div>
    )
  }

  editableSelectedCount() {
    return l.size(
      l.filter(
        this.stateBox().data.selectedResources,
        (r) => r.editable
      )
    )
  }

  editableEntriesSelectedCount() {
    return l.size(
      l.filter(
        this.stateBox().data.selectedResources,
        (r) => r.type == 'MediaEntry' && r.editable
      )
    )
  }

  editableCollectionsSelectedCount() {
    return l.size(
      l.filter(
        this.stateBox().data.selectedResources,
        (r) => r.type == 'Collection' && r.editable
      )
    )
  }

  editableCount() {
    return l.size(
      l.filter(
        this.stateBox().components.resources,
        (rs) => rs.data.resource.editable
      )
    )
  }

  editableEntriesCount() {
    return l.size(
      l.filter(
        this.stateBox().components.resources,
        (rs) => rs.data.resource.type == 'MediaEntry' && rs.data.resource.editable
      )
    )
  }

  editableCollectionsCount() {
    return l.size(
      l.filter(
        this.stateBox().components.resources,
        (rs) => rs.data.resource.type == 'Collection' && rs.data.resource.editable
      )
    )
  }

  selectedCount() {
    return this.stateBox().data.selectedResources.length
  }


  renderApplySelected() {

    if(!this.showButtons()) {
      return null
    }

    if(this.stateBatch().components.metaKeyForms.length == 0) {
      return null
    }


    // if(this.selectedCount() == 0) {
    //   return null
    // }

    var hasSelection = () => {
      return this.selectedCount() > 0
    }

    var renderText = () => {
      return t('resources_box_batch_apply_on_selected_1') + this.editableSelectedCount() + t('resources_box_batch_apply_on_selected_2')
    }

    return (
      <div
        style={{
          float: 'left',
          backgroundColor: '#fff',
          borderRadius: '5px',
          border: '1px solid #cccccc',
          padding: '10px',
          marginLeft: '5px'
        }}
      >
        <div>
          <h2 className='title-m ui-info-box-title mbm'>{t('resources_box_batch_selected_content')}</h2>
          <div>&nbsp;</div>
          <div>{t('resources_box_batch_stats_where_selected') + ' ' + this.selectedCount()}</div>
          <div>{t('resources_box_batch_stats_where_editable') + ' ' + this.editableSelectedCount()}</div>
        </div>
        <div>
          <div
            style={{
              marginTop: '10px',
              fontSize: '20px'
            }}
          >
            {this.editableEntriesSelectedCount() + ' ' + t('resources_box_batch_stats_entries') + ' ' + this.editableCollectionsSelectedCount() + ' ' + t('resources_box_batch_stats_collections')}
          </div>
        </div>
        <div
          onClick={(hasSelection() ? this.props.onClickApplySelected : null)}
          className='primary-button'
          disabled={(hasSelection() ? null: 'disabled')}
          style={{
            display: 'inline-block',
            padding: '0px 10px',
            marginRight: '5px',
            marginBottom: '5px',
            cursor: 'pointer',
            marginTop: '5px'
          }}
        >
          {renderText()}
        </div>
      </div>
    )

  }

  applyJob() {
    return this.stateBatch().data.applyJob
  }

  loadedCount() {
    return this.stateBox().components.resources.length
  }

  showButtons() {
    if(!this.applyJob()) {
      return true
    }

    return this.applyJob().processing.length == 0 && this.applyJob().failure.length == 0
  }

  showProgressBar() {

    if(!this.applyJob()) {
      return false
    }

    return true
    // var toApply = this.toApplyCount()
    //
    // var errorCount = () => {
    //   return this.applyJob().failure.length
    // }
    //
    // return toApply > 0 || errorCount() > 0
  }

  renderApplyAll() {

    if(!this.showButtons()) {
      return null
    }

    if(this.stateBatch().components.metaKeyForms.length == 0) {
      return null
    }


    var totalCount = () => {
      return this.props.totalCount
    }


    var renderText = () => {

      if(this.loadedCount() == totalCount()) {
        return t('resources_box_batch_apply_on_all_1') + this.editableCount() + t('resources_box_batch_apply_on_all_2')
      } else {
        return t('resources_box_batch_load_all_pages')
      }

      // Auf alle anwenden
    }

    return (
      <div
        style={{
          float: 'left',
          backgroundColor: '#fff',
          borderRadius: '5px',
          border: '1px solid #cccccc',
          padding: '10px'
        }}
      >
        <div>
          <h2 className='title-m ui-info-box-title mbm'>{t('resources_box_batch_all_content')}</h2>
          <div>{t('resources_box_batch_stats_total') + ' ' + this.props.totalCount}</div>
          <div>{t('resources_box_batch_stats_where_loaded') + ' ' + this.loadedCount()}</div>
          <div>{t('resources_box_batch_stats_where_editable') + ' ' + this.editableCount()}</div>
        </div>
        <div>
          <div
            style={{
              marginTop: '10px',
              fontSize: '20px'
            }}
          >
            {(
              this.loadedCount() != totalCount()
              ? <span>&nbsp;</span>
              : (this.editableEntriesCount() + ' ' + t('resources_box_batch_stats_entries') + ' ' + this.editableCollectionsCount() + ' ' + t('resources_box_batch_stats_collections'))
            )}
          </div>
        </div>
        <div
          onClick={(this.toApplyCount() > 0 || this.loadedCount() != totalCount() ? null : this.props.onClickApplyAll)}
          className='primary-button'
          disabled={(this.toApplyCount() > 0 || this.loadedCount() != totalCount() ? 'disabled' : null)}
          style={{
            display: 'inline-block',
            padding: '0px 10px',
            marginRight: '5px',
            marginBottom: '5px',
            cursor: 'pointer',
            marginTop: '5px'
          }}
        >
          {renderText()}
        </div>
      </div>
    )
  }



  renderProgress() {

    if(!this.showProgressBar()) {
      return null
    }

    var total = this.totalCount()
    var toApply = this.toApplyCount()

    var pendingCount = () => {
      return this.applyJob().pending.length
    }

    var applyingCount = () => {
      return this.applyJob().processing.length
    }

    var doneCount = () => {
      return this.applyJob().success.length
    }

    var errorCount = () => {
      return this.applyJob().failure.length
    }

    // if(toApply == 0 && errorCount() == 0) {
    //   return null
    // }

    var processingTotalCount = () => {
      return pendingCount() + applyingCount() + doneCount()
    }

    var renderIgnoreFailures = () => {

      var showIgnore = () => {
        return pendingCount() == 0 && applyingCount() == 0 && toApply == 0 && errorCount() > 0
      }

      if(!showIgnore()) {
        return null
      }

      return (
        <div
          className='primary-button'
          style={{
            display: 'inline-block',
            backgroundImage: 'linear-gradient(#F44336, #c53434)',
            border: '1px solid #6f0d0d'
          }}
          onClick={this.props.onClickIgnore}
        >
          {t('resources_box_batch_ignore_failures')}
        </div>
      )
    }

    var renderCancel = () => {

      if(pendingCount() == 0) {
        return null
      }

      return (
        <div
          className='button'
          style={{
            // display: 'inline-block',
            // borderRadius: '5px',
            // backgroundColor: '#3c3c3c',
            // color: '#fff',
            // padding: '0px 10px',
            // fontSize: '14px',
            // cursor: 'pointer',
            // float: 'right',
            // marginTop: '1px'
          }}
          onClick={this.props.onClickCancel}
        >
          {t('resources_box_batch_cancel_waiting')}
        </div>
      )
    }

    var renderErrors = () => {
      if(errorCount() == 0) {
        return null
      }

      return (
        <span>
          {', '}
          <span style={{color: '#f00'}}>
            {errorCount() + t('resources_box_batch_loading_stats_failed')}
          </span>
        </span>
      )
    }

    var renderText = () => {

      if(pendingCount() == 0 && applyingCount() == 0 && errorCount() == 0) {
        return doneCount() + t('resources_box_batch_processing_successful')
      } else {
        return (
          processingTotalCount() + t('resources_box_batch_loading_stats_total') +
          applyingCount() + t('resources_box_batch_loading_stats_applying') +
          pendingCount() + t('resources_box_batch_loading_stats_pending') +
          doneCount() + t('resources_box_batch_loading_stats_done')
        )
      }
    }

    return (
      <div style={{backgroundColor: '#bfda80', borderRadius: '5px', color: '#fff', textAlign: 'center', fontSize: '16px', padding: '3px'}}>
        <div>
          {renderText()}
          {renderErrors()}
        </div>
        <div>
          {renderCancel()}
          {renderIgnoreFailures()}
        </div>
      </div>
    )
  }




  renderInvalidMessage() {

    if(l.isEmpty(this.props.stateBox.components.batch.data.invalidMetaKeyUuids)) {
      return null
    }

    return (
      <div style={{color: '#f00'}}>
        {t('resources_box_batch_fill_in_all_fields_hint')}
      </div>
    )
  }

  // renderSuccessMessage() {
  //
  //   if(this.props.stateBox.components.batch.data.resultMessage.status == 'hidden') {
  //     return null
  //   }
  //
  //   return (
  //     <div style={{clear: 'both', paddingTop: '10px'}}>
  //
  //       <div
  //         style={{
  //           backgroundColor: '#bfda80',
  //           borderRadius: '5px',
  //           color: '#fff',
  //           textAlign: 'center',
  //           fontSize: '16px',
  //           padding: '3px',
  //           // opacity: (this.props.stateBox.components.batch.data.resultMessage.status == 'success' ? '1' : '0'),
  //           // transition: 'opacity 0.5s linear'
  //         }}
  //       >
  //         <div>
  //           {this.props.stateBox.components.batch.data.resultMessage.count + t('resources_box_batch_processing_successful')}
  //         </div>
  //       </div>
  //     </div>
  //   )
  //
  // }

  anyFieldSelected() {
    return this.stateBatch().components.metaKeyForms.length > 0
  }

  renderRightSide() {

    if(!this.anyFieldSelected()) {
      return null
    }

    return (
      <div>
        <h2 className='title-l ui-info-box-title mbm'>{t('resources_box_batch_enter_metadata')}</h2>


        <div style={{paddingTop: '26px'}}>
          {this.renderInvalidMessage()}
          {this.renderKeyForms()}

          <div style={{marginTop: '20px'}}>
            {this.renderApplyAll()}
            {this.renderApplySelected()}
          </div>
          <div style={{paddingTop: '20px', clear: 'both'}}>
            {this.renderHint()}
            {this.renderProgress()}
          </div>
        </div>
      </div>
    )

  }

  render() {

    let {data, components} = this.stateBatch()

    if(!data.open) {
      return null
    } else {

      if(this.props.stateBox.components.batch.components.loadMetaMetaData.data.metaMetaData.length != 2) {
        return (
          <div className='ui-resources-holder pbm'>
            <Preloader />
          </div>
        )
      }

      return (
        <div className='ui-resources-holder pbm'>

          <div style={{textAlign: 'right', marginBottom: '10px', float: 'right'}}>
            <a className='button' onClick={this.props.onClose}>
              <i className='icon-close'></i>
              {' '}
              {t('resources_box_batch_close')}
            </a>
          </div>

          <div style={{width: '40%', float: 'left', clear: 'both'}}>
            <h2 className='title-l ui-info-box-title mbm'>{t('resources_box_batch_select_fields')}</h2>
            <div style={{marginRight: '30px'}}>
              <BoxMetaKeySelector trigger={this.props.trigger} loadMetaMetaData={this.props.stateBox.components.batch.components.loadMetaMetaData} onClickKey={this.props.onClickKey} />
            </div>
          </div>
          <div style={{width: '60%', float: 'right'}}>
            {this.renderRightSide()}
          </div>
        </div>
      )
    }
  }
}

module.exports = BoxBatchEditForm
