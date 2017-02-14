# Display multiple Rows of MetaData Lists (by Context or by Vocabulary)
React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation')('de')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
MetaDataList = require('./MetaDataList.cjsx')
listingHelper = require('../../lib/metadata-listing-helper.coffee')


module.exports = React.createClass
  displayName: 'Deco.MetaDataByListing'
  propTypes:
    list: MadekPropTypes.metaDataListing.isRequired
    vocabLinks: React.PropTypes.bool


  render: ({list, vocabLinks, hideSeparator} = @props)->

    onlyListsWithContent = f.filter(
      list,
      (contextOrVocab) ->
        not listingHelper._isEmptyContextOrVocab(contextOrVocab)
    )

    # build the boxes with meta_data lists, 4 per row, skip empty
    colums = f.chunk(onlyListsWithContent, 4)

    <div className='meta-data-summary mbl'>

      {colums.map (row)->
        [(
          <div className='ui-container media-entry-metadata' key={f(row).map('context.uuid').join()}>
            {row.map((data)->
              key = (data.context or data.vocabulary).uuid
              <div className='col1of4' key={key}>
                <MetaDataList mods='prl' list={data} vocabUuid={(key if data.vocabulary)}/>
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
