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

  displayName: 'MetaDatumFormItem'
  propTypes:
    name: PropTypes.string.isRequired

  _onChange: (values) ->
    if @props.onChange
      @props.onChange(@props.metaKeyId, values)

  _validModel: (model) ->
    if model.multiple
      model.values.length > 0
    else
      if model.values[0]
        model.values[0].trim().length > 0
      else
        false

  render: ({name, error} = @props)->
    name += "[#{@props.metaKeyId}][]"

    meta_key = @props.allMetaData.meta_key_by_meta_key_id[@props.metaKeyId]

    newget = f.mapValues @props.get, (value) ->
      value
    newget.values = @props.model.values

    style = {}
    if @props.hidden
      style = {display: 'none'}

    <fieldset style={style} className={cx('ui-form-group columned prh', {'error': error})}>
      {if error
        <div className="ui-alerts" style={marginBottom: '10px'}>
          <div className="error ui-alert">
            {error}
          </div>
        </div>
      }
      {
        signStyle = {
          color: '#d9534f',
          display: 'table',
          marginLeft: '-25px',
          float: 'left',
          paddingTop: '7px',
          paddingBottom: '10px'
        }
        if @props.requiredMetaKeyIds[@props.metaKeyId] and not @_validModel(@props.model)
          signStyle.color = '#d9534f'
          <i className='icon-bang' style={signStyle} />
        else if @props.requiredMetaKeyIds[@props.metaKeyId]
          signStyle.color = '#5cb85c'
          <i className='icon-checkmark' style={signStyle} />
        else
          <div style={{display: 'table', marginLeft: '-20px', float: 'left', paddingTop: '5px', paddingBottom: '10px'}}></div>
      }
      <MetaKeyFormLabel name={name} metaKey={meta_key}/>
      <InputMetaDatum onChange={@_onChange} name={name} get={newget}/>

    </fieldset>
