React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')

classnames = require('classnames')

module.exports = React.createClass
  displayName: 'CollectionDetailOverview'

  render: ({authToken, get} = @props) ->
    <div className="bright pal rounded-top-right ui-container">
      <div className="ui-resource-overview ui-set-overview">
        <Preview title={get.title} alt='(Unbekannt)' src={get.image_url} />
        <Metadata get={get} />
      </div>
    </div>

Keyword = React.createClass
  displayName: 'Keyword'
  render: ({label, href, iconTag} = @props) ->
    <li className="ui-tag-cloud-item">
      <a className="ui-tag-button small ellipsed tag-button-person" href={href}>
        <i className={classnames("ui-tag-icon", iconTag)}></i>
        {label}
      </a>
    </li>


Preview = React.createClass
  displayName: 'Preview'
  render: ({title, alt, src} = @props) ->
    <div className="ui-set-preview">
      <div className="media-set ui-thumbnail">
        <span className="ui-thumbnail-image-wrapper" title={title}>
          <div className="ui-thumbnail-image-holder">
            <div className="ui-thumbnail-table-image-holder">
              <div className="ui-thumbnail-cell-image-holder">
                <div className="ui-thumbnail-inner-image-holder">
                  <img alt={alt} className="ui-thumbnail-image" src={src}></img>
                </div>
              </div>
            </div>
          </div>
        </span>
      </div>
    </div>

Metadata = React.createClass
  displayName: 'Metadata'
  render: ({get} = @props) ->
    <div className="ui-metadata-box">
      <table className="borderless">
        <tbody>
          <tr>
            <td className="ui-summary-label">{t('resource_meta_data_title')}</td>
            <td className="title-l ui-summary-content">{get.title}</td>
          </tr>
          <tr>
            <td className="ui-summary-label">{t('resource_meta_data_description')}</td>
            <td className="ui-summary-content">{get.description}</td>
          </tr>
          <tr>
            <td className="ui-summary-label">{t('resource_meta_data_keywords')}</td>
            <td className="ui-summary-content">
              <ul className="ellipsed small tag-cloud-label ui-tag-cloud">
                {
                  entries = f.filter(get.meta_data.by_vocabulary['madek_core'].meta_data, (entry) ->
                    entry.meta_key_id == 'madek_core:keywords'
                  )
                  first = f.first(entries)
                  if not first
                    null
                  else
                    f.map first.values, (value, index) ->
                      <Keyword key={'key_' + index} label={value.label} href={value.url} iconTag={'icon-tag-mini'} />
                }
              </ul>
            </td>
          </tr>
          <tr>
            <td className="ui-summary-label">{t('resource_meta_data_responsible')}</td>
            <td className="ui-summary-content">
              <ul className="ellipsed small tag-cloud-label tag-cloud-person ui-tag-cloud">
                <Keyword label={get.responsible.label} href={get.responsible.url} iconTag={'icon-user-mini'} />
              </ul>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
