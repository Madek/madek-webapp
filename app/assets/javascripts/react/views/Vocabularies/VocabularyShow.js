import React, {PropTypes} from 'react'
import chunk from 'lodash/chunk'
import sortBy from 'lodash/sortBy'
import isEmpty from 'lodash/isEmpty'

import MadekPropTypes from '../../lib/madek-prop-types.coffee'
import PageHeader from '../../ui-components/PageHeader'
import Icon from '../../ui-components/Icon.cjsx'

import Tabs from '../Tabs.cjsx'
import Tab from '../Tab.cjsx'
import PageContent from '../PageContent.cjsx'
import TabContent from '../TabContent.cjsx'

import VocabularyPage from './VocabularyPage.cjsx'

const ROWS = 3 // for MetaKeys

const shortID = (id) => !!id && id.split(':')[1]

const metaKeyInfo = (mk) => [
  [ 'ID', mk.uuid.replace(':', ':\u200b') ], // insert optional linebreak after ':'
  [ 'type',
    mk.value_type.split('::')[1] + (
    mk.value_type !== 'MetaDatum::People' ? ''
      : ` (${mk.allowed_people_subtypes.join(', ')})`)
  ],
  [ 'description', mk.description ],
  [ 'hint', mk.hint ],
  [ 'scope', mk.scope.join(', ')
  ],
  [ 'keywords', mk.value_type !== 'MetaDatum::Keywords' ? ''
      : mk.keywords_count
  ],
  [ 'mappings',
    isEmpty(mk.mappings) ? null
      : <ul className='inline'>{mk.mappings.map((m) => <li key={m.uuid}>{m.key_map}</li>)}</ul>
  ]
]

const VocabulariesShow = React.createClass({
  displayName: 'VocabularyShow',

  render (get = this.props.get) {
    const {meta_keys} = get
    const {label, url, description, enabled_for_public_view} = get.page.vocabulary

    const metaKeys = sortBy(meta_keys, 'position')

    return <VocabularyPage page={get.page} for_url={this.props.for_url}>

        <div className='bright ui-container pal rounded'>
          <div className='mbl'>

            <h2 className='title-l'>
              <a href={url}>{label}</a><span> </span>
              <Icon i={`privay-${enabled_for_public_view ? 'public' : 'private'}`} />
            </h2>

            <p className='mtm'>{description || '(Keine Beschreibung)'}</p>

            <h3 className='title-m separated light mtl mbm' style={{fontWeight: 'bold'}}>
              MetaKeys
            </h3>
            {chunk(metaKeys, ROWS).map((row, i) =>
              <div className='row' key={i}>
                {row.map((mk) =>
                  <div className={`col1of${ROWS}`} key={mk.uuid}>
                    <div className='prm mbl'>

                      <h4 className='title-m separated light' id={shortID(mk.uuid)} >
                        <a href={'#' + shortID(mk.uuid)}>{mk.label}</a>
                      </h4>

                      <table className='borderless'>
                        <tbody>
                          {metaKeyInfo(mk).map(([label, value]) => (
                            isEmpty(value) ? null : (
                              <tr key={label + value}>
                                <td className='ui-summary-label'>{label}</td>
                                <td className='ui-summary-content'>{value}</td>
                              </tr>)
                          ))}
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
  }
})

VocabulariesShow.propTypes = {
  get: PropTypes.shape({
    page: PropTypes.shape({
      vocabulary: PropTypes.shape({
        label: PropTypes.string.isRequired,
        description: PropTypes.string,
        enabled_for_public_view: PropTypes.bool.isRequired,
        usable: PropTypes.bool.isRequired,
      }).isRequired,
      actions: PropTypes.shape({
        index: PropTypes.string.isRequired
      }).isRequired
    }),
    meta_keys: PropTypes.arrayOf(MadekPropTypes.VocabularyMetaKey).isRequired,
  }).isRequired
}

module.exports = VocabulariesShow