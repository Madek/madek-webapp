import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import MediaEntryPreview from '../../decorators/MediaEntryPreview.jsx'

module.exports = createReactClass({
  displayName: 'Views.MediaEntryEmbedded',
  propTypes: {
    get: PropTypes.shape({
      media_file: PropTypes.object.isRequired
    }).isRequired
  },

  render({ get } = this.props) {
    const { caption_conf, media_type, embed_config } = get

    const defaultSize = {
      width: 500,
      height: media_type == 'audio' ? 200 : 500,
      ratio: '16:9'
    }

    const eWidth = embed_config.width || defaultSize.width
    const eHeight = embed_config.height || defaultSize.height
    const fullsize = {
      height: eHeight + 'px',
      width: eWidth + 'px'
    }

    const mediaProps = f.merge(fullsize, {
      options: {
        fluid: false,
        height: eHeight,
        width: eWidth,
        ratio: embed_config.ratio || defaultSize.ratio
      }
    })

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
})
