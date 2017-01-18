import React from 'react'
import chunk from 'lodash/chunk'
import sortBy from 'lodash/sortBy'

import PageHeader from '../../ui-components/PageHeader'
import PageContent from '../PageContent.cjsx'

import VocabTitleLink from '../../ui-components/VocabTitleLink.cjsx'

const COLS = 3

module.exports = React.createClass({
  displayName: 'VocabulariesIndex',

  render () {
    const {title, resources} = this.props.get
    const vocabularies = sortBy(resources, (v) => v.uuid === 'madek_core' ? -1 : v.position)
    const vocabularyRows = chunk(vocabularies, COLS)
    return <PageContent>

      <PageHeader title={title} icon='tags' />

      <div className='bright ui-container pal bordered rounded-bottom rounded-right'>
        {vocabularyRows.map((row, i) =>
          <div className='row' key={i}>

            {row.map(({label, description, usable, url}) =>
              <div className={`col1of${COLS}`} key={url}>
                <div className='prm mbl'>
                  <VocabTitleLink hi='h2' text={label} href={url}
                    className='title-l separated light mbm' />
                  <p>{description || '(Keine Beschreibung)'}</p>
                </div>
              </div>
            )}

          </div>
        )}
      </div>
    </PageContent>
  }
})
