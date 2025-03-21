import React from 'react'
import createReactClass from 'create-react-class'
import chunk from 'lodash/chunk'
import last from 'lodash/last'

import PageHeader from '../../ui-components/PageHeader'
import PageContent from '../PageContent.jsx'

import VocabTitleLink from '../../ui-components/VocabTitleLink.jsx'

const COLS = 3

module.exports = createReactClass({
  displayName: 'VocabulariesIndex',
  render() {
    const { title, resources } = this.props.get
    const vocabularies = resources.map(({ vocabulary, meta_keys }) => ({
      ...vocabulary,
      meta_keys
    }))
    const vocabularyRows = chunk(vocabularies, COLS)

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
                            <a href={url}>{label || last(uuid.split(':'))}</a>
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
})
