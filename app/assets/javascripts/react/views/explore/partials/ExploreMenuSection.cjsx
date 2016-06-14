React = require('react')
cx = require('classnames')

module.exports = React.createClass
  displayName: 'ExploreMenuSection'
  render: ({label, hrefUrl, active} = @props)->
    <li className={cx('ui-side-navigation-item', {'active': active})}>
      <a className="strong" href={hrefUrl}>{label}</a>
      {@props.children}
    </li>
