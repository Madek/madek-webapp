React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
xhr = require('xhr')
cx = require('classnames')
t = require('../../lib/string-translation.js')('de')
setUrlParams = require('../../lib/set-params-for-url.coffee')
RailsForm = require('../lib/forms/rails-form.cjsx')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
MetaKeyFormLabel = require('../lib/forms/form-label.cjsx')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
MetaDatumFormItem = require('./MetaDatumFormItemPerContext.cjsx')

module.exports = React.createClass
  displayName: 'ResourceMetaDataFormPerContext'

  getInitialState: () ->
    mounted: false
    editing: false
    errors: {}
    saving: false

  componentDidMount: () ->
    @setState({mounted: true})

  _actionUrl: () ->
    automaticPublish = @props.validityForAll == 'valid' and @state.mounted == true and not @props.get.published
    if automaticPublish
      actionType = 'publish'
    else
      actionType = 'save'


    url = @props.get.url + '/meta_data'

    if @props.batch
      actionType = 'save'
      url = @props.get.submit_url

    url = url + '?actionType=' + actionType

    # Note: Return to must be a hidden field to for the server-side case.
    # Url parameters are ignored in the <form action=... field.
    url = setUrlParams(url, {return_to: @props.get.return_to})


  submit: (actionType) ->

    @setState(saving: true)
    serialized = @refs.form.serialize()
    xhr(
      {
        method: 'PUT'
        url: @_actionUrl()
        body: serialized
        headers: {
          'Accept': 'application/json'
          'Content-type': 'application/x-www-form-urlencoded'
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, body) =>
        try
          data = JSON.parse(body)
        catch error
          console.error('Cannot parse body of answer for meta data update', error)

        if res.statusCode == 400
          @setState({saving: false})
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

  _onClick: (event) ->
    event.preventDefault()
    @submit(event.target.value)
    return false

  render: ({get, authToken, context} = @props, {errors} = @state) ->

    name = "#{f.snakeCase(get.type)}[meta_data]"
    if @props.batch
      name = "media_entry[meta_data]"

    meta_data = get.meta_data

    disableSave = (@state.saving or not @props.hasAnyChanges or (@props.validityForAll == 'invalid' and @props.get.published)) and @state.mounted == true

    disablePublish = (@state.saving or @props.validityForAll != 'valid')
    showPublish = not @props.get.published and @state.mounted == true

    showPublish = false

    published = get.published
    if @props.batch
      published = false
      f.each get.batch_entries, (entry) ->
        published = true if entry.published

    cancelUrl = @props.get.return_to

    <RailsForm ref='form'
      name='resource_meta_data' action={@_actionUrl()}
      method='put' authToken={authToken}>

      <input type='hidden' name='return_to' value={@props.get.return_to} />


      {if @state.errors and f.keys(@state.errors).length > 0
        <div className="ui-alerts" style={marginBottom: '10px'}>
          <div className="error ui-alert">
            {t('resource_meta_data_has_validation_errors')}
          </div>
        </div>
      }

      <div className='form-body'>

        {
          f.map get.batch_entries, (entry) ->
            <input key={entry.uuid} type='hidden' name='batch_resource_meta_data[id][]' value={entry.uuid} />
        }

        {

          f.map get.meta_meta_data.meta_key_ids_by_context_id[context.uuid], (meta_key_id) =>
            datum = get.meta_data.meta_datum_by_meta_key_id[meta_key_id]

            <MetaDatumFormItem
              batch={@props.batch}
              published={published}
              batchConflict={@props.batchDiff[meta_key_id]}
              hidden={false}
              onChange={@props.onChange}
              allMetaMetaData={get.meta_meta_data}
              name={name}
              get={datum}
              metaKeyId={meta_key_id}
              model={@props.models[meta_key_id]}
              requiredMetaKeyIds={get.meta_meta_data.mandatory_by_meta_key_id}
              error={errors[meta_key_id]}
              key={meta_key_id}/>


        }
        {

          hidden_meta_key_ids = f.select (f.keys get.meta_meta_data.meta_key_by_meta_key_id), (meta_key_id) ->
            not (f.includes get.meta_meta_data.meta_key_ids_by_context_id[context.uuid], meta_key_id)

          f.map hidden_meta_key_ids, (meta_key_id) =>
            datum = get.meta_data.meta_datum_by_meta_key_id[meta_key_id]
            if datum
              <MetaDatumFormItem
                batch={@props.batch}
                published={published}
                hidden={true}
                onChange={@props.onChange}
                allMetaMetaData={get.meta_meta_data}
                name={name}
                get={datum}
                metaKeyId={meta_key_id}
                model={@props.models[meta_key_id]}
                requiredMetaKeyIds={get.meta_meta_data.mandatory_by_meta_key_id}
                error={errors[meta_key_id]}
                key={meta_key_id}/>


        }
      </div>

      <div className='form-footer'>
        <div className='ui-actions'>
          <a className='weak' href={cancelUrl}>Cancel</a>
          <button className='primary-button large' name='actionType' value='save'
            type='submit' onClick={@_onClick} disabled={disableSave}>Save</button>
          {
            if showPublish
              <button className='primary-button large' name='actionType' value='publish'
                type='submit' onClick={@_onClick} disabled={disablePublish}>Publish</button>
          }
        </div>
      </div>
    </RailsForm>
