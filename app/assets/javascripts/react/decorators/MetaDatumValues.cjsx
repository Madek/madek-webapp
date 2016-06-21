# Takes a MetaDatum and displays the values according to the type.

React = require('react')
f = require('active-lodash')
linkifyStr = require('linkifyjs/string')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
resourceName = require('../lib/decorate-resource-names.coffee')
UI = require('../ui-components/index.coffee')

# Decorator for each type is single stateless-function-component,
# the main/exported component just selects the right one.
DecoratorsByType =
  Text: ({values} = @props)->
    <ul className='inline'>
      {values.map (string)->
        <li key={string} dangerouslySetInnerHTML={linkifyInnerHtml(string)}/>}</ul>

  TextDate:  ({values} = @props)->
    <ul className='inline'>
      {values.map (string)-> <li key={string}>{string}</li>}</ul>

  People: ({values, tagMods} = @props)->
    <UI.TagCloud mod='person' mods='small' list={labelize(values)}/>

  Groups: ({values, tagMods} = @props)->
    <UI.TagCloud mod='group' mods='small' list={labelize(values)}/>

  Keywords: ({values, tagMods} = @props)->
    <UI.TagCloud mod='label' mods='small' list={labelize(values)}/>

  Licenses: ({values} = @props)->
    <ul className='inline'>
      {values.map (license)->
        <li key={license.uuid}>
          <UI.Link href={license.url}>{license.label}</UI.Link></li>}</ul>


module.exports = React.createClass
  displayName: 'Deco.MetaDatumValues'
  propTypes:
    metaDatum: MadekPropTypes.metaDatum.isRequired
    tagMods: React.PropTypes.any # TODO: mods

  render: ({type, values, tagMods} = @props.metaDatum)->
    DecoratorByType = DecoratorsByType[f.trimLeft(type, 'MetaDatum::')]
    <DecoratorByType values={values} tagMods={tagMods}/>


# helpers

## build tag from name and url and provide unique key
labelize = (resourceList)->
  resourceList.map (resource)->
    {children: resourceName(resource), href: resource.url, key: resource.uuid}

## build html string with auto-generated links
linkifyInnerHtml = (string)->
  {__html: linkifyStr(string,
    linkClass: 'link ui-link-autolinked'
    linkAttributes:
      rel: 'nofollow'
    target: '_self'
    nl2br: true # also takes care of linebreaks…
    format: (value, type)->
      if (type == 'url' && value.length > 50)
        value = value.slice(0, 50) + '…'
      return value)}
