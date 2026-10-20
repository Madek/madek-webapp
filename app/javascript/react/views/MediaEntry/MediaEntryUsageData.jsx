import React from 'react'
import cx from 'classnames'
import t from '../../../lib/i18n-translate.js'
import UsageData from '../../decorators/UsageData.jsx'

const MediaEntryUsageData = ({ get, for_url, authToken }) => {
  const list = get.more_data.file_information
  const sidecars = get.more_data.xmp_sidecars

  return [
    <UsageData key="usage_data" get={get} for_url={for_url} authToken={authToken} />,
    <div key="file_information" className="col2of3">
      <h3 className="title-l separated mbm">{t('media_entry_file_information_title')}</h3>
      <div>{list ? <MetaDataTable list={list} /> : undefined}</div>
      {sidecars && sidecars.length > 0 && (
        <div>
          <h3 className="title-l separated mtl mbm">{t('media_entry_xmp_sidecars_title')}</h3>
          {sidecars.map(sidecar => (
            <div key={sidecar.uuid} className="mbm">
              <h4 className="title-m mbs">
                {[sidecar.filename, sidecar.import_date, sidecar.user && sidecar.user.name]
                  .filter(Boolean)
                  .join(' · ')}
              </h4>
              <MetaDataTable list={sidecar.meta_data} />
            </div>
          ))}
        </div>
      )}
    </div>
  ]
}

const MetaDataTable = ({ list }) => (
  <div className="ui-metadata-box">
    <table className="borderless">
      <tbody>
        {list
          .map(item => {
            const key = item[0]
            const value = item[1]
            const mod = item[2]
            if (value) {
              return (
                <tr key={key}>
                  <td className="ui-summary-label">{key}</td>
                  <td className={cx('ui-summary-content', mod)}>{value}</td>
                </tr>
              )
            }
            return null
          })
          .filter(Boolean)}
      </tbody>
    </table>
  </div>
)

export default MediaEntryUsageData
