React = require('react')
MadekPropTypes = require('../madek-prop-types.coffee')
Icon = require('../../ui-components/Icon.cjsx')
Tooltipped = require('../../ui-components/Tooltipped.cjsx')

module.exports = React.createClass
  displayName: 'MetaKeyFormLabel'
  propTypes:
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
        ttId = (metaKey || contextKey).uuid + '_tooltip' # for a11y
        <Tooltipped text={description} id={ttId}>
          <span className='ui-form-ui-ttip-toggle ui-ttip-toggle'>
            <Icon i='question'/>
          </span>
        </Tooltipped>
      }
      <small>{hint}</small>
    </div>
