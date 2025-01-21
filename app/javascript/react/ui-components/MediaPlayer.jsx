/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import t from '../../lib/i18n-translate.js'
import AudioPlayer from './AudioPlayer'
import VideoPlayer from './VideoPlayer'

module.exports = createReactClass({
  displayName: 'MediaPlayer',
  propTypes: {
    type: PropTypes.oneOf(['audio', 'video']).isRequired,
    sources: PropTypes.arrayOf(
      PropTypes.shape({
        url: PropTypes.string.isRequired,
        content_type: PropTypes.string.isRequired
      }).isRequired
    ).isRequired,
    poster: PropTypes.string
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
    const { type, poster } = param
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
