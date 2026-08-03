import React, { useState } from 'react'
import PropTypes from 'prop-types'
import { useMutation } from '@tanstack/react-query'
import { t } from '../../lib/ui.js'
import ResourcePermissionsForm from '../../decorators/ResourcePermissionsForm.jsx'
import Preloader from '../../ui-components/Preloader.jsx'
import ResourcesBatchBox from '../../decorators/ResourcesBatchBox.jsx'
import TabContent from '../../views/TabContent.jsx'
import PageContent from '../../views/PageContent.jsx'
import PageContentHeader from '../../views/PageContentHeader.jsx'
import {
  buildBatchPermissionsState,
  saveBatchPermissions,
  applyPermissionCascade
} from '../../../api/permissions.js'

function BatchResourcePermissions({ get, authToken }) {
  const [permissions, setPermissions] = useState(() => buildBatchPermissionsState(get))

  const mutation = useMutation({
    mutationFn: () => saveBatchPermissions(permissions, get.actions.save, get.actions.cancel.url),
    onSuccess: body => {
      if (body && body.forward_url) {
        window.location = body.forward_url
      } else {
        alert('Error: no forward_url in response')
      }
    },
    onError: (err, _, statusCode) => {
      alert(`Error ${statusCode || ''}!`)
      console.error(err)
    }
  })

  const onSubmit = event => {
    event.preventDefault()
    mutation.mutate()
  }

  const onCancel = event => {
    event.preventDefault()
    window.location = get.actions.cancel.url
  }

  const onPermissionChange = (collectionKey, subjectUuid, permissionTypes, name, value) => {
    setPermissions(prev => ({
      ...prev,
      [collectionKey]: prev[collectionKey].map(p =>
        p.subject && p.subject.uuid === subjectUuid
          ? applyPermissionCascade(p, permissionTypes, name, value)
          : p
      )
    }))
  }

  const onPublicPermissionChange = (permissionTypes, name, value) => {
    setPermissions(prev => ({
      ...prev,
      public_permission: applyPermissionCascade(
        prev.public_permission,
        permissionTypes,
        name,
        value
      )
    }))
  }

  const onAddSubject = (collectionKey, subject) => {
    setPermissions(prev => {
      const list = prev[collectionKey]
      if (list.some(p => p.subject && p.subject.uuid === subject.uuid)) return prev
      // Derive which permission types apply to this collection by inspecting
      // an existing entry (groups omit edit_permissions, api_clients omit more).
      // Fall back to all permission_types when the list is empty.
      const newPerm = { subject }
      const template = list[0] || {}
      const applicable = Object.keys(template).filter(k => k !== 'subject' && k !== 'tooltip_text')
      const types = applicable.length > 0 ? applicable : prev.permission_types
      types.forEach(pt => {
        newPerm[pt] = false
      })
      return { ...prev, [collectionKey]: [...list, newPerm] }
    })
  }

  const onRemoveSubject = (collectionKey, subjectUuid) => {
    setPermissions(prev => ({
      ...prev,
      [collectionKey]: prev[collectionKey].filter(
        p => !(p.subject && p.subject.uuid === subjectUuid)
      )
    }))
  }

  const pageTitle =
    t('permissions_batch_title_pre') + get.batch_length + t('permissions_batch_title_post')

  return (
    <PageContent>
      <PageContentHeader icon="pen" title={pageTitle} />
      <ResourcesBatchBox
        batchCount={get.batch_length}
        resources={get.batch_resources.resources}
        authToken={authToken}
      />
      <TabContent>
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          {mutation.isLoading && !permissions ? (
            <Preloader />
          ) : (
            <ResourcePermissionsForm
              editing={true}
              get={permissions}
              saving={mutation.isLoading}
              onSubmit={onSubmit}
              onCancel={onCancel}
              onPermissionChange={onPermissionChange}
              onPublicPermissionChange={onPublicPermissionChange}
              onAddSubject={onAddSubject}
              onRemoveSubject={onRemoveSubject}
            />
          )}
        </div>
      </TabContent>
    </PageContent>
  )
}

BatchResourcePermissions.propTypes = {
  get: PropTypes.shape({
    batch_permissions: PropTypes.array.isRequired,
    batch_length: PropTypes.number,
    batch_resources: PropTypes.shape({
      resources: PropTypes.array.isRequired
    }),
    actions: PropTypes.shape({
      save: PropTypes.shape({
        url: PropTypes.string.isRequired,
        method: PropTypes.string.isRequired
      }),
      cancel: PropTypes.shape({ url: PropTypes.string.isRequired })
    })
  }).isRequired,
  authToken: PropTypes.string.isRequired
}

export default BatchResourcePermissions
