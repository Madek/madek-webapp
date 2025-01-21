/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import Preloader from './Preloader.jsx'

module.exports = createReactClass({
  displayName: 'Modal',

  getInitialState() {
    return { active: false }
  },

  componentDidMount() {
    this.setState({ active: true })
    return $('body').css('overflow', 'hidden')
  },

  componentWillUnmount() {
    return $('body').css('overflow', 'auto')
  },

  render() {
    let fixedStyle, modalStyle, staticStyle
    if (this.state.active === true) {
      modalStyle = {
        position: 'static',
        zIndex: '1000000',
        margin: 'auto',
        width: '200px'
      }
      fixedStyle = {
        position: 'fixed',
        zIndex: '1000000',
        overflow: 'scroll',
        top: '0px',
        left: '0px',
        bottom: '0px',
        right: '0px'
      }
      staticStyle = {
        position: 'static',
        marginTop: '100px',
        marginBottom: '100px',
        overflow: 'visible'
      }
    } else {
      modalStyle = {
        zIndex: '1000000',
        top: '100px',
        position: 'absolute'
      }
      fixedStyle = {}
      staticStyle = {}
    }

    if (this.props.widthInPixel && this.state.active === false) {
      modalStyle.width = this.props.widthInPixel + 'px'
      modalStyle.marginLeft = `-${this.props.widthInPixel / 2}px`
    } else {
      modalStyle.width = this.props.widthInPixel + 'px'
    }

    const wrapperStyle = {
      position: 'absolute',
      top: '0px',
      bottom: '0px',
      left: '0px',
      right: '0px',
      zIndex: '100000'
    }

    return (
      <div style={wrapperStyle}>
        <div className="modal-backdrop" />
        {this.props.loading ? (
          <Preloader />
        ) : (
          <div style={fixedStyle}>
            <div style={staticStyle}>
              <div className="modal" style={modalStyle}>
                {this.props.children}
              </div>
            </div>
          </div>
        )}
      </div>
    )
  }
})
