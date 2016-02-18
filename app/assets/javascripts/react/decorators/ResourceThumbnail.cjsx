React = require('react')
async = require('async')
f = require('active-lodash')
ampersandReactMixin = require('ampersand-react-mixin')
urlFromBrowserFile = require('../../lib/url-from-browser-file.coffee')
{Icon, Thumbnail} = require('../ui-components/index.coffee')
xhr = require('xhr')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
RailsForm = require('../lib/forms/rails-form.cjsx')
Button = require('../ui-components/Button.cjsx')


getUrlFromBrowserFileQueue = async.queue(urlFromBrowserFile, 1)

# async! will cause re-render with the new img, but only once per file:
localPreviewImage = (resource, callback)->
  # TODO: generic fallback images
  type = f.get(resource, 'uploading.file.type')
  switch
    when /image\//.test(type)
      getUrlFromBrowserFileQueue.push f.get(resource, 'uploading.file'), (url)->
        return callback({}) if not url
        callback(localPreview: url)
    else
      callback({})

module.exports = React.createClass
  displayName: 'ResourceThumbnail'
  mixins: [ampersandReactMixin]
  getInitialState: ()-> {
    active: true
    starActive: @props.get.favored
    javascript: false
    pendingFavorite: false
    favoriteVisible: @props.get.favorite_policy
  }
  componentDidMount: ()->
    localPreviewImage(@props.resource, @setState.bind(@))
    @setState(javascript: true)
  componentWillReceiveProps: (nextProps)->
    return if (@props.uploading?.file is nextProps.uploading?.file)
    localPreviewImage(nextProps.resource, @setState.bind(@))
  favorOnClick: () ->
    @setState(starActive: not @state.starActive)
    action = if @state.starActive then 'disfavor' else 'favor'
    @favorAjax(action);

  favorAjax: (action) ->
    @setState(pendingFavorite: true)
    url = @props.get.url + '/' + action
    req = xhr
      method: 'PATCH'
      url: url
      body: ''
      headers:
        'Accept': 'application/json'
        'X-CSRF-Token': getRailsCSRFToken()
      ,
      (err, res)=>
        result = (try JSON.parse(res.body))
        @setState(starActive: result.isFavored)
        @setState(pendingFavorite: false)


  propTypes:
    authToken: React.PropTypes.string
    resource: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry', 'Collection', 'FilterSet'])



  render: ({get, elm, authToken} = @props, state = @state)->
    # map the type name:
    type = get.type.replace(/Collection/, 'MediaSet')
    # map the privacy icon:
    # see <http://madek.readthedocs.org/en/latest/entities/#privacy-status>
    # vs <http://test.madek.zhdk.ch/styleguide/Icons#6.2>
    iconMapping = {'public': 'open', 'private': 'private', 'shared': 'group'}
    privacyIcon = "privacy-#{iconMapping[get.privacy_status]}"


    favoriteAction = if get.favored then 'disfavor' else 'favor'
    favoriteUrl = get.url + '/' + favoriteAction


    starClass = if @state.starActive then 'icon-star' else 'icon-star-empty'
    favoriteItem = <i className={starClass}></i>
    favoriteOnClick = @favorOnClick if not @state.pendingFavorite

    actionsLeft = []

    if get.favorite_policy

      favorButton = if true #@state.javascript or true
          <Button className='ui-thumbnail-action-favorite' onClick={favoriteOnClick} data-pending={@state.pendingFavorite}>
            {favoriteItem}
          </Button>
        else
          <RailsForm name='resource_meta_data' action={favoriteUrl}
            method='patch' authToken={authToken}>
            <button className='ui-thumbnail-action-favorite' type='submit'>
              {favoriteItem}
            </button>
          </RailsForm>

      actionsLeft.push(
                <li key='favorite' className='ui-thumbnail-action'>
                  {favorButton}
                </li>
              )


    Element = elm or 'div'
    props =
      type: f.kebabCase(type)
      src: get.image_url or state.localPreview or '.'
      href: get.url
      alt: get.title
      meta:
        title: get.title or get.uploadStatus
      badgeLeft:
        <Icon i={privacyIcon} title={get.privacy_status}/>
      badgeRight: if get.type is 'FilterSet'
        <Icon i='filter' title='This is a Filterset'/>
      actionsLeft: actionsLeft
      actionsRight: []

    <Element className='ui-resource'>
      <div className='ui-resource-body'>
        <Thumbnail {...props}/>
      </div>
    </Element>
