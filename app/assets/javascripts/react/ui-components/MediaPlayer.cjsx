React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')

module.exports = React.createClass
  displayName: 'MediaPlayer'
  propTypes:
    type: React.PropTypes.oneOf(['audio', 'video']).isRequired
    sources: React.PropTypes.arrayOf(
      React.PropTypes.shape({
        url: React.PropTypes.string.isRequired,
        content_type: React.PropTypes.string.isRequired
      }).isRequired).isRequired
    poster: React.PropTypes.string

  getInitialState: () -> {
    showHint: false
  }

  _ref: (ref) ->
    maybes = f.filter @props.sources, (source) ->
      ref.canPlayType(source.content_type) != ''

    if f.isEmpty(maybes)
      @setState({showHint: true})

  render: ({type, sources, poster} = @props)->
    MediaTag = type
    <div style={{margin: '0px', padding: '0px'}}>
      <MediaTag controls poster={poster} ref={@_ref}>
        {f.map sources, (vid)->
          <source src={vid.url} type={vid.content_type} key={vid.content_type + vid.url}/>}
      </MediaTag>
      {
        if @state.showHint
          <p style={{marginTop: '40px'}}>
            {t('media_entry_file_format_not_supported_1')}
            <a href={@props.originalUrl}>{t('media_entry_file_format_not_supported_2')}</a>
            {t('media_entry_file_format_not_supported_3')}
          </p>
      }
    </div>
