import React from 'react'
import f from 'lodash'
import classList from 'classnames'
import { parse as parseUrl } from 'url'
import qs from 'qs'
import t from '../../../lib/i18n-translate'
import UI from '../../ui-components/index.coffee'

const MediaResourcesLine = ({ children, resources }) =>
  <div className='ui-container pbm'>
    <div className='ui-container'>
      {children && <div className='mbm'>{children}</div>}
      <div className='ui-featured-entries small active'>
        <ul className='ui-featured-entries-list'>
          {f.map(resources, ({ uuid, url, title, image_url, media_type }) =>
            <li key={uuid} className='ui-featured-entries-item'>
              <a
                className={classList('ui-featured-entry', {[`is-${media_type}`]: !!media_type})}
                href={url}
                title={title}
              >
                <img src={image_url} />
              </a>
              <ul className='ui-featured-entry-actions'>
                <li className='ui-featured-entry-action'>
                  <a
                    className='block'
                    href={makeBrowseUrl(url)}
                    title={t('browse_entries_browse_link_title')}
                  >
                    <UI.Icon i='eye' />
                  </a>
                </li>
              </ul>
            </li>
          )}
        </ul>
      </div>
    </div>
    <hr className='separator' />
  </div>

export default MediaResourcesLine

const makeBrowseUrl = (url) => {
  const parsedUrl = parseUrl(url)
  const params = qs.parse(parsedUrl.query)
  return parsedUrl.pathname.replace(/\/*$/, '') + '/browse?' + qs.stringify(params);
}
