require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MediaEntryPermissionsShared

feature 'Resource: MediaEntry' do
  let(:deactivated_user_string) { I18n.t(:user_name_deactivated) }
  background do
    @user = User.find_by(login: 'normin')
    @entry = FactoryGirl.create(:media_entry_with_image_media_file,
                                responsible_user: @user)

    sign_in_as @user.login
  end

  it 'shows users as deactivated' do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(
      :media_entry_user_permission, media_entry: @entry, user: user)
    user.update_attributes!(is_deactivated: true)

    visit permissions_media_entry_path(@entry)

    expect(
      find('.ui-rights-body', text: 'Nutzer/innen')
        .find('td.ui-rights-user', text: deactivated_user_string)
    ).to be
  end

  it 'shows responsible user as deactivated' do
    user = @entry.responsible_user
    user.update_attributes!(is_deactivated: true)

    visit permissions_media_entry_path(@entry)

    expect(
      find(
        '.ui-info-box',
        text: I18n.t(:permissions_responsible_user_and_responsibility_group_title)
      ).find('.person-tag', text: deactivated_user_string)
    ).to be
  end

end
