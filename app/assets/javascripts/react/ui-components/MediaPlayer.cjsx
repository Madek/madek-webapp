React = require('react')
f = require('active-lodash')

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

  render: ({type, sources, poster} = @props)->
    MediaTag = type
    <MediaTag controls preload='auto' poster={poster}>
      {f.map sources, (vid)->
        <source src={vid.url} type={vid.content_type} key={vid.content_type + vid.url}/>}
    </MediaTag>
