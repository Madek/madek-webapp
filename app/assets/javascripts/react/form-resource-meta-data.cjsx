React = require('react')
f = require('../lib/fun.coffee')
RailsForm = require('./lib/forms/rails-form.cjsx')
MetaKeyFormLabel = require('./lib/forms/form-label.cjsx')
InputMetaDatum = require('./lib/input-meta-datum.cjsx')
MadekPropTypes = require('./lib/madek-prop-types.coffee')

module.exports = React.createClass
  displayName: 'FormResourceMetaData'
  render: ({get, token} = @props)->
    name = 'media_entry[meta_data]' # TMP
    meta_data = get.meta_data.by_vocabulary

    <RailsForm name='resource_meta_data' action={get.url + '/meta_data'}
      method='put' token={token}>

      <div className='form-body'>
        {f.keys(meta_data).map (voc_id)->
          <VocabularyFormItem get={meta_data[voc_id]} name={name} key={voc_id}/>
        }
      </div>

      <div className='form-footer'>
        <div className='ui-actions'>
          <a className='weak' href={get.url}
            >Cancel</a>
          <button className='primary-button large'
            type='submit'
            >Save</button>
        </div>
      </div>
    </RailsForm>

VocabularyFormItem = React.createClass
  displayName: 'VocabularyFormItem'
  render: ({get, name} = @props)->
    <div className='mbl'>
      <VocabularyHeader vocabulary={get.vocabulary}/>
      {get.meta_data.map (datum)->
        <MetaDatumFormItem get={datum} name={name} key={datum.meta_key.uuid}/>
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

  render: ({get, name} = @props)->
    name += "[#{get.meta_key.uuid}][]"
    <fieldset className='ui-form-group columned'>
      <MetaKeyFormLabel name={name} metaKey={get.meta_key}/>
      <InputMetaDatum name={name} get={get}/>
    </fieldset>
