import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import BoxBatchEditMetaKeyForm from './BoxBatchEditMetaKeyForm.jsx'
import BoxBatchEditFormKeyBubbles from './BoxBatchEditFormKeyBubbles.jsx'

class BoxMetaKeySelector extends React.Component {

  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    var l = require('lodash')
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  findMetaKeysWithTypes(metaKeyIds) {
    var metaKeysWithTypes = this.props.loadMetaMetaData.data.metaKeysWithTypes
    return l.map(
      metaKeyIds,
      (k) => l.find(metaKeysWithTypes, (mkt) => mkt.metaKeyId == k)
    )
  }

  renderTemplates() {

    return this.renderTemplateEntries()

  }

  renderTemplateEntries() {

    return l.map(
      this.prepareContexts(),
      (pc) => {

        let {type, context, contextKeys} = pc

        var isSelected = () => {
          return this.props.loadMetaMetaData.data.selectedTemplate == context.uuid
        }

        var renderBubbles = () => {
          if(!isSelected()) {
            return null
          }
          var keys = l.map(
            contextKeys,
            (ck) => {
              return {
                metaKey: ck.meta_key,
                contextKey: ck
              }
            }
          )
          return (
            <BoxBatchEditFormKeyBubbles
              keys={keys}
              onClickKey={this.props.onClickKey}
            />
          )
        }

        return (
          <div key={context.uuid}>
            <div>
              <div style={{marginBottom: (isSelected() ? '10px' : '0px')}}>
                <div>
                  <span className={(isSelected() ? 'open' : null)} style={{cursor: 'pointer'}} onClick={(e) => this.props.trigger(this.props.loadMetaMetaData, {action: 'select-template', template: context.uuid})}>
                    <i
                      className={'ui-side-filter-lvl1-marker'}
                      style={{
                        position: 'static',
                        float: 'left',
                        width: '20px',
                        marginTop: '4px'
                      }}
                    />
                    {context.label}
                  </span>
                </div>
                <div style={{marginLeft: '20px', marginTop: '5px'}}>
                  {renderBubbles()}
                </div>
              </div>
            </div>
          </div>
        )
      }
    )
  }

  renderVocabularies() {

    var metaMetaDataForTypes = this.props.loadMetaMetaData.data.metaMetaData

    var vocabularies = l.reduce(
      metaMetaDataForTypes,
      (memo, mmd) => {
        l.each(
          mmd.data.vocabularies_by_vocabulary_id,
          (v, k) => memo[k] = v
        )
        return memo
      },
      {}
    )

    var vocabMetaKeys = l.reduce(
      l.map(metaMetaDataForTypes, (mmd) => mmd.data.meta_key_ids_by_vocabulary_id),
      (memo, vocab2Key) => {
        l.each(
          vocab2Key,
          (v, k) => memo[k] = l.uniq(l.concat((memo[k] ? memo[k] : []), v))
        )
        return memo
      },
      {}
    )

    var metaKeysWithTypes = this.props.loadMetaMetaData.data.metaKeysWithTypes

    return l.map(
      vocabularies,
      (v, k) => {

        var isSelected = () => {
          return this.props.loadMetaMetaData.data.selectedVocabulary == k
        }

        var renderBubbles = () => {
          if(!isSelected()) {
            return null
          }
          var keys = l.map(
            this.findMetaKeysWithTypes(vocabMetaKeys[k]),
            (mkt) => {
              return {
                metaKey: mkt.metaKey,
                contextKey: null
              }
            }
          )
          return (
            <BoxBatchEditFormKeyBubbles
              keys={keys}
              onClickKey={this.props.onClickKey}
            />
          )
        }

        return (
          <div key={k}>
            <div>
              <div style={{marginBottom: (isSelected() ? '10px' : '0px')}}>
                <div>
                  <span className={(isSelected() ? 'open' : null)} style={{cursor: 'pointer'}} onClick={(e) => this.props.trigger(this.props.loadMetaMetaData, {action: 'select-vocabulary', vocabulary: k})}>
                    <i
                      className={'ui-side-filter-lvl1-marker'}
                      style={{
                        position: 'static',
                        float: 'left',
                        width: '20px',
                        marginTop: '4px'
                      }}
                    />
                    {v.label}
                  </span>
                </div>
                <div style={{marginLeft: '20px', marginTop: '5px'}}>
                  {renderBubbles()}
                </div>
              </div>
            </div>
          </div>
        )
      }
    )
  }

  prepareContexts() {

    var data = this.props.loadMetaMetaData.data

    var metaMetaDataForTypes = data.metaMetaData


    var type = () => {
      if(data.selectedTab == 'entries') {
        return 'MediaEntry'
      } else if(data.selectedTab == 'sets') {
        return 'Collection'
      } else {
        throw 'Unexpected template = ' + data.selectedTemplate
      }
    }


    var getMetaData = () => {
      return l.find(metaMetaDataForTypes, (mdft) => mdft.type == type()).data
    }

    var contextsWithType = () => {

      var metaMetaData = getMetaData()

      return l.map(
        metaMetaData.meta_data_edit_context_ids,
        (cid) => {
          return {
            type: type(),
            context: metaMetaData.contexts_by_context_id[cid],
            contextKeys: l.uniqBy(
              l.map(
                metaMetaData.context_key_ids_by_context_id[cid],
                (ckid) => metaMetaData.context_key_by_context_key_id[ckid]
              ),
              (ck) => ck.meta_key_id
            )
          }
        }
      )

    }

    return l.filter(
      l.uniqBy(
        contextsWithType(),
        (ct) => ct.context.uuid
      ),
      (ct) => ct.contextKeys.length > 0
    )
  }

  renderContextTabs() {

    var renderTab = (tab, label) => {

      var className = () => {
        if(tab == this.props.loadMetaMetaData.data.selectedTab) {
          return 'active ui-tabs-item'
        } else {
          return 'ui-tabs-item'
        }
      }

      var onClick = (e) => {
        this.props.trigger(this.props.loadMetaMetaData, {action: 'select-tab', selectedTab: tab})
      }

      return (
        <li className={className()}>
          <a onClick={(e) => onClick(e)}>
            {label}
          </a>
        </li>
      )
    }

    var renderTabContent = () => {
      if(this.props.loadMetaMetaData.data.selectedTab == 'all_data') {
        return this.renderVocabularies()
      } else {
        return this.renderTemplates()
      }
    }

    return (
      <div>
        <ul className='ui-tabs'>
          {renderTab('entries', t('resources_box_batch_entry_contexts'))}
          {renderTab('sets', t('resources_box_batch_set_contexts'))}
          {renderTab('all_data', t('resources_box_batch_all_data'))}
        </ul>
        <div className='ui-container tab-content bordered bright rounded-right rounded-bottom'>
          <div className='phs pts'>
            {renderTabContent()}
          </div>
        </div>
      </div>
    )
  }

  render() {
    return (
      <div>
        {this.renderContextTabs()}
      </div>
    )

  }
}

module.exports = BoxMetaKeySelector
