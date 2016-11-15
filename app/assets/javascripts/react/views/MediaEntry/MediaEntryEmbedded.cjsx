React = require('react')
f = require('active-lodash')
cx = require('classnames')
t = require('../../../lib/string-translation')('de')

MediaPlayer = require('../../ui-components/MediaPlayer.cjsx')

module.exports = React.createClass
  displayName: 'Views.MediaEntryEmbedded'
  propTypes:
    get: React.PropTypes.shape(
      media_file: React.PropTypes.object.isRequired # TODO
    ).isRequired


  render: ({get} = @props)->
    # NOTE: only videos supported!
    {image_url, title, media_type, type, media_file, embed_config} = get
    if (!media_type == 'video') then throw new Error('only videos supported!')
    {previews, original_file_url} = media_file

    # TMP: until the size handling is bullet proof, be extra carefull
    offsetWidth = 0 # 20 # be this many pixel less wide than requested

    style = {
      maxWidth: embed_config.maxwidth && (embed_config.maxwidth - offsetWidth) + 'px',
      maxHeight: embed_config.maxheight && embed_config.maxheight + 'px'
    }

    # TODO: choose appropriate sizes (instad of largest)
    poster = f.chain(previews.images).sortBy('heigth').last().get('url').run()

    <div style={style}>
      <MediaPlayer type='video'
        sources={previews.videos}
        poster={poster}
        originalUrl={original_file_url}
      />
  </div>

# render component: 'TodoList', props: { todos: @todos }, tag: 'span', class: 'todo'
