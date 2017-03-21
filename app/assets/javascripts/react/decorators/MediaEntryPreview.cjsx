React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
cx = require('classnames')

Link = require('../ui-components/Link.cjsx')
Icon = require('../ui-components/Icon.cjsx')
Picture = require('../ui-components/Picture.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
MediaPlayer = require('../ui-components/MediaPlayer.cjsx')

module.exports = React.createClass({
  displayName: 'MediaEntryPreview',
  propTypes: {
    get: PropTypes.shape({
      title: PropTypes.string.isRequired,
      # image_url: PropTypes.string.isRequired,
      media_file: PropTypes.shape({
        previews: PropTypes.object
        # original_file_url: PropTypes.string
      }).isRequired
    }).isRequired,
    mods: PropTypes.any
    },

  render: ()->
    {get, mediaProps, withLink, withZoomLink} = @props
    {image_url, title, media_type, type} = get
    {previews} = get.media_file

    classes = cx(this.props.mods)

    # get the largest image and use it as 'full size link'
    # NOTE: we want this link even if the file is the same,
    # for consistency and bc it's easier for users…
    imageHref = f.chain(previews.images).sortBy('width').last().get('url').run()

    # just the picure element (might be wrapped)
    # prefer the given image_url, but fallback to largest
    picture = if image_url || imageHref
      <Picture title={title} src={image_url || imageHref} {...mediaProps} />
    else
      <ResourceIcon mediaType={media_type} thumbnail={false} type={type} />

    originalUrl = ''
    if @props.get.media_file && @props.get.media_file.original_file_url
      originalUrl = @props.get.media_file.original_file_url

    mediaPlayerConfig = f.merge({
      poster: imageHref || image_url,
      originalUrl: originalUrl
    }, mediaProps)

    get = @props.get
    not_ready = (get.media_type == 'video' || get.media_type == 'audio') && get.media_file &&
      get.media_file.conversion_status && get.media_file.conversion_status != 'finished'

    if not_ready
      warningText =
        if get.media_file.conversion_status is 'submitted'
          [t('media_entry_conversion_progress_pre'),
           get.media_file.conversion_progress,
           t('media_entry_conversion_progress_post')].join('')
        else
          t('media_entry_conversion_status_' + get.media_file.conversion_status)

      <div className={classes}>
        <div className="ui-alert warning">{warningText}</div>
        <div className="p pvh mth">
          {t('media_entry_conversion_hint')}
          <br />
          <span className="title-xs">
            {t('media_entry_conversion_reload')}
          </span>
        </div>
      </div>
    else

      <div className={classes}>
        {
          switch

            # PDF
            when @props.get.media_type == 'document'
              <div className='ui-has-magnifier'>
                <a href={originalUrl}>
                  {picture}
                </a>
                <a href={originalUrl} className='ui-magnifier'>
                  <Icon i='magnifier' mods='bright'/>
                </a>
              </div>

            # video player
            when previews.videos
              <MediaPlayer type='video'
                {...mediaPlayerConfig}
                sources={previews.videos}
                options={f.merge({fluid: true}, f.get(mediaPlayerConfig, 'options'))}
              />

            # audio player
            when previews.audios
              <div
                className='ui-container mvm'
                style={{width: '100%', padding: '1em', display: 'inline-block', boxSizing: 'border-box'}}
              >
                <MediaPlayer type='audio'
                  {...mediaPlayerConfig}
                  sources={previews.audios}
                />
              </div>

            # picture with link and 'zoom' icon on hover
            when imageHref && (withLink || withZoomLink)
              <div className={cx({'ui-has-magnifier': withZoomLink})}>
                <a href={imageHref}>
                  {picture}
                </a>
                {if withZoomLink
                  <a href={imageHref} target='_blank' className='ui-magnifier' style={{textDecoration: 'none'}}>
                    <Icon i='magnifier' mods='bright'/>
                  </a>}
              </div>

            else
              picture
        }
      </div>
})
