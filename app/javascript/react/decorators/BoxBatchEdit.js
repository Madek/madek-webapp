import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import BoxBatchTextInput from './BoxBatchTextInput.js'
import BoxBatchTextDateInput from './BoxBatchTextDateInput.js'
import BoxBatchKeywords from './BoxBatchKeywords.js'
import BoxBatchPeople from './BoxBatchPeople.js'
import BoxBatchLoadMetaMetaData from './BoxBatchLoadMetaMetaData.js'
import BoxRedux from './BoxRedux.js'
import BoxStateApplyMetaData from './BoxStateApplyMetaData.js'
import BoxBatchEditInvalids from './BoxBatchEditInvalids.js'


module.exports = (merged) => {

  let {event, trigger, initial, components, data, nextProps, path} = merged

  var cachedAllMetaKeysById = null

  var next = () => {
    return {
      props: nextProps,
      path: path,
      data: {
        open: nextOpen(),
        invalidMetaKeyUuids: nextInvalidMetaKeyUuids(),
        applyFormData: nextApplyFormData(),
        applyJob: nextApplyJob()
      },
      components: {
        loadMetaMetaData: nextLoadMetaMetaData(),
        metaKeyForms: nextMetaKeyForms()
      }
    }
  }

  var nextApplyJob = () => {

    if(initial) {
      return null
    }

    if(!nextProps.willStartApply && !data.applyJob) {
      return null
    }


    var job = data.applyJob


    var anyFormEvent = () => {
      return l.find(
        components.metaKeyForms,
        (mkf) => mkf.event.action
      ) || event.action == 'select-key'
    }

    if(anyFormEvent() && job.processing.length == 0 && job.failure.length == 0 && !nextProps.willStartApply) {
      return null
    }


    if(nextProps.ignoreAll && job.processing.length == 0 && job.pending.length == 0 && !nextProps.willStartApply) {
      return null
    }

    var maxParallel = (() => {
      if(!job) {
        return 1
      }
      // The first update is sent isolated (not in parallel), because we need the first
      // to create the not existing keywords. Otherwise several will try to create them
      // in parallel resulting in not unique exceptions.
      var hasDone = job.success.length > 0 || event.action == 'apply-success'
      if(!hasDone) {
        return 1
      } else {
        return 12
      }
    })()

    var formData = (() => {
      if(nextProps.willStartApply) {
        return l.map(
          components.metaKeyForms,
          (mkf) => {
            return {
              data: mkf.data,
              props: mkf.props
            }
          }
        )
      } else {
        return job.formData
      }
    })()

    var ongoing = (() => {
      if(nextProps.willStartApply) {
        return []
      } else {
        return l.reject(
          job.processing,
          (p) => (event.action == 'apply-success' || event.action == 'apply-failure') && event.resourceId == p.uuid
        )
      }
    })()

    var success = (() => {
      if(nextProps.willStartApply) {
        return []
      } else {
        return l.concat(
          job.success,
          l.filter(
            job.processing,
            (p) => event.action == 'apply-success' && event.resourceId == p.uuid
          )
        )
      }
    })()

    var failure = (() => {
      if(nextProps.willStartApply) {
        return []
      } else {
        return l.concat(
          l.reject(
            job.failure,
            (f) => l.find(nextProps.retryResources, (r) => f.uuid == r.uuid)
          ),
          l.filter(
            job.processing,
            (p) => event.action == 'apply-failure' && event.resourceId == p.uuid
          )
        )
      }
    })()

    var cancelled = (() => {
      if(nextProps.willStartApply) {
        return []
      } else if(nextProps.cancelAll) {
        return job.pending
      } else {
        return job.cancelled
      }
    })()

    var toLoad = (() => {
      if(nextProps.willStartApply) {
        return l.slice(nextProps.applyResources, 0, maxParallel)
      } else if(nextProps.cancelAll) {
        return []
      } else {
        return l.slice(
          l.concat(
            job.pending,
            nextProps.retryResources
          ),
          0,
          maxParallel - ongoing.length
        )
      }
    })()


    var pending = (() => {
      if(nextProps.willStartApply) {
        return l.slice(nextProps.applyResources, maxParallel)
      } else if(nextProps.cancelAll) {
        return []
      } else {
        return l.reject(
          l.concat(
            job.pending,
            nextProps.retryResources
          ),
          (p) => l.find(toLoad, (r) => r.uuid == p.uuid)
        )
      }
    })()

    var processing = (() => {
      return l.concat(toLoad, ongoing)
    })()


    BoxStateApplyMetaData(
      merged,
      toLoad,
      formData,
      trigger
    )

    // if(processing.length == 0 && failure.length == 0) {
    //   return null
    // }

    return {
      formData: formData,
      pending: pending,
      processing: processing,
      success: success,
      failure: failure,
      cancelled: cancelled
    }


  }


  var nextApplyFormData = () => {

    if(initial) {
      return null
    }

    if(nextProps.willStartApply) {
      return l.map(
        components.metaKeyForms,
        (mkf) => {
          return {
            data: mkf.data,
            props: mkf.props
          }
        }
      )
    } else {
      return data.applyFormData
    }
  }

  var nextInvalidMetaKeyUuids = () => {
    if(initial) {
      return []
    }
    else {

      var invalidUuids = () => {
        return l.map(BoxBatchEditInvalids(merged), (i) => i.props.metaKey.uuid)
      }

      var formsWithClose = () => {
        return l.filter(
          components.metaKeyForms,
          (mkf) => mkf.event.action == 'close'
        )

      }

      var anyCloseAction = () => {
        return !l.isEmpty(formsWithClose())
      }

      var rejectClosed = () => {
        return l.reject(
          data.invalidMetaKeyUuids,
          (id) => l.find(formsWithClose(), (f) => {
            return f.props.metaKeyId == id
          })
        )
      }


      if(initial) {
        return []
      }
      else if(nextProps.anyApplyAction) {
        return invalidUuids()
      }
      else if(anyCloseAction()) {
        return rejectClosed()
      }
      else {
        return null
      }
    }

  }


  var nextLoadMetaMetaData = () => {

    var props = {
      mount: nextProps.mount
    }

    return BoxBatchLoadMetaMetaData(
      {
        event: (initial ? {} : components.loadMetaMetaData.event),
        trigger: trigger,
        initial: initial,
        components: (initial ? {} : components.loadMetaMetaData.components),
        data: (initial ? {} : components.loadMetaMetaData.data),
        nextProps: props,
        path: l.concat(path, ['loadMetaMetaData'])
      }
    )
  }

  var nextMetaKeyForms = () => {

    if(initial) {
      return []
    }

    var findMetaKeyForm = (metaKeyId) => {
      return l.find(components.metaKeyForms, (f) => f.props.metaKeyId == event.metaKeyId)
    }

    var allMetaKeysById = () => {
      if(!cachedAllMetaKeysById) {
        cachedAllMetaKeysById = l.fromPairs(
          l.flatten(
            l.map(
              components.loadMetaMetaData.data.metaMetaData,
              (mmd) => l.map(
                mmd.data.meta_key_by_meta_key_id,
                (m, k) => [k, m]
              )
            )
          )
        )
      }
      return cachedAllMetaKeysById
    }

    var mandatoryForTypes = (metaKeyId) => {

      return l.map(
        l.filter(
          components.loadMetaMetaData.data.metaMetaData,
          (mmd) => l.includes(l.keys(mmd.data.mandatory_by_meta_key_id), metaKeyId)
        ),
        (mmd) => mmd.type
      )
    }


    var findMetaKey = (metaKeyId) => {
      return allMetaKeysById()[metaKeyId]
    }

    var withoutClosed = () => {
      return l.filter(
        components.metaKeyForms,
        (f) => f.event.action != 'close'
      )
    }

    var reuseMetaKeyForm = (metaKeyForm, componentId, metaKeyId, contextKey, index) => {

      var props = {
        metaKeyId: metaKeyId,
        metaKey: findMetaKey(metaKeyId),
        contextKey: contextKey,
        mandatoryForTypes: mandatoryForTypes(metaKeyId),
        invalid: l.includes(nextInvalidMetaKeyUuids(), metaKeyId)
      }

      return decideComponents(metaKeyId)(
        {
          event: metaKeyForm.event,
          trigger: trigger,
          initial: false,
          components: metaKeyForm.components,
          data: metaKeyForm.data,
          nextProps: props,
          path: ['batch', ['metaKeyForms', index]]
        }
      )
    }

    var newMetaKeyForm = (componentId, metaKeyId, contextKey, index) => {

      var props = {
        metaKeyId: metaKeyId,
        metaKey: findMetaKey(metaKeyId),
        contextKey: contextKey,
        mandatoryForTypes: mandatoryForTypes(metaKeyId),
        invalid: l.includes(nextInvalidMetaKeyUuids(), metaKeyId)
      }

      return decideComponents(metaKeyId)(
        {
          event: {},
          trigger: trigger,
          initial: true,
          components: {},
          data: {},
          nextProps: props,
          path: ['batch', ['metaKeyForms', index]]
        }
      )
    }

    var mapExisting = () => {
      return l.map(
        withoutClosed(),
        (c, i) => reuseMetaKeyForm(c, c.id, c.props.metaKeyId, c.props.contextKey, i)
      )
    }

    var decideComponents = (metaKeyId) => {
      var mapping = {
        'MetaDatum::Text': BoxBatchTextInput,
        'MetaDatum::TextDate': BoxBatchTextDateInput,
        'MetaDatum::Keywords': BoxBatchKeywords,
        'MetaDatum::People': BoxBatchPeople
      }
      var type = findMetaKey(metaKeyId).value_type
      if(!mapping[type]) throw 'not implemented for ' + type
      return mapping[type]
    }

    if(event.action == 'select-key' && !findMetaKeyForm(event.metaKeyId)) {
      var existing = mapExisting()
      return l.concat(
        existing,
        newMetaKeyForm(null, event.metaKeyId, event.contextKey, existing.length)
      )
    } else {
      return mapExisting()
    }
  }

  var nextOpen = () => {
    if(initial) {
      return false
    }

    if(event.action == 'toggle') {
      if(!data.open) {
        return true
      } else {
        return false
      }
    } else {
      return data.open
    }
  }




  return next()
}
