require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MediaEntryPermissionsShared

feature 'Resource: MediaEntry' do
  let(:deactivated_user_string) { I18n.t(:user_name_deactivated) }
  background do
    @user = User.find_by(login: 'normin')
    @responsible_user = FactoryBot.create(:user)
    @entry = FactoryBot.create(:media_entry_with_image_media_file,
                               responsible_user: @responsible_user)
    FactoryBot.create(:media_entry_user_permission, :full,
                      user: @user,
                      media_entry: @entry)

    sign_in_as @user.login
  end

  it 'shows users as deactivated' do
    user = FactoryBot.create(:user)
    FactoryBot.create(
      :media_entry_user_permission, media_entry: @entry, user: user)
    user.update!(active_until: Date.yesterday.to_datetime.end_of_day)

    visit permissions_media_entry_path(@entry)

    expect(
      find('.ui-rights-body', text: 'Nutzer/innen')
        .find('td.ui-rights-user', text: deactivated_user_string)
    ).to be
  end

  it 'shows responsible user as deactivated' do
    @responsible_user.update!(active_until: Date.yesterday.to_datetime.end_of_day)

    visit permissions_media_entry_path(@entry)

    expect(
      find(
        '.ui-info-box',
        text: I18n.t(:permissions_responsible_user_and_responsibility_group_title)
      ).find('.person-tag', text: deactivated_user_string)
    ).to be
  end

end
