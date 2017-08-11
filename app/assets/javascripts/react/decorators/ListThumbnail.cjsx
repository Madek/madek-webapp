React = require('react')
async = require('async')
f = require('active-lodash')
c = require('classnames')
t = require('../../lib/i18n-translate.js')
Picture = require('../ui-components/Picture.cjsx')
Button = require('../ui-components/Button.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
Link = require('../ui-components/Link.cjsx')
Icon = require('../ui-components/Icon.cjsx')
TagCloud = require('../ui-components/TagCloud.cjsx')
FavoriteButton = require('./thumbnail/FavoriteButton.cjsx')
StatusIcon = require('./thumbnail/StatusIcon.cjsx')
DeleteModal = require('./thumbnail/DeleteModal.cjsx')
MetaDataList = require('./MetaDataList.cjsx')
LoadXhr = require('../../lib/load-xhr.coffee')
Preloader = require('../ui-components/Preloader.cjsx')
Thumbnail = require('../ui-components/Thumbnail.cjsx')
MetaDataTable = require('./MetaDataTable.cjsx')
MetaDataDefinitionList = require('./MetaDataDefinitionList.cjsx')

module.exports = React.createClass
  displayName: 'ListThumbnail'



  render: ({resourceType, imageUrl, mediaType, title, subtitle, mediaUrl, metaData, selectProps, favoriteProps, deleteProps, get} = @props) ->


    listsWithClasses = []
    if metaData
      if metaData.contexts_for_list_details.length > 0
        listsWithClasses.push({
          key: 'context_1'
          className: 'ui-resource-meta'
          list: metaData.contexts_for_list_details[0]
        })
      if metaData.contexts_for_list_details.length > 1
        listsWithClasses.push({
          key: 'context_2'
          className: 'ui-resource-description'
          list: metaData.contexts_for_list_details[1]
        })


    usageData = {
      key: 'usage_data'
      className: 'ui-resource-extension ui-metadata-box',
      list: [
        {
          key: 'responsible',
          type: 'text',
          label: t('usage_data_responsible'),
          value: <TagCloud mod='person' mods='small' list={[{
              href: get.responsible.url
              children: get.responsible.name
              key:  get.responsible.uuid
            }]}></TagCloud>
        },
        {
          key: 'created_at',
          type: 'text',
          label: t('usage_data_import_at'),
          value: get.created_at_pretty
        }
      ]
    }


    iconStyle = {
      position: 'relative'
      top: '2px'
    }

    if get.list_meta_data

      relation_counts = get.list_meta_data.relation_counts

      if relation_counts['parent_collections_count?']
        usageData.list.push({
          key: 'parents',
          type: 'text',
          label: t('usage_data_relations_parents'),
          value: <span>
              {relation_counts.parent_collections_count} <Icon i='set' style={iconStyle} />
            </span>
        })

      if relation_counts['child_collections_count?'] && relation_counts['child_media_entries_count?']
        usageData.list.push({
          key: 'children',
          type: 'text',
          label: t('usage_data_relations_children'),
          value: <span>
              <span>
                {relation_counts.child_collections_count} <Icon i='set' style={iconStyle} />
              </span>
              <span style={{marginLeft: '15px'}}>
                {relation_counts.child_media_entries_count} <Icon i='media-entry' style={iconStyle} />
              </span>
            </span>
        })


    innerImage = if imageUrl
      <Picture mods='ui-thumbnail-image' src={imageUrl} alt={title} />
    else
      <ResourceIcon mediaType={mediaType} thumbnail={true} tiles={false}
        type={resourceType} overrideClasses='ui-thumbnail-image' />

    thumbnailClass = f.kebabCase(resourceType.replace(/Collection/, 'MediaSet'))


    actionLis = []

    liStyle = {
      marginRight: '3px'
      padding: '2px'
    }

    if selectProps and selectProps.onSelect
      selectAction =
        <li className='ui-thumbnail-action' key='selector' style={liStyle}>
          <span className='js-only'>
            <Link onClick={selectProps.onSelect}
              style={selectProps.selectStyle}
              className='ui-thumbnail-action-checkbox'
              title={if selectProps.isSelected then t('resources_box_selection_remove_selection') else t('resources_box_selection_select')}>
              <Icon i='checkbox' mods={if selectProps.isSelected then 'active'}/>
            </Link>
          </span>
        </li>
      actionLis.push(selectAction)

    if favoriteProps && favoriteProps.favoritePolicy
      favorButton = <FavoriteButton modelFavored={favoriteProps.modelFavored}
        favorUrl={favoriteProps.favorUrl} disfavorUrl={favoriteProps.disfavorUrl}
        favorOnClick={favoriteProps.favorOnClick} pendingFavorite={favoriteProps.pendingFavorite}
        stateIsClient={favoriteProps.stateIsClient} authToken={favoriteProps.authToken}
        buttonClass='ui-thumbnail-action-favorite' />
      actionLis.push(
        <li key='favorite' className='ui-thumbnail-action' style={liStyle}>{favorButton}</li>)

    if get.editable
      actionLis.push(
        <li key='edit' className='ui-thumbnail-action' style={liStyle}>
          <Button className='ui-thumbnail-action-favorite' href={get.edit_meta_data_by_context_url}>
            <i className='icon-pen'></i>
          </Button>
        </li>
      )

    if deleteProps && get.destroyable
      actionLis.push(
        <li key='destroy' className='ui-thumbnail-action' style={liStyle}>
          <Button className='ui-thumbnail-action-favorite' onClick={deleteProps.showModal}>
            <i className='icon-trash'></i>
          </Button>
        </li>
      )



    actionsStyle = {
      left: '0px'
      top: '0px'
      right: 'auto'
      bottom: 'auto'
      height: '20px'
      width: '110px'
      position: 'static'
      float: 'left'
    }

    actions = <div className='ui-thumbnail-actions' style={actionsStyle}>
        <ul className='left by-left'>
          {actionLis}
        </ul>
      </div>


    classes = {'ui-resource': true, 'ui-selected': true if (selectProps and selectProps.isSelected)}

    <li className={c(classes)} style={@props.style}>
      <div className="ui-resource-head" style={{marginLeft: '168px'}}>
        {actions}
        <h3 className="ui-resource-title">{title}</h3>
      </div>
      <div className="ui-resource-body">
        <div className="ui-resource-thumbnail">
          <div className={c('ui-thumbnail', thumbnailClass)}>
            <div className="ui-thumbnail-privacy">
              <i className="icon-privacy-group"></i>
            </div>
            <Image innerImage={innerImage} mediaUrl={mediaUrl} />
            <Titles />
          </div>
        </div>
        {
          if deleteProps && deleteProps.stateDeleteModal == true
            <DeleteModal resourceType={get.type} onModalOk={deleteProps.onModalOk}
              onModalCancel={deleteProps.onModalCancel} modalTitle={deleteProps.modalTitle} />
          else
            null
        }
        {
          if metaData
            f.map(listsWithClasses, (item, index) =>
              <div className={item.className} key={item.key}>
                <MetaDataList showTitle={false} mods='ui-resource-meta' listMods='block' type='list'
                  list={item.list} listClasses='borderless block'
                  keyClasses='ui-resource-meta-label' valueClasses='ui-resource-meta-content' />
              </div>
            ).concat(
              <div className={usageData.className} key={usageData.key}>
                <MetaDataDefinitionList labelValuePairs={usageData.list}
                  fallbackMsg={null} tagMods={null} />
              </div>
            )
          else
            <Preloader />
        }

      </div>
    </li>


Image = React.createClass
  displayName: 'Image'
  render: ({old, innerImage, mediaUrl} = @props) ->
    <a className="ui-thumbnail-image-wrapper" href={mediaUrl}>
      <div className="ui-thumbnail-image-holder">
        <div className="ui-thumbnail-table-image-holder">
          <div className="ui-thumbnail-cell-image-holder">
            <div className="ui-thumbnail-inner-image-holder">
              {innerImage}
            </div>
          </div>
        </div>
      </div>
    </a>


Titles = React.createClass
  displayName: 'Titles'
  render: () ->
    <div className="ui-thumbnail-meta">
      <h3 className="ui-thumbnail-meta-title">Name that can easily go onto 2 lines</h3>
      <h4 className="ui-thumbnail-meta-subtitle">Author that can easily go onto 2 lines as well</h4>
    </div>
