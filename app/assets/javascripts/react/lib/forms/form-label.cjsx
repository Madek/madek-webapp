React = require('react')
MadekPropTypes = require('../madek-prop-types.coffee')

module.exports = React.createClass
  displayName: 'MetaKeyFormLabel'
  propTypes:
    name: React.PropTypes.string.isRequired
    metaKey: MadekPropTypes.metaKey

  render: ({metaKey, contextKey} = @props)->

    label = metaKey.label
    hint = metaKey.hint
    description = metaKey.description

    if contextKey
      if contextKey.label
        label = contextKey.label
      if contextKey.hint
        hint = contextKey.hint
      if contextKey.description
        description = contextKey.description


    if @props.mandatory
      label = label + ' *'

    <div className='form-label'>
      {label}
      {if description
        <span className='ui-form-ui-ttip-toggle ui-ttip-toggle'
          title={description}>
          <i className='icon-question'/>
        </span>
      }
      <small>{hint}</small>
    </div>
