# Display multiple Rows of MetaData Lists (by Context or by Vocabulary)
React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation')('de')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
MetaDataList = require('./MetaDataList.cjsx')

module.exports = React.createClass
  displayName: 'Deco.MetaDataByListing'
  propTypes:
    list: MadekPropTypes.metaDataListing.isRequired
    vocabLinks: React.PropTypes.bool

  render: ({list, vocabLinks} = @props)->
    # build the boxes with meta_data lists, 4 per row, skip empty
    colums = f.chunk(list, 4)

    <div className='meta-data-summary mbl'>

      {colums.map (row)->
        [(
          <div className='ui-container media-entry-metadata' key={f(row).map('context.uuid').join()}>
            {row.map((data)->
              key = (data.context or data.vocabulary).uuid
              <div className='col1of4' key={key}>
                <MetaDataList mods='prm' list={data} vocabUuid={(key if data.vocabulary)}/>
              </div>)}
          </div>),
        (if row isnt f.last(colums)
          <hr key='sep' className='separator mini mvl'/>)]
      }

    </div>
