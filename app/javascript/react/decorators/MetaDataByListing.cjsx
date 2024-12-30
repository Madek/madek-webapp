# Display multiple Rows of MetaData Lists (by Context or by Vocabulary)
React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
MetaDataList = require('./MetaDataList.cjsx')
listingHelper = require('../../lib/metadata-listing-helper.coffee')


module.exports = React.createClass
  displayName: 'Deco.MetaDataByListing'
  propTypes:
    list: MadekPropTypes.metaDataListing.isRequired
    vocabLinks: React.PropTypes.bool


  render: ({list, vocabLinks, hideSeparator} = @props)->

    # Wenn es  Werte in 1 oder 2 Kontexten gibt, dann ist die Darstellung 2-spaltig.(Bei nur 1 Kontext bleibt die zweite Spalte leer.)
    # Wenn es Werte in 3 Kontexten gibt, ist die Darstellung 3-spaltig.
    # Wenn es Werte in 4 und mehr Kontexten gibt, ist die Darstellung 4-spaltig. (Der 5+n. Kontexte rutscht in die zweite Zeile.)

    onlyListsWithContent = f.reject(list, (i)-> listingHelper._isEmptyContextOrVocab(i))
    numVocabs = onlyListsWithContent.length
    numColumns = f.max([2, f.min([4, numVocabs])])
    colums = f.chunk(onlyListsWithContent, numColumns)

    <div className='meta-data-summary mbl'>

      {colums.map (row)->
        [(
          <div className='ui-container media-entry-metadata' key={f(row).map('context.uuid').join()}>
            {row.map((data)->
              key = (data.context or data.vocabulary).uuid
              vocabUrl = f.get(data, 'vocabulary.url', '')
              <div className={"col1of#{numColumns}"} key={key}>
                <MetaDataList mods='prl' list={data} vocabUrl={vocabUrl}/>
              </div>)}
          </div>),
          (
            if (row isnt f.last(colums))
              if (not hideSeparator)
                <hr key='sep' className='separator mini mvl'/>
              else
                <div className='mvl' />
          )
        ]
      }

    </div>
