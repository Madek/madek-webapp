React = require('react')
f = require('active-lodash')
t = require('../lib/string-translation.js')('de')
RailsForm = require('./lib/forms/rails-form.cjsx')
MetaKeyFormLabel = require('./lib/forms/form-label.cjsx')
InputMetaDatum = require('./lib/input-meta-datum.cjsx')
MadekPropTypes = require('./lib/madek-prop-types.coffee')
xhr = require('xhr')
getRailsCSRFToken = require('../lib/rails-csrf-token.coffee')
classnames = require('classnames')

module.exports = React.createClass
  displayName: 'FormResourceMetaData'

  getInitialState: () ->
    editing: false
    errors: {}
    saving: false

  _onSubmit: (event) ->
    event.preventDefault()
    @setState(saving: true)
    serialized = @refs.form.serialize()
    xhr(
      {
        method: 'PUT'
        url: @props.get.url + '/meta_data'
        body: serialized
        headers: {
          'Accept': 'application/json'
          'Content-type': 'application/x-www-form-urlencoded'
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, body) =>
        @setState(saving: false)
        try
          data = JSON.parse(body)
        catch error
          console.error('Cannot parse body of answer for meta data update', error)

        if res.statusCode == 400
          errors = f.presence(f.get(data, 'errors')) or {}
          if not f.present(errors)
            console.error('Cannot get errors from meta data update')
          else
            window.scrollTo(0, 0)
          @setState(errors: errors)
        else
          forward_url = data['forward_url']
          if not forward_url
            console.error('Cannot get forward url of answer of meta data update')
          window.location = forward_url
    )

  render: ({get, authToken} = @props) ->
    name = "#{f.snakeCase(get.type)}[meta_data]"

    meta_data = get.meta_data.by_vocabulary

    <RailsForm ref='form' onSubmit={@_onSubmit}
      name='resource_meta_data' action={get.url + '/meta_data'}
      method='put' authToken={authToken}>


      {if @state.errors and f.keys(@state.errors).length > 0
        <div className="ui-alerts" style={marginBottom: '10px'}>
          <div className="error ui-alert">
            {t('resource_meta_data_has_validation_errors')}
          </div>
        </div>
      }


      <div className='form-body'>
        {f.keys(meta_data).map (voc_id) =>
          <VocabularyFormItem errors={@state.errors} get={meta_data[voc_id]} name={name} key={voc_id}/>
        }
      </div>

      <div className='form-footer'>
        <div className='ui-actions'>
          <a className='weak' href={get.url}>Cancel</a>
          <button className='primary-button large'
            type='submit' disabled={@state.saving}>Save</button>
        </div>
      </div>
    </RailsForm>

VocabularyFormItem = React.createClass
  displayName: 'VocabularyFormItem'
  render: ({get, name, errors} = @props)->
    <div className='mbl'>
      <VocabularyHeader vocabulary={get.vocabulary}/>
      {get.meta_data.map (datum) ->
        <MetaDatumFormItem error={errors[datum.meta_key.uuid]} get={datum} name={name} key={datum.meta_key.uuid}/>
      }
    </div>

VocabularyHeader = React.createClass
  displayName: 'VocabularyHeader'
  render: ({vocabulary} = @props)->
    <div className='ui-container separated pas'>
      <h3 className='title-l'>
        {vocabulary.label + ' '}
        <small>{"(#{vocabulary.uuid})"}</small>
      </h3>
      <p className='paragraph-s'>{vocabulary.description}</p>
    </div>

MetaDatumFormItem = React.createClass
  displayName: 'MetaDatumFormItem'
  propTypes:
    name: React.PropTypes.string.isRequired
    get: MadekPropTypes.metaDatum

  render: ({get, name, error} = @props)->
    name += "[#{get.meta_key.uuid}][]"
    <fieldset className={classnames('ui-form-group', 'columned', {'error': error})}>
      {if error
        <div className="ui-alerts" style={marginBottom: '10px'}>
          <div className="error ui-alert">
            {error}
          </div>
        </div>
      }
      <MetaKeyFormLabel name={name} metaKey={get.meta_key}/>
      <InputMetaDatum name={name} get={get}/>
    </fieldset>
