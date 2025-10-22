import React, { useState, useEffect } from 'react'
import Preloader from './Preloader.jsx'

const Modal = ({ widthInPixel, loading, children }) => {
  const [active, setActive] = useState(false)

  useEffect(() => {
    setActive(true)
    document.body.style.overflow = 'hidden'

    return () => {
      document.body.style.overflow = 'auto'
    }
  }, [])

  let modalStyle, fixedStyle, staticStyle

  if (active === true) {
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

  if (widthInPixel && active === false) {
    modalStyle.width = widthInPixel + 'px'
    modalStyle.marginLeft = `-${widthInPixel / 2}px`
  } else {
    modalStyle.width = widthInPixel + 'px'
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
      {loading ? (
        <Preloader />
      ) : (
        <div style={fixedStyle}>
          <div style={staticStyle}>
            <div className="modal" style={modalStyle}>
              {children}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default Modal
module.exports = Modal
