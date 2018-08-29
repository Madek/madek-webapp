React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
cx = require('classnames')
libUrl = require('url')
qs = require('qs')

module.exports = React.createClass
  displayName: 'Sidebar'

  _endsWith: (string, suffix) ->
    string.indexOf(suffix, string.length - suffix.length) != - 1

  render: ({sections, for_url} = @props) ->

    show_beta = false

    <ul className='ui-side-navigation'>

      {
        f.flatten(f.map(f.keys(sections), (section_id) =>
          section = sections[section_id]
          link = section.href

          if !link
            throw new Error('Missing href attribute for \'' + section_id + '\' section!')

          link_active = @_endsWith(libUrl.parse(for_url).pathname, section_id)

          classes = cx(
            'ui-side-navigation-item',
            {'active': link_active}
          )

          f.compact([
            <li key={section_id + 'key1'} className={classes} key={section_id}>
              <a className='strong' href={link}>
                {
                  if section.is_beta && show_beta
                    <em style={{fontStyle: 'italic', fontWeight: 'normal'}}>Beta: </em>
                }
                {section.title}
              </a>

            </li>
            ,
            if section_id != f.last(f.keys(sections))
              <li  key={section_id + 'key2'} className='separator mini' />

          ])
        ))
      }



    </ul>
