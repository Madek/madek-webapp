import React from 'react'
import t from '../../../lib/i18n-translate.js'
import VocabularyPage from './VocabularyPage.jsx'
import ResourcePermissionsForm from '../../decorators/ResourcePermissionsForm.jsx'

const VocabularyPermissions = ({ get, for_url }) => {
  const hints = [t('vocabulary_permissions_hint1'), t('vocabulary_permissions_hint2')]

  const GroupIndex = ({ subject }) => (
    <span className="text mrs">
      {subject.can_show ? <a href={subject.url}>{subject.detailed_name}</a> : subject.detailed_name}
    </span>
  )

  return (
    <VocabularyPage page={get.page} for_url={for_url}>
      <div className="ui-container pal">
        <ResourcePermissionsForm
          get={get.permissions}
          editing={false}
          decos={{ Groups: GroupIndex }}
          optionals={['Users', 'Groups', 'ApiClients']}>
          <div className="row">
            {hints.map((msg, i) => (
              <div className="col1of2" key={i}>
                <div className={`ui-info-box ${['prm', 'plm'][i]}`}>
                  <p className="paragraph-l">{msg}</p>
                </div>
              </div>
            ))}
          </div>
          <hr className="separator light mvm" />
        </ResourcePermissionsForm>
      </div>
    </VocabularyPage>
  )
}

export default VocabularyPermissions
module.exports = VocabularyPermissions
