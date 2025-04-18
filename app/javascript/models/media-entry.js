/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'active-lodash'
import { File as BrowserFile } from 'global/window'
import app from 'ampersand-app'
import AppResource from './shared/app-resource.js'
import Permissions from './media-entry/permissions.js'
import Person from './person.js'
import t from '../lib/i18n-translate'
import getMediaType from './shared/get-media-type.js'
import MetaData from './meta-data.js'
import ResourceWithRelations from './concerns/resource-with-relations.js'
import Favoritable from './concerns/resource-favoritable.js'
import Deletable from './concerns/resource-deletable.js'

module.exports = AppResource.extend(
  ResourceWithRelations,
  Favoritable,
  Deletable,
  // ,
  // ResourceWithListMetadata,
  {
    type: 'MediaEntry',
    urlRoot: '/entries',
    // NOTE: this allows some session-like props on presenters for simplicity:
    extraProperties: 'allow',
    props: {
      title: {
        type: 'string',
        required: true
      },
      description: ['string'],
      'published?': {
        type: 'boolean',
        default: false,
        required: true
      },
      copyright_notice: ['string'],
      portrayed_object_date: ['string'],
      image_url: {
        type: 'string',
        required: false
      },
      privacy_status: {
        type: 'string',
        required: true,
        default: 'private'
      },
      keywords: ['array'],
      more_data: ['object'],
      media_file: ['object']
    },

    children: {
      permissions: Permissions,
      responsible: Person
    },

    collections: {
      meta_data: MetaData
    },

    session: {
      uploading: 'object'
    },

    derived: {
      // mediaType either from (media_file) presenter or uploading file:
      mediaType: {
        deps: ['media_file', 'uploading'],
        fn() {
          const contentType =
            f.presence(f.get(this.media_file, 'content_type')) ||
            f.presence(f.get(this.uploading, 'file.type'))
          return getMediaType(contentType)
        }
      },

      // NOTE: we don't allow batch-editing of "currently invalid" entries
      isBatchEditable: {
        deps: ['editable', 'invalid_meta_data'],
        fn() {
          return this.editable && !this.invalid_meta_data
        }
      },

      uploadStatus: {
        deps: ['uploading'],
        fn() {
          if (!this.uploading) {
            return
          }
          const filename = f.get(this, 'uploading.file.name')
          const state = (() => {
            switch (false) {
              case !this.uploading.error:
                return t('media_entry_media_import_box_upload_status_error')
              case !!this.uploading.progress:
                return t('media_entry_media_import_box_upload_status_waiting')
              case !(this.uploading.progress < 100):
                return (
                  t('media_entry_media_import_box_upload_status_progress_a') +
                  `${this.uploading.progress === -1 ? '??' : this.uploading.progress.toFixed(2)}` +
                  t('media_entry_media_import_box_upload_status_progress_b')
                )
              default:
                return t('media_entry_media_import_box_upload_status_processing')
            }
          })()
          return [filename, state]
        }
      }
    },

    upload(callback) {
      if (!(this.uploading.file instanceof BrowserFile)) {
        throw new Error('Model: MediaEntry: #upload called but no file!')
      }

      const formData = new FormData()
      formData.append('media_entry[media_file]', this.uploading.file)
      if (this.uploading.workflowId) {
        formData.append('media_entry[workflow_id]', this.uploading.workflowId)
      }
      if (
        f.has(this.uploading, 'copyMdFrom.id') &&
        f.has(this.uploading, 'copyMdFrom.configuration')
      ) {
        formData.append('media_entry[copy_md_from][id]', this.uploading.copyMdFrom.id)
        formData.append(
          'media_entry[copy_md_from][configuration]',
          JSON.stringify(this.uploading.copyMdFrom.configuration)
        )
      }

      this.merge('uploading', { started: new Date().getTime() })

      // listen to progress if supported by XHR:
      const handleOnProgress = param => {
        let progress
        if (param == null) {
          param = event
        }
        const { loaded, total } = param
        try {
          progress = (loaded / total) * 100
        } catch (error) {
          // Why the log? see https://github.com/Madek/Madek/issues/669
          // eslint-disable-next-line no-console
          console.error('Could not calculate percentage for loaded/total:', loaded, total, error)
          progress = -1
        }
        return this.merge('uploading', { progress })
      }

      return this._runRequest(
        {
          method: 'POST',
          url: app.config.relativeUrlRoot + '/entries/',
          body: formData,
          beforeSend(xhrObject) {
            return (xhrObject.upload.onprogress = handleOnProgress)
          }
        },
        (err, res) => {
          // handle error
          let error
          if (err || !res || res.statusCode >= 400) {
            if (err) {
              error = err
            } else if (res) {
              // Why the log? see above
              // eslint-disable-next-line no-console
              console.error(`Response status code = ${res.statusCode}`)
              error = res.body
            } else {
              error = 'Error: no response data'
            }
            // Why the log? see above
            // eslint-disable-next-line no-console
            console.log('Date', Date())
            this.set('uploading', f.merge(this.uploading, { error }))
          } else {
            // or update self with server response:
            const attrs = (() => {
              try {
                return JSON.parse(res.body)
                // eslint-disable-next-line no-unused-vars
              } catch (e) {
                // silently ignore
              }
            })()
            if (attrs) {
              this.set(attrs)
            }
            this.unset('uploading')
          }

          // pass through to callback if given:
          if (f.isFunction(callback)) {
            return callback(error || null, res)
          }
        }
      )
    }
  }
)
