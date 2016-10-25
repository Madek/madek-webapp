React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
xhr = require('xhr')
cx = require('classnames')
t = require('../../lib/string-translation.js')('de')
InputMetaDatum = require('../decorators/InputMetaDatum.cjsx')
MetaKeyFormLabel = require('../lib/forms/form-label.cjsx')
MadekPropTypes = require('../lib/madek-prop-types.coffee')

module.exports = React.createClass

  displayName: 'MetaDatumFormItemPerContext'
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

  render: ({name, error} = @props) ->

    if @props.batch
      name += "[#{@props.metaKeyId}][values][]"
    else
      name += "[#{@props.metaKeyId}][]"

    meta_key = @props.allMetaMetaData.meta_key_by_meta_key_id[@props.metaKeyId]

    newget = f.mapValues @props.get, (value) ->
      value
    newget.values = @props.model.values

    style = {}
    if @props.hidden
      style = {display: 'none'}

    validErr = @props.published and @props.requiredMetaKeyIds[@props.metaKeyId] and not @_validModel(@props.model)

    batchConflict = false
    if @props.batchConflict
      batchConflict = not @props.batchConflict.all_equal

    className = cx('ui-form-group columned prh', {'error': (error or validErr) and not batchConflict}, {'highlight': batchConflict})

    # FIXE: wtf? contextKey can be null?
    inputID = f.get(@props, 'contextKey.uuid') || @props.metaKeyId

    <fieldset style={style} className={className}>
      {if error
        <div className="ui-alerts" style={marginBottom: '10px'}>
          <div className="error ui-alert">
            {error}
          </div>
        </div>
      }
      {
        # signStyle = {
        #   color: '#d9534f',
        #   display: 'table',
        #   marginLeft: '-25px',
        #   float: 'left',
        #   paddingTop: '7px',
        #   paddingBottom: '10px'
        # }
        # if @props.requiredMetaKeyIds[@props.metaKeyId] and not @_validModel(@props.model)
        #   signStyle.color = '#d9534f'
        #   <i className='icon-bang' style={signStyle} />
        # else if @props.requiredMetaKeyIds[@props.metaKeyId]
        #   signStyle.color = '#5cb85c'
        #   <i className='icon-checkmark' style={signStyle} />
        # else
        #   <div style={{display: 'table', marginLeft: '-20px', float: 'left', paddingTop: '5px', paddingBottom: '10px'}}></div>
        null
      }
      <MetaKeyFormLabel name={name} metaKey={meta_key} contextKey={@props.contextKey}
        mandatory={@props.requiredMetaKeyIds[@props.metaKeyId]}/>
      <InputMetaDatum id={inputID} onChange={@_onChange} name={name} get={newget} />

    </fieldset>
