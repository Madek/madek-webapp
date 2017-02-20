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

    <VocabularyPage page={get.page} for_url={for_url}>
      <div className='ui-container pal'>

        <ResourcePermissionsForm
          get={get.permissions}
          editing={false}
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
