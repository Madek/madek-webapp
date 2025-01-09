/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')

const AudioPlayer = require('./AudioPlayer').default
const VideoPlayer = require('./VideoPlayer').default

module.exports = React.createClass({
  displayName: 'MediaPlayer',
  propTypes: {
    type: React.PropTypes.oneOf(['audio', 'video']).isRequired,
    sources: React.PropTypes.arrayOf(
      React.PropTypes.shape({
        url: React.PropTypes.string.isRequired,
        content_type: React.PropTypes.string.isRequired
      }).isRequired
    ).isRequired,
    poster: React.PropTypes.string
  },

  getInitialState() {
    return { active: false, showHint: false }
  },
  componentDidMount() {
    return this.setState({ active: true })
  },

  _ref(ref) {
    if (!ref) {
      return
    }
    const maybes = f.filter(
      this.props.sources,
      source => ref.canPlayType(source.content_type) !== ''
    )

    if (f.isEmpty(maybes)) {
      return this.setState({ showHint: true })
    }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { type, sources, poster } = param
    const MediaTag = type
    const mediaProps = f.omit(this.props, 'originalUrl')

    if (type === 'audio') {
      return (
        <div style={{ margin: '0px', padding: '0px' }}>
          <AudioPlayer {...Object.assign({}, mediaProps)} />
          {(() => {
            if (this.state.showHint) {
              const downloadRef = this.props.getUrl + '/export'
              return (
                <p style={{ marginTop: '40px' }}>
                  {t('media_entry_file_format_not_supported_1')}
                  <a href={downloadRef}>{t('media_entry_file_format_not_supported_2')}</a>
                  {t('media_entry_file_format_not_supported_3')}
                </p>
              )
            }
          })()}
        </div>
      )
    } else {
      // use videojs for client-side videos
      // before the player is loaded, show the poster to minimize flicker
      // if js fails, user still get the HTML5 video tag
      if (!this.state.active) {
        return (
          <div>
            <div className="no-js">
              <VideoPlayer {...Object.assign({}, mediaProps)} />
            </div>
            <div className="js-only">
              <img src={poster} style={{ height: '100%', width: '100%' }} />
            </div>
          </div>
        )
      } else {
        return <VideoPlayer {...Object.assign({}, mediaProps)} />
      }
    }
  }
})
