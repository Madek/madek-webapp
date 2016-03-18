React = require('react')
f = require('active-lodash')
cx = require('classnames')

Picture = require('../ui-components/Picture.cjsx')
MediaPlayer = require('../ui-components/MediaPlayer.cjsx')

module.exports = React.createClass({
  displayName: 'MediaEntryPreview',
  propTypes: {
    get: React.PropTypes.object.isRequired # TODO: <MediaEntry(Previews)>
    mods: React.PropTypes.any},

  render: ({audio_previews, video_previews, image_url, title} = this.props.get)->
    classes = cx(this.props.mods)

    switch
      when video_previews
        <MediaPlayer type='video' className={classes}
          sources={video_previews} poster={image_url}/>
      when audio_previews
        <div className='ui-container mtm'>
          <MediaPlayer type='audio' className={classes}
            sources={audio_previews} poster={image_url}/></div>
      else
        <Picture className={classes} src={image_url} alt={title}/>
})
