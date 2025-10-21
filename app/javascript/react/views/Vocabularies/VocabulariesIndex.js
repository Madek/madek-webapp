import React from 'react'

import PageHeader from '../../ui-components/PageHeader'
import PageContent from '../PageContent.jsx'
import VocabTitleLink from '../../ui-components/VocabTitleLink.jsx'

const COLS = 3

const VocabulariesIndex = ({ get }) => {
  const { title, resources } = get
  const vocabularies = resources.map(({ vocabulary, meta_keys }) => ({
    ...vocabulary,
    meta_keys
  }))

  // Create chunks of COLS vocabularies per row
  const vocabularyRows = []
  for (let i = 0; i < vocabularies.length; i += COLS) {
    vocabularyRows.push(vocabularies.slice(i, i + COLS))
  }

  return (
    <PageContent>
      <PageHeader title={title} icon="tags" />
      <div className="ui-container pal bright bordered rounded-bottom rounded-right">
        {vocabularyRows.map((row, i) => (
          <div className="row" key={i}>
            {row.map(({ label, description, meta_keys, url }) => (
              <div className={`col1of${COLS}`} key={url}>
                <div className="prm mbl">
                  <VocabTitleLink
                    hi="h2"
                    text={label}
                    href={url}
                    className="title-l separated light mbm"
                  />

                  {!!description && <p>{description}</p>}

                  <div className="mts">
                    <ul>
                      {meta_keys.map(({ uuid, label, url }) => (
                        <li key={uuid}>
                          <a href={url}>{label || uuid.split(':').pop()}</a>
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ))}
      </div>
    </PageContent>
  )
}

export default VocabulariesIndex
module.exports = VocabulariesIndex
