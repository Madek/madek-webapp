const React = require('react')
const f = require('active-lodash')
// const cx = require('classnames')
// const t = require('../../../lib/i18n-translate.js')

const MediaEntryPreview = require('../../decorators/MediaEntryPreview.jsx')

// eslint-disable-next-line react/no-deprecated
module.exports = React.createClass({
  displayName: 'Views.MediaEntryEmbedded',
  propTypes: {
    // eslint-disable-next-line react/no-deprecated
    get: React.PropTypes.shape({
      // eslint-disable-next-line react/no-deprecated
      media_file: React.PropTypes.object.isRequired
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
        isInternal={embed_config.isInternal}
      />
    )
  }
})
