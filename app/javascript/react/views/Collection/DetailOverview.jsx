/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import MetaDataList from '../../decorators/MetaDataList.jsx'
import ResourceShowOverview from '../../templates/ResourceShowOverview.jsx'
import SimpleResourceThumbnail from '../../decorators/SimpleResourceThumbnail.jsx'

module.exports = createReactClass({
  displayName: 'CollectionDetailOverview',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
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
