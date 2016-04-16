React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
cx = require('classnames')

Link = require('../ui-components/Link.cjsx')
Icon = require('../ui-components/Icon.cjsx')
Picture = require('../ui-components/Picture.cjsx')
MediaPlayer = require('../ui-components/MediaPlayer.cjsx')

module.exports = React.createClass({
  displayName: 'MediaEntryPreview',
  propTypes: {
    get: PropTypes.shape({
      title: PropTypes.string.isRequired,
      image_url: PropTypes.string.isRequired,
      media_file: PropTypes.shape({
        previews: PropTypes.object
        original_file_url: PropTypes.string
      }).isRequired
    }).isRequired,
    mods: PropTypes.any
    },

  render: ()->
    {image_url, title} = @props.get
    {previews} = @props.get.media_file

    classes = cx(this.props.mods)
    href = f.chain(previews.images).sortBy('width').last().get('url').run()

    picture = <Picture className={classes} src={image_url} title={title}/>

    switch
      # video player
      when previews.videos
        <MediaPlayer type='video' className={classes}
          sources={previews.videos} poster={image_url}/>

      # audio player
      when previews.audios
        <div className='ui-container mvm'>
          <MediaPlayer type='audio' className={classes}
            sources={previews.audios} poster={image_url}/></div>

      # picture with link and 'zoom' icon on hover
      when href
        hasZoom = !(href == image_url)
        <div className={cx({'ui-has-magnifier': hasZoom})}>
          <a href={href}>
            {picture}
          </a>
          {if hasZoom
            <a href={href} target='_blank' className='ui-magnifier'>
              <Icon i='magnifier' mods='bright'/>
            </a>}
        </div>

      else
        picture
})
