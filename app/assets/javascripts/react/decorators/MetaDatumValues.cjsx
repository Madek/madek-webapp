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
    # NOTE: the wrapping seems useless but is currently needed for styling
    <ul className='inline measure-double'>
      {values.map (string)->
        <li key={string} dangerouslySetInnerHTML={linkifyInnerHtml(string)}/>}</ul>

  TextDate: ({values} = @props)->
    <ul className='inline'>
      {values.map (string)-> <li key={string}>{string}</li>}</ul>

  People: ({values, tagMods} = @props)->
    <UI.TagCloud mod='person' mods='small' list={labelize(values)}/>

  Roles: ({values, tagMods} = @props)->
    <UI.TagCloud mod='role' mods='small' list={labelize(values)}/>

  Groups: ({values, tagMods} = @props)->
    <UI.TagCloud mod='group' mods='small' list={labelize(values)}/>

  Keywords: ({values, tagMods} = @props)->
    <UI.TagCloud mod='label' mods='small' list={labelize(values)}/>

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
  resourceList.map (resource, i)->
    {children: resourceName(resource), href: resource.url, key: "#{resource.uuid}-#{i}"}

## build html string with auto-generated links
linkifyInnerHtml = (string)->
  {__html: linkifyStr(string,
    linkClass: 'link ui-link-autolinked'
    linkAttributes:
      rel: 'nofollow'
    target: '_self'
    nl2br: true # also takes care of linebreaks…
    validate: { # only linkyify if it starts with 'http://' (etc) or 'www.'
      url: (string) -> /^((http|ftp)s?:\/\/|www\.)/.test(string)
    },
    format: (value, type)->
      if (type == 'url' && value.length > 50)
        value = value.slice(0, 50) + '…'
      return value)}
