React = require('react')
f = require('active-lodash')
InputFieldText = require('../forms/input-field-text.cjsx')

module.exports = React.createClass
  displayName: 'InputText'
  propTypes:
    name: React.PropTypes.string.isRequired
    values: React.PropTypes.array.isRequired
    active: React.PropTypes.bool.isRequired
    multiple: React.PropTypes.bool.isRequired

  render: ({get, name, values, active, multiple} = @props)->
    <div className='form-item'>
      <div className='form-item-values'>
        {values.map (textValue, n)->
          <InputFieldText name={name} value={textValue} key={n}/>
        }
      </div>

      {if multiple # add a value:
        <div className='form-item-add'>
          <InputFieldText name={name}/>
        </div>
      }
    </div>
