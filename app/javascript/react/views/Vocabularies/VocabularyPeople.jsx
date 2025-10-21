import React from 'react'
import t from '../../../lib/i18n-translate.js'
import { chunk } from '../../../lib/utils.js'
import VocabularyPage from './VocabularyPage.jsx'

const MIN_COLS = 2 // for layout
const MAX_COLS = 4

const MetakeyItem = ({ meta_key, keywords }) => {
  const sortLabel = t('meta_key_order_alphabetical')
  const sortTitle = t('meta_key_order_alphabetical_hint')

  return (
    <div className="ui-metadata-box prl mbm">
      <h3 className="title-s-alt separated light mbx">
        {meta_key.label}
        <small title={sortTitle} className="title-xs-alt mlx">
          ({sortLabel})
        </small>
      </h3>
      {keywords.length > 0 ? (
        <ul className="ui-tag-cloud small ellipsed compact">
          {keywords.map(kw => (
            <KeywordItem key={kw.uuid} {...kw} />
          ))}
        </ul>
      ) : (
        <div>{t('vocabularies_no_people')}</div>
      )}
    </div>
  )
}

const KeywordItem = ({ label, url }) => (
  <li className="ui-tag-cloud-item">
    <a className="ui-tag-button" title={label} href={url}>
      {label}
    </a>
  </li>
)

const VocabularyPeople = ({ get, for_url }) => {
  const metaKeys = get.meta_keys_with_people
  const numCols = Math.max(MIN_COLS, Math.min(MAX_COLS, metaKeys.length))
  const metaKeyColumns = chunk(metaKeys, numCols)
  const hint =
    t('vocabularies_people_hint_1') +
    '"' +
    get.page.vocabulary.label +
    '"' +
    t('vocabularies_people_hint_2')

  return (
    <VocabularyPage page={get.page} for_url={for_url}>
      <div className="ui-container pal">
        <h2 className="title-m mbl">{hint}</h2>
        <div className="mbl">
          {metaKeyColumns.map((metaKeys, i) => (
            <div className={`col1of${numCols}`} key={i}>
              {metaKeys.map(mk => (
                <MetakeyItem key={mk.meta_key.uuid} {...mk} />
              ))}
            </div>
          ))}
        </div>
      </div>
    </VocabularyPage>
  )
}

export default VocabularyPeople
module.exports = VocabularyPeople
