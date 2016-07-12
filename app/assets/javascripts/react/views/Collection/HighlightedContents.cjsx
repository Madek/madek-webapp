React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')

cx = require('classnames')

module.exports = React.createClass
  displayName: 'HighlightedContents'
  render: ({get, authToken} = @props) ->

    if f.isEmpty(get.highlighted_media_resources.resources)
      return null

    <div className='ui-container midtone-darker bordered'>
      <div className='ui-container inverted ui-toolbar phs pvx'>
        <h2 className='ui-toolbar-header'>
          {t('collection_highlighted_contents')}
        </h2>
      </div>
      <div className='ui-featured-entries ptl phm'>
        <ul className='ui-featured-entries-list ui-resources tiles horizontal large'>
          {
            f.map(
              f.union(
                f.filter(get.highlighted_media_resources.resources, {type: 'MediaEntry'}),
                f.filter(get.highlighted_media_resources.resources, {type: 'Collection'})
              ),
              (mediaResource, index) ->
                <HighlightedContent key={'key_' + index} mediaResource={mediaResource} />
            )
          }
        </ul>
      </div>
    </div>


HighlightedContent = React.createClass
  displayName: 'HighlightedContent'

  render: ({mediaResource} = @props) ->
    iconMapping = {'public': 'open', 'private': 'private', 'shared': 'group'}
    iconName = "privacy-#{iconMapping[mediaResource.privacy_status]}"

    aClass = cx('ui-tile', {'ui-tile--set': mediaResource.type == 'Collection'})

    imgStyle = {
      backgroundColor: 'rgba(1.0, 1.0, 1.0, 0.3)', #'rgba(0, 0, 0, 0.3)',
      boxShadow: '0 0 150px #575757 inset'
    }

    if not mediaResource.image_url
      imgStyle.width = '300px'

    <a className={aClass} href={mediaResource.url} style={{marginLeft: '5px'}}>
      <div className='ui-tile__body'>
        <div className='ui-tile__thumbnail'>
          <img className='ui-tile__image' src={mediaResource.image_url}
            style={imgStyle}></img>
        </div>
      </div>
      <div className='ui-tile__foot'>
        <h3 className='ui-tile__title'>{mediaResource.title}</h3>
        <h4 className='ui-tile__meta'>{mediaResource.authors_pretty}</h4>
        <span className='ui-tile__flags'>
          <i className={'icon-' + iconName} title='TODO'></i>
        </span>
      </div>
    </a>
