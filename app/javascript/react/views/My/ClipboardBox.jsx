/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ui = require('../../lib/ui.js')
const { t } = ui
const libUrl = require('url')

const MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')

module.exports = React.createClass({
  displayName: 'ClipboardBox',

  forUrl() {
    if (this.props.get.clipboard_id) {
      return libUrl.format(this.props.get.resources.config.for_url)
    }
  },

  render() {
    if (!this.props.get.clipboard_id) {
      return (
        <div className="pvh mth mbl">
          <div className="by-center">
            <p className="title-l mbm">{t('clipboard_empty_message')}</p>
          </div>
        </div>
      )
    }

    return (
      <MediaResourcesBox
        {...Object.assign({}, this.props, {
          get: this.props.get.resources,
          resourceTypeSwitcherConfig: { showAll: true },
          collectionData: { uuid: this.props.get.clipboard_id }
        })}
      />
    )
  }
})
