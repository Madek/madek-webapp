import React, { PropTypes } from 'react'
import chunk from 'lodash/chunk'
import sortBy from 'lodash/sortBy'
import isEmpty from 'lodash/isEmpty'

import MadekPropTypes from '../../lib/madek-prop-types.coffee'
import Icon from '../../ui-components/Icon.cjsx'

import VocabularyPage from './VocabularyPage.cjsx'

import VocabTitleLink from '../../ui-components/VocabTitleLink.cjsx'

const MIN_COLS = 2 // for MetaKeys list
const MAX_COLS = 3

const shortID = id => !!id && id.split(':')[1]

const metaKeyInfo = mk => [
  ['ID', mk.uuid.replace(':', ':\u200b')], // insert optional linebreak after ':'
  [
    'type',
    mk.value_type.split('::')[1] +
      (mk.value_type !== 'MetaDatum::People'
        ? ''
        : ` (${mk.allowed_people_subtypes.join(', ')})`)
  ],
  ['description', mk.description],
  ['hint', mk.hint],
  ['scope', mk.scope.join(', ')],
  [
    'keywords',
    mk.value_type !== 'MetaDatum::Keywords' ? '' : mk.keywords_count
  ],
  [
    'mappings',
    isEmpty(mk.mappings)
      ? null
      : <ul className='inline'>
          {mk.mappings.map(m =>
            <li key={m.uuid}>
              {m.key_map}
            </li>
          )}
        </ul>
  ]
]

const VocabulariesShow = React.createClass({
  displayName: 'VocabularyShow',

  render (get = this.props.get) {
    const { meta_keys } = get
    const {
      label,
      url,
      description,
      enabled_for_public_view
    } = get.page.vocabulary

    const metaKeys = sortBy(meta_keys, 'position')
    const numCols = Math.max(MIN_COLS, Math.min(MAX_COLS, metaKeys.length))
    const metaKeyCols = chunk(metaKeys, numCols)

    return (
      <VocabularyPage page={get.page} for_url={this.props.for_url}>
        <div className='ui-container pal'>
          <div className='mbl'>
            <VocabTitleLink text={label} href={url} />

            <p className='mtm'>
              {description || '(Keine Beschreibung)'}
            </p>

            <h3
              className='title-m separated light mtl mbm'
              style={{ fontWeight: 'bold' }}
            >
              MetaKeys
            </h3>
            {metaKeyCols.map((col, i) =>
              <div className='row' key={i}>
                {col.map(mk =>
                  <div className={`col1of${numCols}`} key={mk.uuid}>
                    <div className='prl mbl'>
                      <h4
                        className='title-m separated light'
                        id={shortID(mk.uuid)}
                      >
                        <a href={'#' + shortID(mk.uuid)}>
                          {mk.label}
                        </a>
                      </h4>

                      <table className='borderless'>
                        <tbody>
                          {metaKeyInfo(mk).map(
                            ([label, value]) =>
                              isEmpty(value)
                                ? null
                                : <tr key={label + value}>
                                    <td className='ui-summary-label'>
                                      {label}
                                    </td>
                                    <td className='ui-summary-content'>
                                      {value}
                                    </td>
                                  </tr>
                          )}
                        </tbody>
                      </table>
                      <br />
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </VocabularyPage>
    )
  }
})

VocabulariesShow.propTypes = {
  get: PropTypes.shape({
    page: PropTypes.shape({
      vocabulary: PropTypes.shape({
        label: PropTypes.string.isRequired,
        description: PropTypes.string,
        enabled_for_public_view: PropTypes.bool.isRequired,
        usable: PropTypes.bool.isRequired
      }).isRequired,
      actions: PropTypes.shape({
        index: PropTypes.string.isRequired
      }).isRequired
    }),
    meta_keys: PropTypes.arrayOf(MadekPropTypes.VocabularyMetaKey).isRequired
  }).isRequired
}

module.exports = VocabulariesShow
