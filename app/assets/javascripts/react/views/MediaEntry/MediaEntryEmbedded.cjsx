React = require('react')
f = require('active-lodash')
cx = require('classnames')
t = require('../../../lib/string-translation')('de')

MediaPlayer = require('../../ui-components/MediaPlayer.cjsx')

CAPTION_HEIGHT = 55 # absolute heigth of tile caption in pixels

module.exports = React.createClass
  displayName: 'Views.MediaEntryEmbedded'
  propTypes:
    get: React.PropTypes.shape(
      media_file: React.PropTypes.object.isRequired # TODO
    ).isRequired


  render: ({get} = @props)->
    # NOTE: only videos supported!
    {image_url, caption_text, media_type, type, media_file, embed_config} = get
    if (!media_type == 'video') then throw new Error('only videos supported!')
    {previews, original_file_url} = media_file

    maxWidth = embed_config.maxwidth
    maxHeight = embed_config.maxheight

    style = {
      maxWidth: maxWidth > 0 && maxWidth + 'px',
      maxHeight: maxHeight > 0 && maxHeight + 'px'
      overflow: 'hidden'
    }

    # TODO: choose appropriate sizes (instad of largest)
    poster = f.chain(previews.images).sortBy('heigth').last().get('url').run()

    # TODO: `fluid: false` only when height AND size are requested!
    mediaPlayer = <MediaPlayer type='video'
            uuid={get.uuid}
            title={get.title}
            author={get.authors_pretty}
            sources={previews.videos}
            poster={poster}
            originalUrl={original_file_url}
            options={{
              fluid: false
              height: (maxHeight - CAPTION_HEIGHT)
            }}
          />

    <div style={style}>
      <div className="ui-tile" style={{display: 'block'}}>
        <div className="ui-tile__body">
          {
            mediaPlayer
          }
        </div>
        <a
          className="ui-tile__foot"
          href={'/media_resources/' + get.uuid}
          target='_blank'
        >
          <h3 className="ui-tile__title">
            {caption_text[0]}
          </h3>
          <h4 className="ui-tile__meta">
            <span>
              {caption_text[1]}
            </span>
          </h4>
          <span className="ui-tile__flags">
            <i className="icon-link ui-tile__flag ui-tile__flag--type"></i>
          </span>
        </a>
      </div>
  </div>

# render component: 'TodoList', props: { todos: @todos }, tag: 'span', class: 'todo'
