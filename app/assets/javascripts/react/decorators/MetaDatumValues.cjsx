# Takes a MetaDatum and displays the values according to the type.

React = require('react')
f = require('active-lodash')
linkifyStr = require('linkifyjs/string')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
resourceName = require('../lib/decorate-resource-names.coffee')
linkifyInnerHtml = require('../lib/linkify-inner-html.coffee')
t = require('../../lib/i18n-translate.js')
UI = require('../ui-components/index.coffee')
MetaDatumRolesCloud = require('./MetaDatumRolesCloud.js').default
MetaDatumText = require('./MetaDatumText.js').default
labelize = UI.labelize

# Decorator for each type is single stateless-function-component,
# the main/exported component just selects the right one.
DecoratorsByType =
  Text: ({values, metaKeyId} = @props)->
    <MetaDatumText values={values} allowReadMore={metaKeyId == 'madek_core:description'}/>

  TextDate: ({values} = @props)->
    <ul className='inline'>
      {values.map (string)-> <li key={string}>{string}</li>}</ul>

  JSON: ({values, apiUrl} = @props)->
    <ul className='inline ui-md-json'>{
      values.map (obj, i)->
        <li className="wrapped-textarea" style={{
          display: 'block', padding: 0, overflow: 'hidden'
        }} key={i}>
          <textarea
            readOnly
            className='code block'
            rows=10
            style={{
              margin: 0, padding: 0,
              fontSize: '85%',
              borderTop: 'none',
              borderLeft: 'none',
              borderRight: 'none'}}
            defaultValue={prettifyJson(obj)}
          />
          <small style={{fontSize: '85%', display: 'block', padding: '0.5rem'}}>
            <a href={apiUrl}>
              <UI.Icon i="dload"/> {t('meta_datum_json_download_value')}
            </a>
          </small>
        </li>
    }</ul>

  People: ({values, tagMods} = @props)->
    <UI.TagCloud mod='person' mods='small' list={labelize(values)}/>

  Roles: ({values, tagMods, metaKeyId} = @props)->
    <MetaDatumRolesCloud personRoleTuples={values} metaKeyId={metaKeyId} />

  Groups: ({values, tagMods} = @props)->
    <UI.TagCloud mod='group' mods='small' list={labelize(values)}/>

  Keywords: ({values, tagMods} = @props)->
    <UI.TagCloud mod='label' mods='small' list={labelize(values)}/>

  MediaEntry: ({values} = @props) ->
    [resource, description] = f.get(values, '0')
    { url, title, unAuthorized, notFound } = resource
    <div>
      <UI.Link href={url} className='link'>{title}</UI.Link>{' '}
      {f.present(description) && <p>({description})</p>}
      {!!unAuthorized && <p style={{fontStyle: 'italic'}}>{t('meta_datum_media_entry_value_unauthorized')}</p>}
      {!!notFound && <p style={{fontStyle: 'italic'}}>{t('meta_datum_media_entry_value_not_found')}</p>}
    </div>

module.exports = React.createClass
  displayName: 'Deco.MetaDatumValues'
  propTypes:
    metaDatum: MadekPropTypes.metaDatum.isRequired
    tagMods: React.PropTypes.any # TODO: mods

  render: (props = @props)->
    {type, values, api_data_stream_url, tagMods, meta_key_id} = props.metaDatum
    DecoratorByType = DecoratorsByType[f.last(type.split('::'))]
    <DecoratorByType
      values={values}
      tagMods={tagMods}
      apiUrl={api_data_stream_url}
      metaKeyId={meta_key_id}
    />


# helpers

prettifyJson = (obj)->
  try
    JSON.stringify(obj, 0, 2)
  catch error
    console.error("MetaDatumJSON: " + error)
    String(obj)
