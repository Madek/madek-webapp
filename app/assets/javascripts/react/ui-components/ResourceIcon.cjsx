React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')
t = require('../../lib/i18n-translate.js')
Picture = require('./Picture.cjsx')
Icon = require('./Icon.cjsx')
cx = require('classnames')

module.exports = React.createClass
  displayName: 'ResourceIcon'
  propTypes:
    type: React.PropTypes.oneOf(['MediaEntry', 'FilterSet', 'Collection']).isRequired
    mediaType: React.PropTypes.string

  render: ({type, mediaType, overrideClasses} = @props)->


    # media type icon, used instead of image preview if there isn't any
    mediaTypeIcon = do () =>
      mediaTypeIconMapping = (mediaType)->
        map =
          'image':    'fa fa-file-image-o'
          'audio':    'fa fa-file-audio-o'
          'video':    'fa fa-file-video-o'
          'document': 'fa fa-file-o' # TODO: 'text' and 'pdf' when mapping exists…
          'other':    'fa fa-file-o' # TODO: 'archive' when 'compressed' exists…
        map[mediaType] or map['other']

      style = if @props.thumbnail then { } else { fontSize: '104px', padding: '64px', color: '#9a9a9a' }
      if @props.tiles
        style = { padding: '64px 0px', fontSize: '104px', color: '#9a9a9a', textAlign: 'center', backgroundColor: '#fff' }
      if @props.flyout
        # The classes fa... bring inline-block automatically, but for sets we must have it anyways.
        style = { fontSize: '26px', padding: '26px', textAlign: 'center', display: 'inline-block'}

      switch
        when type is 'MediaEntry'
          mediaTypeIcon = mediaTypeIconMapping(mediaType)
          <i className={cx('ui_media-type-icon', mediaTypeIcon, overrideClasses)} style={style} />
        when type is 'Collection'
          <Icon i='set' mods={cx('ui_media-type-icon', overrideClasses)} style={style} />
        when type is 'FilterSet'
          <Icon i='set' mods={cx('ui_media-type-icon', overrideClasses)} style={style} />
        else
          <Icon i='bang' mods={cx('ui_media-type-icon', overrideClasses)} style={style} />

    mediaTypeIcon
