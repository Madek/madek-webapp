React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')
t = require('../../lib/string-translation')('de')
Picture = require('./Picture.cjsx')
Icon = require('./Icon.cjsx')
cx = require('classnames')

module.exports = React.createClass
  displayName: 'ResourceIcon'
  propTypes:
    type: React.PropTypes.oneOf(['MediaEntry', 'FilterSet', 'Collection']).isRequired
    mediaType: React.PropTypes.string

  render: ({type, mediaType} = @props)->


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

      switch
        when type is 'MediaEntry'
          mediaTypeIcon = mediaTypeIconMapping(mediaType)
          <i className={cx('ui_media-type-icon', mediaTypeIcon)} style={style} />
        when type is 'Collection'
          <Icon i='set' mods='ui_media-type-icon' style={style} />
        when type is 'FilterSet'
          <Icon i='set' mods='ui_media-type-icon' style={style} />
        else
          <Icon i='bang' mods='ui_media-type-icon' style={style} />

    mediaTypeIcon