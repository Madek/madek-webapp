React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')

VideoJS = require('./VideoJs').default

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

  getInitialState: () -> { active: false, showHint: false }
  componentDidMount: ()->
    @setState(active: true)

  _ref: (ref) ->
    return unless ref
    maybes = f.filter @props.sources, (source) ->
      ref.canPlayType(source.content_type) != ''

    if f.isEmpty(maybes)
      @setState({showHint: true})

  render: ({type, sources, poster} = @props)->
    # TMP: audios (will just re-use <VideoJS> which could handle audio via `videojs`)
    if type == 'audio'
      <div style={{margin: '0px', padding: '0px'}}>
        <audio
          controls
          preload='auto'
          style={{width: '100%'}}
          ref={@_ref}
        >
          {f.map sources, (vid)->
            <source src={vid.url} type={vid.content_type} key={vid.content_type + vid.url}/>}
        </audio>
        {
          if @state.showHint
            <p style={{marginTop: '40px'}}>
              {t('media_entry_file_format_not_supported_1')}
              <a href={@props.originalUrl}>{t('media_entry_file_format_not_supported_2')}</a>
              {t('media_entry_file_format_not_supported_3')}
            </p>
        }
      </div>

    else
      # use videojs for client-side videos
      # before the player is loaded, show the poster to minimize flicker
      # if js fails, user still get the HTML5 video tag
      videoProps = f.omit(@props, 'originalUrl')
      if !@state.active
        <div>
          <div className='no-js'>
            <VideoJS {...videoProps} />
          </div>
          <div className='js-only'>
            <img src={poster} style={{height: '100%', width: '100%'}}/>
          </div>
        </div>
      else
        <VideoJS {...videoProps} />
