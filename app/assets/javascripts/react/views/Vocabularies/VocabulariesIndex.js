import React from 'react'
import chunk from 'lodash/chunk'
import sortBy from 'lodash/sortBy'

import PageHeader from '../../ui-components/PageHeader'

import PageContent from '../PageContent.cjsx'

const ROWS = 3

module.exports = React.createClass({
  displayName: 'VocabulariesIndex',

  render () {
    const {title, resources} = this.props.get
    const vocabularies = sortBy(resources, (v) => v.uuid === 'madek_core' ? -1 : v.position)

    return <PageContent>

      <PageHeader title={title} icon='tags' />

      <div className='bright ui-container pal bordered rounded-bottom rounded-right'>
        {chunk(vocabularies, ROWS).map((row, i) =>
          <div className='row' key={i}>

            {row.map(({label, description, usable, url}) =>
              <div className={`col1of${ROWS}`} key={url}>
                <div className='prm mbl'>
                  <h2 className='title-l link separated light mbm'>
                    <a href={url}>{label}</a>
                  </h2>
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
