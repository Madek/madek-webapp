import React from 'react'
import t from '../../../lib/i18n-translate.js'
import VocabularyPage from './VocabularyPage.jsx'
import MediaResourcesBox from '../../decorators/MediaResourcesBox.jsx'

const VocabularyContents = ({ get, authToken, for_url }) => {
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

export default VocabularyContents
module.exports = VocabularyContents
