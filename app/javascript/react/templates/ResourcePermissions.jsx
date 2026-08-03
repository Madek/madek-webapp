import React, { useState, useEffect, useRef } from 'react'
import { useMutation } from '@tanstack/react-query'
import t from '../../lib/i18n-translate.js'
import url from 'url'
import ResourcePermissionsForm from '../decorators/ResourcePermissionsForm.jsx'
import Modal from '../ui-components/Modal.jsx'
import EditTransferResponsibility from '../views/Shared/EditTransferResponsibility.jsx'
import { savePermissions, applyPermissionCascade } from '../../api/permissions.js'

function ResourcePermissions({ get, optionals, authToken }) {
  const [permissions, setPermissions] = useState(get)
  const [editing, setEditing] = useState(false)
  const [transferModal, setTransferModal] = useState(false)
  const routerRef = useRef(null)
  const editingRef = useRef(false)
  const isLoadingRef = useRef(false)

  editingRef.current = editing

  const mutation = useMutation({
    mutationFn: () => savePermissions(permissions),
    onSuccess: saved => {
      // Reset refs before goTo so confirmNavigation check doesn't block navigation.
      // setEditing(false) is intentionally called AFTER goTo: calling it before would
      // trigger a React 16 synchronous re-render that overwrites isLoadingRef.current
      // back to mutation.isLoading (still true at that point in TanStack Query's
      // callback order), causing listenBefore's check() to see isLoadingRef=true and
      // show a confirm dialog. The router.listen callback will call setEditing(false)
      // anyway when navigation completes.
      editingRef.current = false
      isLoadingRef.current = false
      routerRef.current.goTo((saved && saved.url) || get.url)
      setEditing(false)
    },
    onError: err => {
      alert(
        (() => {
          try {
            return JSON.stringify(err, null, 2)
          } catch {
            return String(err)
          }
        })()
      )
    }
  })

  isLoadingRef.current = mutation.isLoading

  useEffect(() => {
    const router = require('../../lib/router.js').default
    const editUrl = url.parse(get.edit_permissions_url).pathname

    const stopListen = router.listen(location => {
      setEditing(location.pathname === editUrl)
    })

    const stopConfirming = router.confirmNavigation({
      check: () => editingRef.current || isLoadingRef.current
    })

    routerRef.current = router
    router.start()

    return () => {
      stopListen()
      stopConfirming()
    }
  }, [])

  const onStartEdit = event => {
    if (event) event.preventDefault()
    routerRef.current.goTo(event.target.href)
  }

  const onCancelEdit = () => {}

  const onSubmitForm = event => {
    event.preventDefault()
    mutation.mutate()
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
      const newPerm = { subject }
      const template = list[0] || {}
      const applicable = Object.keys(template).filter(k => k !== 'subject' && k !== 'tooltip_text')
      const types = applicable.length > 0 ? applicable : prev.permission_types || []
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

  const GroupIndex = ({ subject }) => (
    <span className="text" title={subject.detailed_name}>
      {subject.can_show ? <a href={subject.url}>{subject.detailed_name}</a> : subject.detailed_name}
    </span>
  )

  return (
    <div>
      {transferModal && (
        <Modal widthInPixel={800}>
          <EditTransferResponsibility
            authToken={authToken}
            batch={false}
            resourceType={get.type}
            singleResourceUrl={get.resource_url}
            singleResourceFallbackUrl={get.fallback_url}
            singleResourcePermissionsUrl={get.permissions_url}
            singleResourceActionUrl={get.update_transfer_responsibility_url}
            batchResourceIds={null}
            responsible={get.responsible}
            onClose={() => setTransferModal(false)}
            currentUser={get.current_user}
          />
        </Modal>
      )}
      <ResourcePermissionsForm
        get={permissions}
        editing={editing}
        saving={mutation.isLoading}
        optionals={optionals}
        onEdit={onStartEdit}
        onSubmit={onSubmitForm}
        onCancel={onCancelEdit}
        editUrl={get.edit_permissions_url}
        decos={{ Groups: GroupIndex }}
        onPermissionChange={onPermissionChange}
        onPublicPermissionChange={onPublicPermissionChange}
        onAddSubject={onAddSubject}
        onRemoveSubject={onRemoveSubject}>
        <PermissionsOverview
          get={permissions}
          openTransferModal={get.can_transfer ? () => setTransferModal(true) : undefined}
        />
        <hr className="separator light mvl" />
        <h3 className="title-l mbs">{t('permissions_table_title')}</h3>
      </ResourcePermissionsForm>
    </div>
  )
}

function PermissionsOverview({ get, openTransferModal }) {
  return (
    <div className="row">
      <h3 className="title-l mbl">{t('permissions_responsibility_title')}</h3>
      <div className="col1of2">
        <div className="ui-info-box">
          <h2 className="ui-rights-user-title mbs" style={{ fontWeight: '700' }}>
            {t('permissions_responsible_user_and_responsibility_group_title')}
          </h2>
          <p className="ui-info-box-intro prm">
            {t('permissions_responsible_user_and_responsibility_group_msg')}
          </p>
          <ul className="inline">
            <li className="person-tag">{get.responsible.name}</li>
          </ul>
          {openTransferModal && (
            <ul className="inline mts">
              <a className="button" onClick={openTransferModal}>
                {t('permissions_transfer_responsibility_link')}
              </a>
            </ul>
          )}
        </div>
      </div>
      {get.current_user && (
        <div className="col1of2">
          <h2 className="ui-rights-user-title mbs" style={{ fontWeight: '700' }}>
            {t('permissions_overview_yours_title')}
          </h2>
          <p className="ui-info-box-intro">
            {t('permissions_overview_yours_msg_start')}
            {get.current_user.name}
            {t('permissions_overview_yours_msg_end')}
          </p>
          <ul className="inline">
            {get.current_user_permissions.map(p => (
              <li key={p}>{t(`permission_name_${p}`)}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}

export default ResourcePermissions
