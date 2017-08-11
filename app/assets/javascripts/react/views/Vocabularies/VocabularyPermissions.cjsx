React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../../lib/i18n-translate.js')
Icon = require('../../ui-components/Icon.cjsx')

VocabularyPage = require('./VocabularyPage.cjsx')

ResourcePermissionsForm = require('../../decorators/ResourcePermissionsForm.cjsx')

module.exports = React.createClass
  displayName: 'VocabularyPermissions'

  render: ({get, for_url} = @props) ->

    hints = [t('vocabulary_permissions_hint1'), t('vocabulary_permissions_hint2')]

    GroupIndex = ({subject}) ->
      <span className='text mrs'>
        {
          if subject.can_show
            <a href={subject.url}>{subject.detailed_name}</a>
          else
            subject.detailed_name
        }
      </span>

    <VocabularyPage page={get.page} for_url={for_url}>
      <div className='ui-container pal'>

        <ResourcePermissionsForm
          get={get.permissions}
          editing={false}
          decos={{Groups: GroupIndex}}
          optionals={['Users', 'Groups', 'ApiClients']}>

          <div className='row'>
            {hints.map((msg, i) ->
              <div className='col1of2'>
                <div className={'ui-info-box '+ ['prm','plm'][i]}>
                  <p className='paragraph-l'>{msg}</p>
                </div>
              </div>
            )}
          </div>

          <hr className='separator light mvm' />

        </ResourcePermissionsForm>

      </div>
    </VocabularyPage>
