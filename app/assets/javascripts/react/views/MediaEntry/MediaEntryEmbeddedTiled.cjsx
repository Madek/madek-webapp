React = require('react')
f = require('active-lodash')
cx = require('classnames')
t = require('../../../lib/i18n-translate.js')

MediaEntryPreview = require('../../decorators/MediaEntryPreview.jsx')

CAPTION_HEIGHT = 55 # absolute heigth of tile caption in pixels

module.exports = React.createClass
  displayName: 'Views.MediaEntryEmbeddedTiled'
  propTypes:
    get: React.PropTypes.shape(
      media_file: React.PropTypes.object.isRequired # TODO
    ).isRequired


  render: ({get} = @props)->
    {image_url, caption_conf, media_type, type, media_file, embed_config} = get
    {previews, original_file_url} = media_file

    defaultSize = {width: 500, height: 500}

    eWidth = embed_config.width || defaultSize.width
    eHeight = embed_config.height || defaultSize.height

    # for tile body and footer
    linkProps = { href: get.url, target: '_blank' }
    style = {
      maxWidth: (if eWidth > 0 then eWidth + 'px'),
      maxHeight: (if eHeight > 0 then eHeight + 'px'),
      overflow: 'hidden'
    }

    bodyStyle = {
      height: (if eHeight > 0 then (eHeight - CAPTION_HEIGHT) + 'px'),
      width: (if eWidth > 0 then eWidth + 'px'),
      boxShadow: '0 0 150px #575757 inset',
      display: 'table-cell',
      verticalAlign: 'middle'
      textAlign: 'center'
    }

    # TODO: choose appropriate sizes (instad of largest)
    poster = f.chain(previews.images).sortBy('heigth').last().get('url').run()

    fullsize = {
      height: (eHeight - CAPTION_HEIGHT) + 'px',
      width: eWidth + 'px'
    }

    style = f.assign({}, style, {
      width: (if eWidth > 0 then eWidth + 'px'),
      height: (if eHeight > 0 then eHeight + 'px')
    })

    mediaProps = {
      style: {
        maxWidth: eWidth + 'px'
        maxHeight: (eHeight - (1 * CAPTION_HEIGHT)) + 'px'
        minWidth: '100px'
        minHeight: '100px',
      }
    }

    <div style={style}>
      <div className="ui-tile" style={{display: 'block'}}>
        <div className="ui-tile__body" style={bodyStyle}>
          <a {...linkProps}>
            <MediaEntryPreview get={get} mediaProps={mediaProps} />
          </a>
        </div>
        <a
          className="ui-tile__foot"
          {...linkProps}
        >
          <h3 className="ui-tile__title">
            {caption_conf.title}
          </h3>
          <h4 className="ui-tile__meta">
            <span>
              {caption_conf.subtitle}
            </span>
          </h4>
          <span className="ui-tile__flags">
            <i className="icon-link ui-tile__flag ui-tile__flag--type"></i>
          </span>
        </a>
      </div>
    </div>
