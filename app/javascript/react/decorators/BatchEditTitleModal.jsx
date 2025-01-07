import React, { Component } from 'react'
import Modal from '../ui-components/Modal.jsx'
import RailsForm from '../lib/forms/rails-form.jsx'
import FormButton from '../ui-components/FormButton.jsx'
import xhr from 'xhr'
import qs from 'qs'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import t from '../../lib/i18n-translate.js'

const endPointUrl = '/batch_edit_title'

class BatchEditTitleModal extends Component {
  constructor(props) {
    super(props)
    this.state = {
      loading: true,
      errorMessage: undefined,
      mediaEntries: []
    }
    this._isMounted = false
  }

  componentDidMount() {
    this._isMounted = true
    const { resourceIds, returnTo } = this.props
    const requestData = {
      resource_id: resourceIds,
      return_to: returnTo
    }
    const body = qs.stringify(requestData, { arrayFormat: 'brackets' })
    xhr(
      {
        url: endPointUrl,
        method: 'POST',
        body: body,
        headers: {
          Accept: 'application/json',
          'Content-type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, json) => {
        if (err || res.statusCode !== 200) {
          this.setState({ loading: false, errorMessage: 'Error fetching data' })
        } else {
          if (this._isMounted) {
            const resultData = JSON.parse(json)
            this.setState({
              loading: false,
              mediaEntries: resultData.media_entries
            })
          }
        }
      }
    )
  }

  componentWillUnmount() {
    this._isMounted = false
  }

  _onCancel(event) {
    if (this.props.onClose) {
      event.preventDefault()
      this.props.onClose()
      return false
    } else {
      return true
    }
  }

  _onChangeTitle(value, id) {
    this.setState({
      ...this.state,
      mediaEntries: this.state.mediaEntries.map(entry =>
        id === entry.id ? { ...entry, title: value } : entry
      )
    })
  }

  render() {
    const { authToken, returnTo, resourceIds } = this.props
    const { loading, errorMessage, mediaEntries } = this.state
    const submitUrl = endPointUrl
    return (
      <Modal widthInPixel="800">
        <RailsForm name="batch_edit_title" action={submitUrl} method="put" authToken={authToken}>
          <div className="ui-modal-head">
            <a
              href={returnTo}
              onClick={e => this._onCancel(e)}
              className="ui-modal-close"
              data-dismiss="modal"
              title="Close"
              type="button"
              style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
              <i className="icon-close"></i>
            </a>
            <h3 className="title-l">{t('batch_edit_title_title')}</h3>
          </div>

          <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
            {/* Hidden data */}
            <input type="hidden" name="return_to" value={returnTo} />
            {resourceIds.map(resource_id => [
              <input
                key={'resource_id_' + resource_id.uuid}
                type="hidden"
                name="resource_id[][uuid]"
                value={resource_id.uuid}
              />,
              <input
                key={'resource_id_' + resource_id.type}
                type="hidden"
                name="resource_id[][type]"
                value={resource_id.type}
              />
            ])}

            {errorMessage && <div className="error ui-alert">{errorMessage}</div>}
            {loading && <div>Loading...</div>}
            {!loading && !errorMessage && (
              <table className="ui-table" style={{ width: '100%' }}>
                <thead>
                  <tr>
                    <th></th>
                    <th className="phs">{t('batch_edit_title_th_filename')}</th>
                    <th>{t('batch_edit_title_th_title')}</th>
                  </tr>
                </thead>
                <tbody>
                  {mediaEntries.map(entry => (
                    <tr key={entry.id}>
                      <td style={{ width: '40px' }}>
                        <img
                          className="ui-thumbnail micro"
                          style={{ margin: 0 }}
                          src={entry.image_url}
                        />
                      </td>
                      <td className="phs" style={{ width: '40%', maxWidth: '250px' }}>
                        <div style={{ wordWrap: 'break-word' }}>{entry.file_name}</div>
                      </td>
                      <td style={{ width: '60%' }}>
                        <input
                          type="text"
                          className="block"
                          style={{ margin: 0 }}
                          name={`titles[${entry.id}]`}
                          value={entry.title}
                          required
                          onChange={e => this._onChangeTitle(e.target.value, entry.id)}
                        />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>

          <div className="ui-modal-footer">
            <div className="ui-actions">
              <a
                href={returnTo}
                onClick={e => this._onCancel(e)}
                className="link weak"
                data-dismiss="modal">
                {t('batch_edit_title_cancel')}
              </a>
              {!loading && !errorMessage && <FormButton text={t('batch_edit_title_save')} />}
            </div>
          </div>
        </RailsForm>
      </Modal>
    )
  }
}

export default BatchEditTitleModal
