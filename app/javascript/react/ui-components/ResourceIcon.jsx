import React from 'react'
import PropTypes from 'prop-types'
import Icon from './Icon.jsx'
import cx from 'classnames'

const ResourceIcon = ({ type, mediaType, thumbnail, tiles, flyout, overrideClasses }) => {
  // media type icon, used instead of image preview if there isn't any

  const mediaTypeIconMapping = mediaType => {
    const map = {
      image: 'fa fa-file-image-o',
      audio: 'fa fa-file-audio-o',
      video: 'fa fa-file-video-o',
      document: 'fa fa-file-o',
      other: 'fa fa-file-o'
    }
    return map[mediaType] || map['other']
  }

  let style = {}
  if (thumbnail) {
    style = {}
  } else if (tiles) {
    style = {
      padding: '64px 0px',
      fontSize: '104px',
      color: '#9a9a9a',
      textAlign: 'center',
      backgroundColor: '#fff'
    }
  } else if (flyout) {
    // The classes fa... bring inline-block automatically, but for sets we must have it anyways.
    style = { fontSize: '26px', padding: '26px', textAlign: 'center', display: 'inline-block' }
  } else {
    style = { fontSize: '104px', padding: '64px', color: '#9a9a9a' }
  }

  if (type === 'MediaEntry') {
    const mediaTypeIcon = mediaTypeIconMapping(mediaType)
    return <i className={cx('ui_media-type-icon', mediaTypeIcon, overrideClasses)} style={style} />
  } else if (type === 'Collection') {
    return <Icon i="set" mods={cx('ui_media-type-icon', overrideClasses)} style={style} />
  } else {
    return <Icon i="bang" mods={cx('ui_media-type-icon', overrideClasses)} style={style} />
  }
}

ResourceIcon.propTypes = {
  type: PropTypes.oneOf(['MediaEntry', 'Collection']).isRequired,
  mediaType: PropTypes.string
}

export default ResourceIcon
module.exports = ResourceIcon
