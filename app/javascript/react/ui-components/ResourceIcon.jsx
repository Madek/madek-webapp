/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const ui = require('../lib/ui.js')
const t = require('../../lib/i18n-translate.js')
const Picture = require('./Picture.cjsx')
const Icon = require('./Icon.cjsx')
const cx = require('classnames')

module.exports = React.createClass({
  displayName: 'ResourceIcon',
  propTypes: {
    type: React.PropTypes.oneOf(['MediaEntry', 'Collection']).isRequired,
    mediaType: React.PropTypes.string
  },

  render(param) {
    // media type icon, used instead of image preview if there isn't any
    if (param == null) {
      param = this.props
    }
    const { type, mediaType, overrideClasses } = param
    var mediaTypeIcon = (() => {
      const mediaTypeIconMapping = function(mediaType) {
        const map = {
          image: 'fa fa-file-image-o',
          audio: 'fa fa-file-audio-o',
          video: 'fa fa-file-video-o',
          document: 'fa fa-file-o',
          other: 'fa fa-file-o'
        }
        return map[mediaType] || map['other']
      }

      let style = this.props.thumbnail
        ? {}
        : { fontSize: '104px', padding: '64px', color: '#9a9a9a' }
      if (this.props.tiles) {
        style = {
          padding: '64px 0px',
          fontSize: '104px',
          color: '#9a9a9a',
          textAlign: 'center',
          backgroundColor: '#fff'
        }
      }
      if (this.props.flyout) {
        // The classes fa... bring inline-block automatically, but for sets we must have it anyways.
        style = { fontSize: '26px', padding: '26px', textAlign: 'center', display: 'inline-block' }
      }

      switch (false) {
        case type !== 'MediaEntry':
          mediaTypeIcon = mediaTypeIconMapping(mediaType)
          return (
            <i className={cx('ui_media-type-icon', mediaTypeIcon, overrideClasses)} style={style} />
          )
        case type !== 'Collection':
          return <Icon i="set" mods={cx('ui_media-type-icon', overrideClasses)} style={style} />
        default:
          return <Icon i="bang" mods={cx('ui_media-type-icon', overrideClasses)} style={style} />
      }
    })()

    return mediaTypeIcon
  }
})
