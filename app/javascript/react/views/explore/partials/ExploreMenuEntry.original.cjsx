React = require('react')
cx = require('classnames')

module.exports = React.createClass
  displayName: 'ExploreMenuEntry'
  render: ({label, hrefUrl, active} = @props)->
    <ul className="ui-side-navigation-lvl2">
      <li className={cx('ui-side-navigation-lvl2-item', {'active': active})}>
        <a className="weak" href={hrefUrl}>{label}</a>
      </li>
    </ul>
