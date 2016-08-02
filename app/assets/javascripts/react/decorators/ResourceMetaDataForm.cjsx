React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
xhr = require('xhr')
cx = require('classnames')
t = require('../../lib/string-translation.js')('de')
RailsForm = require('../lib/forms/rails-form.cjsx')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
MetaKeyFormLabel = require('../lib/forms/form-label.cjsx')
InputMetaDatum = require('../lib/input-meta-datum.cjsx')
MadekPropTypes = require('../lib/madek-prop-types.coffee')

module.exports = React.createClass
  displayName: 'ResourceMetaDataForm'
  propTypes: {
    get: PropTypes.shape({
      meta_data: PropTypes.shape({
        by_vocabulary: PropTypes.arrayOf(
          PropTypes.shape({
            # TODO: MadekPropTypes resources:
            vocabulary: PropTypes.object.isRequired
            meta_data: PropTypes.array.isRequired }))})}
    ).isRequired}

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
        @setState(saving: false) if @isMounted()
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
          @setState(errors: errors) if @isMounted()
        else
          forward_url = data['forward_url']
          if not forward_url
            console.error('Cannot get forward url of answer of meta data update')
          window.location = forward_url
    )

  render: ({get, authToken} = @props, {errors} = @state) ->
    name = "#{f.snakeCase(get.type)}[meta_data]"

    meta_data = f.sortBy(get.meta_data.by_vocabulary, 'vocabulary.position')

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
        {meta_data.map (bundle) ->
          <VocabularyFormItem
            errors={errors}
            get={bundle} name={name}
            key={bundle.vocabulary.uuid}/>}
      </div>

      <div className="ui-actions phl pbl mtl">
        <a className="link weak" href={get.url}>{' ' + t('meta_data_form_cancel') + ' '}</a>
        <button className="primary-button large" type="submit"
          disabled={@state.saving}>{' ' + t('meta_data_form_save') + ' '}</button>
      </div>

    </RailsForm>

VocabularyFormItem = React.createClass
  displayName: 'VocabularyFormItem'
  render: ({get, name, errors} = @props)->
    meta_data = f.sortBy(get.meta_data, 'meta_key.position')
    <div className='mbl'>
      <VocabularyHeader vocabulary={get.vocabulary}/>
      {meta_data.map (datum) ->
        <MetaDatumFormItem
          get={datum} name={name}
          error={errors[datum.meta_key.uuid]}
          key={datum.meta_key.uuid}/>
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
    name: PropTypes.string.isRequired
    get: MadekPropTypes.metaDatum

  render: ({get, name, error} = @props)->
    name += "[#{get.meta_key.uuid}][]"
    <fieldset className={cx('ui-form-group columned prh', {'error': error})}>
      {if error
        <div className="ui-alerts" style={marginBottom: '10px'}>
          <div className="error ui-alert">
            {error}
          </div>
        </div>
      }
      <MetaKeyFormLabel name={name} metaKey={get.meta_key} contextKey={null} />
      <InputMetaDatum name={name} get={get}/>
    </fieldset>
