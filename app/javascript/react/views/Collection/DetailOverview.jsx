/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const MetaDataList = require('../../decorators/MetaDataList.jsx')
const ResourceShowOverview = require('../../templates/ResourceShowOverview.jsx')
const SimpleResourceThumbnail = require('../../decorators/SimpleResourceThumbnail.jsx')

module.exports = React.createClass({
  displayName: 'CollectionDetailOverview',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    const summary_context = (() => {
      switch (get.action) {
        case 'show':
          return get.summary_meta_data
        case 'context':
          return get.context_meta_data
      }
    })()

    const overview = {
      content: (
        <MetaDataList list={summary_context} type="table" showTitle={false} showFallback={true} />
      ),
      preview: (
        <div className="ui-set-preview">
          <SimpleResourceThumbnail
            type={get.type}
            title={get.title}
            authors_pretty={get.authors_pretty}
            image_url={get.image_url}
          />
        </div>
      )
    }

    return (
      <div className="bright  pal rounded-top-right ui-container">
        <ResourceShowOverview {...Object.assign({}, overview)} />
      </div>
    )
  }
})
