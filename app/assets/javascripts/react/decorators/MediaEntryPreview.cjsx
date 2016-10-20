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

    {image_url, title, media_type, type} = @props.get
    {previews} = @props.get.media_file

    classes = cx(this.props.mods)

    # get the largest image and use it as 'full size link'
    # NOTE: we want this link even if the file is the same,
    # for consistency and bc it's easier for users…
    href = f.chain(previews.images).sortBy('width').last().get('url').run()


    # just the picure element (might be wrapped)
    picture = if image_url
      <Picture className={classes} title={title} src={image_url} />
    else
      <ResourceIcon mediaType={media_type} thumbnail={false} type={type} />

    originalUrl = ''
    if @props.get.media_file && @props.get.media_file.original_file_url
      originalUrl = @props.get.media_file.original_file_url


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

      <div className='ui-media-overview-preview'>
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

      <div className='ui-media-overview-preview'>
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
              <MediaPlayer type='video' className={classes}
                sources={previews.videos} poster={image_url}
                originalUrl={originalUrl} />

            # audio player
            when previews.audios
              <div className='ui-container mvm'>
                <MediaPlayer type='audio' className={classes}
                  sources={previews.audios} poster={image_url}
                  originalUrl={originalUrl} />
              </div>

            # picture with link and 'zoom' icon on hover
            when href
              hasZoom = !(href == image_url)
              <div className={cx({'ui-has-magnifier': hasZoom})}>
                <a href={href}>
                  {picture}
                </a>
                {if hasZoom
                  <a href={href} target='_blank' className='ui-magnifier'>
                    <Icon i='magnifier' mods='bright'/>
                  </a>}
              </div>

            else
              picture
        }
      </div>
})
