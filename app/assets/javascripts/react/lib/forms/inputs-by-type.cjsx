React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../madek-prop-types.coffee')
Text = require('./input-text.cjsx')
InputResources = require('./input-resources.cjsx')

module.exports =
  Text: Text
  TextDate: Text

  People: React.createClass
    displayName: 'InputPeople'
    render: ()->
      <InputResources {...@props} resourceType='People'/>

  Licenses: React.createClass
    displayName: 'InputLicenses'
    render: ()->
      <InputResources {...@props} resourceType='Licenses'/>

  Keywords: React.createClass
    displayName: 'InputKeywords'
    propTypes:
      name: React.PropTypes.string.isRequired
      values: React.PropTypes.array.isRequired
      get: React.PropTypes.shape(
        meta_key: MadekPropTypes.metaKey.isRequired
        fixed_selection: React.PropTypes.bool.isRequired
        keywords: React.PropTypes.arrayOf(MadekPropTypes.keyword)
      ).isRequired

    render: ({name, values, get} = @props)->
      {meta_key, keywords, fixed_selection} = get
      # - "keywords" might be given as possible values
      # - for fixed selections show checkboxes (with possible values)
      #   otherwise the show autocompleter (prefilled with pos. values if given)

      if fixed_selection and !f.present(keywords)
        throw new Error('Input: No Keywords given for fixed selection!')


      if !fixed_selection
        params = {meta_key_id: meta_key.uuid}
        if !meta_key.is_extensible
          # TODO: prefill data!
          autocompleteConfig = { minLength: 0 }

        <InputResources {...@props}
          resourceType='Keywords'
          searchParams={params}
          autocompleteConfig={autocompleteConfig}/>

      else # is fixed_selection — checkboxes:
        <div className='form-item'>
          {#hidden field needed for broken Rails form serialization}
          <input type='hidden' name={name} value=''/>

          {keywords.map (kw)->
            # determine initial checked status according to current values:
            isInitiallySelected = f.any(values, { uuid: kw.uuid })

            <label className='col2of6' key={kw.uuid}>
              <input type='checkbox'
                name={name}
                defaultChecked={isInitiallySelected}
                value={kw.uuid}/>
                {kw.label}
            </label>
          }
        </div>
