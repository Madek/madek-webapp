require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Batch edit media entries' do
  describe 'authorize entries' do

    it 'returns 403 in case of any unauthorized entry' do
      user = FactoryGirl.create :user

      me1 = FactoryGirl.create :media_entry
      me2 = FactoryGirl.create :media_entry

      me1.user_permissions << FactoryGirl.create(:media_entry_user_permission,
                                                 edit_metadata: true,
                                                 user: user)

      sign_in_as user.login, user.password

      visit batch_edit_meta_data_by_context_media_entries_path(id: [me1, me2])

      expect(page).to have_content I18n.t(:error_403_title)
    end
  end
end
