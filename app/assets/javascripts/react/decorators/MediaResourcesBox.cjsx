React = require('react')
f = require('active-lodash')
ampersandReactMixin = require('ampersand-react-mixin')

RailsForm = require('../lib/forms/rails-form.cjsx')
ResourceThumbnail = require('./ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'MediaResourcesBox'
  mixins: [ampersandReactMixin]
  getObservedItems: ()-> [@props.get?.resources]

  render: ({get, mods, interactive} = @props)->
    get = f.defaultsDeep get,
      config:
        layout: 'grid'
        filter:
          meta_data: [{key: 'madek_core:title', value: ''}]

    classes = ['ui-container'].concat(mods).join(' ')

    Sidebar = if interactive
      <ResourceBoxSidebar {...get.config}/>

    paginationNavigation = if interactive and (pagination = get.pagination)
      <div className='row'>
        {if (prevLink = pagination.prev)
          <a className='button' href={prevLink}>Previous page</a>}
        {if (nextLink = pagination.next)
          <a className='button' href={nextLink}>Next page</a>
        }
      </div>

    # component:
    <div className={classes} id='ui-resources-list-container'>
      <div className='ui-resources-holder pam'>
        <div className='ui-container table auto'>
          {Sidebar}
          <div className="ui-container table-cell table-substance">
            <ul className='ui-resources grid'>
              {get.resources.map (item)->
                <li className='ui-resource' key={item.uuid or item.cid}>
                  <div className='ui-resource-body'>
                    <ResourceThumbnail get={item}/>
                  </div>
                </li>
              }
            </ul>
            {paginationNavigation}
          </div>
        </div>
      </div>
    </div>


ResourceBoxSidebar = ({filter} = @props)->
  <div className='filter-panel ui-side-filter' id='ui-side-filter'>
    <div className='ui-side-filter-search filter-search' id='ui-side-filter-search'>
      <RailsForm id='filter_search_form' name='list' method='get' mods='prm'>
        <textarea name='list[filter]' rows='25'
          style={{fontFamily: 'monospace', fontSize: '1em', width: '100%'}}
          defaultValue={JSON.stringify(filter, 0, 2)}/>
        <button className='button'>Submit</button>
      </RailsForm>
    </div>
  </div>
