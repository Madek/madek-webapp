React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
RailsForm = require('../lib/forms/rails-form.cjsx')
MediaResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
RightsManagement = require('../rights-management.cjsx')

classnames = require('classnames')

module.exports = React.createClass
  displayName: 'CollectionMetadata'

  render: ({authToken, get} = @props) ->
    <div className="bright pal rounded-bottom rounded-top-right ui-container">
      <div className="col2of3">
        <div className="ui-container plm">
          <div className="meta-data-summary mbl">
            <div className="ui-container media-entry-metadata">
              <div className="col1of4">
                {f.map get.meta_data.by_vocabulary, (wrapper, key) ->
                  <div key={key} className="prm ui-metadata-box">
                    <h3 className="separated mbm title-l">{wrapper.vocabulary.label}</h3>
                    {f.map wrapper.meta_data, (meta_datum) ->
                      <MetaDatum key={meta_datum.meta_key_id} metaDatum={meta_datum} />
                    }
                  </div>
                }
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

Text = React.createClass
  displayName: 'Text'
  render: ({metaDatum} = @props) ->
    <ul className="inline">
      {
        f.map metaDatum.values, (value, index) ->
          <li key={'value_' + index}>{value}</li>
      }
    </ul>

Bubbles = React.createClass
  displayName: 'Bubbles'
  render: ({metaDatum} = @props) ->
    <ul className="ellipsed small tag-cloud-label ui-tag-cloud">
      {
        f.map metaDatum.values, (value, index) ->
          <li key={'value_' + index} className="ui-tag-cloud-item">
            <a className="ui-tag-button small ellipsed" href={value.url}>
              <i className="ui-tag-icon icon-tag-mini"></i>
              {value.label}
            </a>
          </li>
      }
    </ul>


MetaDatum = React.createClass
  displayName: 'MetaDatum'
  render: ({metaDatum} = @props) ->
    <div className="tmp">
      <dl className="media-data mbs">
        <dl className="media-data mbs" data-reactid=".0">
          <dt className="media-data-title">
            <span>{metaDatum.meta_key.label}</span>
          </dt>
          <dd className="media-data-content" data-reactid=".0.1">
            {
              isBubble = metaDatum.type in [ 'MetaDatum::Keywords', 'MetaDatum::People' ]
              console.log('is bubble for ' + metaDatum.type + ' = ' + isBubble)
              if isBubble
                <Bubbles metaDatum={metaDatum} />
              else
                <Text metaDatum={metaDatum} />
            }
          </dd>
        </dl>
      </dl>
    </div>
