React = require('react')
MadekPropTypes = require('../madek-prop-types.coffee')

module.exports = React.createClass
  displayName: 'MetaKeyFormLabel'
  propTypes:
    name: React.PropTypes.string.isRequired
    metaKey: MadekPropTypes.metaKey

  render: ({metaKey} = @props)->

    label = metaKey.label
    if @props.mandatory
      label = label + ' *'

    <label className='form-label'>
      {label}
      {if (description = metaKey.description)
        <span className='ui-form-ui-ttip-toggle ui-ttip-toggle' rel='tooltip'
          title={description}>
          <i className='icon-question'/>
        </span>
      }
      <small>{metaKey.hint}</small>
    </label>
