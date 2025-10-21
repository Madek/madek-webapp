import React from 'react'
import PropTypes from 'prop-types'
import MediaEntryPreview from '../../decorators/MediaEntryPreview.jsx'

const MediaEntryEmbedded = ({ get }) => {
  const { caption_conf, media_type, embed_config } = get

  const defaultSize = {
    width: 500,
    height: media_type === 'audio' ? 200 : 500,
    ratio: '16:9'
  }

  const eWidth = embed_config.width || defaultSize.width
  const eHeight = embed_config.height || defaultSize.height
  const fullsize = {
    height: eHeight + 'px',
    width: eWidth + 'px'
  }

  const mediaProps = {
    ...fullsize,
    options: {
      fluid: false,
      height: eHeight,
      width: eWidth,
      ratio: embed_config.ratio || defaultSize.ratio
    }
  }

  return (
    <MediaEntryPreview
      get={get}
      mediaProps={mediaProps}
      captionConf={caption_conf}
      isEmbedded={true}
      isInternal={embed_config.isInternal}
    />
  )
}

MediaEntryEmbedded.propTypes = {
  get: PropTypes.shape({
    media_file: PropTypes.object.isRequired
  }).isRequired
}

export default MediaEntryEmbedded
module.exports = MediaEntryEmbedded
