React = require('react')
t = require('../../../lib/i18n-translate.js')
MadekPropTypes = require('../madek-prop-types.js')
Icon = require('../../ui-components/Icon.cjsx')
Link = require('../../ui-components/Link.cjsx')
Tooltipped = require('../../ui-components/Tooltipped.cjsx')

module.exports = React.createClass
  displayName: 'MetaKeyFormLabel'
  propTypes:
    metaKey: MadekPropTypes.metaKey

  render: ({metaKey, contextKey} = @props)->
    { label, hint, description, documentation_url } = metaKey

    if contextKey
      if contextKey.label
        label = contextKey.label
      if contextKey.hint
        hint = contextKey.hint
      if contextKey.description
        description = contextKey.description
      if contextKey.documentation_url
        documentation_url = contextKey.documentation_url

    if documentation_url
      linkToDocs =
        <Link
          href={documentation_url}
          target='_blank'
        >{t('meta_data_meta_key_documentation_url')}</Link>

    if @props.mandatory
      label = label + ' *'

    <div className='form-label'>
      {label}
      {if description
        ttId = (metaKey || contextKey).uuid + '_tooltip' # for a11y
        <Tooltipped text={description} link={linkToDocs} id={ttId}>
          <span className='ui-form-ui-ttip-toggle ui-ttip-toggle'>
            <Icon i='question'/>
          </span>
        </Tooltipped>
      }
      <small>{hint}</small>
    </div>
