React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../madek-prop-types.coffee')
Text = require('./input-text-async.cjsx')
InputResources = require('./input-resources.cjsx')
InputTextDate = require('./InputTextDate.js').default

module.exports = React.createClass
  displayName: 'InputKeywords'
  propTypes:
    name: React.PropTypes.string.isRequired
    values: React.PropTypes.array.isRequired
    get: React.PropTypes.shape(
      meta_key: MadekPropTypes.metaKey.isRequired
      fixed_selection: React.PropTypes.bool.isRequired
      keywords: React.PropTypes.arrayOf(MadekPropTypes.keyword)
    ).isRequired

  _onChange: (event) ->
    if @props.onChange
      uuid = event.target.value
      checked = event.target.checked

      # In any case remove the element first.
      values = f.filter @props.values, (value) ->
        value.uuid != uuid
      # Then add it again if needed.
      if checked
        values.push({uuid: uuid})

      @props.onChange(values)

  render: ({name, values, get} = @props)->
    {meta_key, keywords, fixed_selection} = get
    # - "keywords" might be given as possible values
    # - for fixed selections show checkboxes (with possible values)
    #   otherwise the show autocompleter (prefilled with pos. values if given)

    if fixed_selection and !f.present(keywords)
      throw new Error('Input: No Keywords given for fixed selection!')


    # show an autocomplete:
    if !fixed_selection
      params = {meta_key_id: meta_key.uuid}
      # prefill the autocomplete if data was given:
      if keywords
        autocompleteConfig = { minLength: 0, localData: keywords }

      <InputResources {...@props}
        resourceType='Keywords'
        searchParams={params}
        extensible={meta_key.is_extensible}
        autocompleteConfig={autocompleteConfig}/>

    else # is fixed_selection — checkboxes:
      <div className='form-item'>
        {#hidden field needed for broken Rails form serialization}
        <input type='hidden' name={name} value=''/>

        {keywords.map (kw) =>
          # determine initial checked status according to current values:
          isInitiallySelected = f.any(values, { uuid: kw.uuid })

          <label className='col2of6' key={kw.uuid}>
            <input type='checkbox'
              onChange={if @props.onChange then @_onChange else null}
              name={name}
              checked={isInitiallySelected}
              value={kw.uuid}/>
            {kw.label}
          </label>
        }
        {@props.subForms}
      </div>
