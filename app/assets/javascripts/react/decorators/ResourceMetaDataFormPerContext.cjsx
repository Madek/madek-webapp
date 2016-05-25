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
  displayName: 'ResourceMetaDataFormPerContext'

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

  render: ({get, authToken, context} = @props, {errors} = @state) ->
    name = "#{f.snakeCase(get.type)}[meta_data]"

    meta_data = context.meta_data

    #meta_data = f.sortBy(get.meta_data.by_vocabulary, 'vocabulary.position')

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
        {
          f.map meta_data, (datum) ->
            <MetaDatumFormItem
              get={datum} name={name}
              error={errors[datum.meta_key.uuid]}
              key={datum.meta_key.uuid}/>
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
      <MetaKeyFormLabel name={name} metaKey={get.meta_key}/>
      <InputMetaDatum name={name} get={get}/>
    </fieldset>
