/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import t from '../../../lib/i18n-translate.js'
import VocabularyPage from './VocabularyPage.jsx'
import MediaResourcesBox from '../../decorators/MediaResourcesBox.jsx'
import libUrl from 'url'

module.exports = createReactClass({
  displayName: 'VocabularyContents',

  forUrl() {
    return libUrl.format(this.props.get.resources.config.for_url)
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get, authToken, for_url } = param
    return (
      <VocabularyPage page={get.page} for_url={for_url}>
        <div className="ui-container pal">
          <h2 className="title-m">
            {t('vocabularies_contents_hint_1')}
            {`"${get.vocabulary.label}"`}
            {t('vocabularies_contents_hint_2')}
          </h2>
        </div>
        <MediaResourcesBox
          for_url={for_url}
          get={get.resources}
          authToken={authToken}
          mods={[{ bordered: false }, 'rounded-bottom']}
          resourceTypeSwitcherConfig={{ showAll: false }}
          enableOrdering={true}
          enableOrderByTitle={true}
        />
      </VocabularyPage>
    )
  }
})
