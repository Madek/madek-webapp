import React from 'react'

export default function SectionLabels({ items = [] }) {
  return (
    <div className="section-labels" data-test-id="section-labels">
      {items.map((item, index) => {
        const El = item.href ? 'a' : 'div'
        return (
          <El
            key={index}
            href={item.href}
            className="section-labels__item"
            style={{
              backgroundColor: item.color,
              left: `${index * 28}px`
            }}>
            {item.label}
          </El>
        )
      })}
    </div>
  )
}
