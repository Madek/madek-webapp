import React from 'react'
import f from 'lodash'
import { ConfidentialLinkRow } from './ConfidentialLinks'
import ui from '../../lib/ui.coffee'
import UI from '../../ui-components/index.coffee'
const t = ui.t

class ConfidentialLinkCreated extends React.Component {
  render (props = this.props) {
    const { get } = props
    const justCreated = f.get(get, 'just_created', false)
    const indexAction = f.get(get, 'actions.index.url')
    const title = justCreated ? t('confidential_links_created_title') : t('confidential_links_show_title')

    return (
      <div
        className='by-center'
        style={{ marginLeft: 'auto', marginRight: 'auto' }}
      >
        <div
          className='ui-container bright bordered rounded mal phl pbs'
          style={{ display: 'inline-block' }}
        >
          <h3 className='title-l mas'>
            {title}
          </h3>
          {get.revoked && (
            <h4 className='title-s mas' style={{ color: 'darkred' }}>revoked</h4>
          )}
          <div>
            <p
              className='ui-container bordered rounded mam pas'
              style={{ display: 'inline-block' }}
            >
              <samp className='title-m code b'>{get.secret_url}</samp>
            </p>
          </div>
          <table className='block aligned'>
            <tbody>
              <tr><td /><td /><td /><td /><td /><td /></tr>
              <ConfidentialLinkRow {...get} />
            </tbody>
          </table>
          {!!indexAction && (
            <div className='ui-actions mtm'>
              <UI.Button href={indexAction} className='button'>
                {t('confidential_links_created_back_btn')}
              </UI.Button>
            </div>
          )}
        </div>
      </div>
    )
  }
}

module.exports = ConfidentialLinkCreated
