// Wrap this around anything for bootstrap-style tooltips

import React, { useState, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import Tooltip from 'react-bootstrap/lib/Tooltip'
import Overlay from 'react-bootstrap/lib/Overlay'

const Tooltipped = ({ text, link, id, children }) => {
  const [showTooltip, setShowTooltip] = useState(false)
  const targetRef = useRef(null)
  const timerRef = useRef(null)

  const handleShowTooltip = () => {
    if (timerRef.current) {
      clearTimeout(timerRef.current)
    }
    setShowTooltip(true)
  }

  const handleHideTooltip = () => {
    timerRef.current = setTimeout(() => setShowTooltip(false), 30)
  }

  useEffect(() => {
    return () => {
      if (timerRef.current) {
        clearTimeout(timerRef.current)
      }
    }
  }, [])

  const getTriggerEl = children => {
    const child = React.Children.toArray(children)[0]

    return React.cloneElement(child, {
      onMouseEnter: handleShowTooltip,
      onMouseLeave: handleHideTooltip,
      ref: el => {
        targetRef.current = el
      }
    })
  }

  return (
    <span>
      {getTriggerEl(children)}
      <Overlay show={showTooltip} target={targetRef.current} placement="top">
        <Tooltip id={id} onMouseEnter={handleShowTooltip} onMouseLeave={handleHideTooltip}>
          {text}
          {link && <div>({link})</div>}
        </Tooltip>
      </Overlay>
    </span>
  )
}

Tooltipped.propTypes = {
  text: PropTypes.string.isRequired,
  link: PropTypes.element,
  id: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired
}

export default Tooltipped
module.exports = Tooltipped
