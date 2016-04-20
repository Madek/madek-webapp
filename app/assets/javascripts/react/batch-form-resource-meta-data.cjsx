React = require('react')
f = require('active-lodash')
RailsForm = require('./lib/forms/rails-form.cjsx')
MetaKeyFormLabel = require('./lib/forms/form-label.cjsx')
InputMetaDatum = require('./lib/input-meta-datum.cjsx')
MadekPropTypes = require('./lib/madek-prop-types.coffee')
Classnames = require('classnames')
t = require('../lib/string-translation.coffee')('de')

module.exports = React.createClass
  displayName: 'BatchFormResourceMetaData'

  render: ({get, authToken} = @props) ->
    name = 'media_entry[meta_data]'
    vocabularies = get.batch_entries[0].meta_data.by_vocabulary

    <RailsForm name='batch_resource_meta_data' action={get.submit_url}
      method='put' authToken={authToken}>

      {f.map get.batch_entries, (batch_entry) ->
        <input name="batch_resource_meta_data[id][]" key={batch_entry.uuid} value={batch_entry.uuid} type="hidden"></input>
      }

      <div className='app-body-content table-cell ui-container table-substance ui-container'>
        <div className='form-body'>
          {f.keys(vocabularies).map (voc_id)->
            <VocabularyFormItem batch_entries={get.batch_entries}
              vocabulary_data={vocabularies[voc_id]} name={name} key={voc_id}/>
          }
        </div>
      </div>

      <BatchHintBox />

      <div className='form-footer'>
        <div className='ui-actions'>
          <a className='weak' href={get.url}>Cancel</a>
          <button className='primary-button large'
            type='submit'>Save</button>
        </div>
      </div>

    </RailsForm>


BatchHintBox = React.createClass
  displayName: 'BatchHintBox'
  render: () ->
    <div className="app-body-sidebar table-cell ui-container table-side pll">
      <div className="ui-container bordered rounded">
        <div className="ui-form-group rowed separated">
          <div className="form-label">
            {t('meta_data_batch_hint_no_data')}
          </div>
          <div className="form-item">
            <input className="block" type="text" readOnly="true"></input>
          </div>
        </div>
        <div className="ui-form-group rowed highlight separated">
          <div className="form-label">
            {t('meta_data_batch_hint_differences')}
            <small>
              {t('meta_data_batch_hint_differences_override')}
            </small>
          </div>
          <div className="form-item">
            <input className="block" type="text" readOnly="true"></input>
          </div>
        </div>
        <div className="ui-form-group rowed">
          <div className="form-label">
            {t('meta_data_batch_hint_equal_data')}
          </div>
          <div className="form-item">
            <input className="block" type="text" value={t('meta_data_batch_hint_value')} readOnly="true"></input>
          </div>
        </div>

      </div>
    </div>



VocabularyFormItem = React.createClass
  displayName: 'VocabularyFormItem'
  render: ({vocabulary_data, name, batch_entries} = @props) ->
    <div className='mbl'>
      <VocabularyHeader vocabulary={vocabulary_data.vocabulary} batch_entries={batch_entries}/>
      {vocabulary_data.meta_data.map (datum)->
        <MetaDatumFormItem datum={datum} name={name} key={datum.meta_key.uuid}
          batch_entries={batch_entries} vocabulary={vocabulary_data.vocabulary} />
      }
    </div>

VocabularyHeader = React.createClass
  displayName: 'VocabularyHeader'
  render: ({vocabulary, batch_entries} = @props)->
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

  render: ({datum, name, batch_entries, vocabulary} = @props) ->
    difference = compare_datum_between_entries(vocabulary, datum, batch_entries)
    copy = f.cloneDeep(datum)
    if not difference.all_equal
      copy.values = []
    new_name = name + "[#{datum.meta_key.uuid}][values][]"
    classes = Classnames('ui-form-group', 'columned', { 'highlight': not difference.all_equal})
    <fieldset className={classes}>
      <input name={name + "[#{datum.meta_key.uuid}][difference][all_equal]"} value={difference.all_equal} type="hidden"></input>
      <input name={name + "[#{datum.meta_key.uuid}][difference][all_empty]"} value={difference.all_empty} type="hidden"></input>
      <MetaKeyFormLabel name={new_name} metaKey={datum.meta_key}/>
      <InputMetaDatum name={new_name} get={copy}/>
    </fieldset>


equal_meta_data_values = (set_a, set_b, attribute) ->

  # Compare the two arrays. First copy both, then remove iteratively an
  # element from A and remove the same in B. If it is not in B, they are not
  # equal.

  # First check the lengths.
  if set_a.length != set_b.length
    return false

  # Copy both arrays.
  rest_a = f.map set_a, (el_a) ->
    el_a
  rest_b = f.map set_b, (el_b) ->
    el_b

  # Remove element from array A...
  while rest_a.length > 0
    el_a = rest_a.pop()

    # ... and search same element in array B and remove it if it is found.
    found_b = false
    to_remove_b = null
    f.each rest_b, (el_b, index_b) ->
      if not found_b
        if attribute == null
          found_b = true if el_a == el_b
        else
          found_b = true if el_a[attribute] == el_b[attribute]
        to_remove_b = index_b if found_b

    # If the element is not found in array B, they are not equal.
    if not found_b
      return false
    else
      rest_b.splice(to_remove_b, 1)

  return true

compare_datums = (datum_a, datum_b) ->

  both_empty = false
  both_equal = false

  if datum_a.values.length == 0 && datum_b.values.length == 0
    both_empty = true
    both_equal = true
  else if datum_a.values.length != datum_b.values.length
    both_empty = false
    both_equal = false
  else if datum_a.type == "MetaDatum::Text" or datum_a.type == "MetaDatum::TextDate"
    both_equal = equal_meta_data_values(datum_a.values, datum_b.values, null)
  else
    both_equal = equal_meta_data_values(datum_a.values, datum_b.values, 'uuid')

  return {
    both_empty: both_empty,
    both_equal: both_equal
  }

find_other_datum_in_voc = (reference_meta_key_id, other_vocabulary) ->
  other = null
  f.each other_vocabulary.meta_data, (datum, index) ->
    if reference_meta_key_id == datum.meta_key_id
      other = datum
  return other

compare_datum_between_entries = (refernce_vocabulary, reference_datum, all_entries) ->

  all_empty = true
  all_equal = true

  # Note: We take the datum of the first entry as the reference datum.
  # We do not explicitly check if we compare the entry against itself,
  # since this does not change the result.

  f.each(all_entries, (entry, index) ->

    other = find_other_datum_in_voc(
      reference_datum.meta_key_id,
      entry.meta_data.by_vocabulary[refernce_vocabulary.uuid])

    # "other" may never be null.

    diff_d_res = compare_datums(reference_datum, other)
    if not diff_d_res.both_empty
      all_empty = false
    if not diff_d_res.both_equal
      all_equal = false
  )

  return {
    all_empty: all_empty,
    all_equal: all_equal
  }
