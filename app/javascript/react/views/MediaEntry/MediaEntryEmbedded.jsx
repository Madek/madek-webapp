import React from 'react'
import PropTypes from 'prop-types'
import MediaEntryPreview from '../../decorators/MediaEntryPreview.jsx'

const MediaEntryEmbedded = ({ get }) => {
  const { caption_conf, embed_config } = get
  const ratio = embed_config.ratio || '16:9'

  // Audio and video both live in a sized iframe (detail preview, oEmbed, fullscreen).
  // A fixed pixel box overflows that frame and clips the player.
  const mediaProps = {
    options: {
      fluid: false,
      fill: true,
      ratio
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
