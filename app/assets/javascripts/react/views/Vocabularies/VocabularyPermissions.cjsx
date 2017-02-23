React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../../lib/string-translation.js')('de')
Icon = require('../../ui-components/Icon.cjsx')

VocabularyPage = require('./VocabularyPage.cjsx')

ResourcePermissionsForm = require('../../decorators/ResourcePermissionsForm.cjsx')

module.exports = React.createClass
  displayName: 'VocabularyPermissions'

  render: ({get, for_url} = @props) ->

    GroupIndex = ({subject})-> <span>
      <span className='text mrs'>{subject.detailed_name} </span>
      {!!subject.edit_url &&
        <a className='button small' href={subject.edit_url}>{t('group_edit_btn')}</a>}
    </span>

    <VocabularyPage page={get.page} for_url={for_url}>
      <div className='ui-container pal'>

        <ResourcePermissionsForm
          get={get.permissions}
          editing={false}
          decos={{Groups: GroupIndex}}
          optionals={['Users', 'Groups', 'ApiClients']}>

          <div className='row mbm'>
            <div className='col1of2'>
              <div className='ui-info-box'>
                <p className='paragraph-l'>
                  {t('vocabulary_permissions_hint')}
                </p>
              </div>
            </div>
          </div>


        </ResourcePermissionsForm>

      </div>
    </VocabularyPage>
