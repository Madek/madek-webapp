require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './media_entry/permissions/_shared'
include MediaEntryPermissionsShared

feature 'Users' do
  background do
    @user = User.find_by(login: 'normin')
    @another_user = User.find_by(login: 'norbert')
    @entry = FactoryGirl.create(:media_entry_with_image_media_file,
                                responsible_user: @user)
  end

  scenario 'show deactivated user as Gelöschter User' do
    sign_in_as @user.login
    open_permission_editable

    expect(page).not_to have_content(I18n.t(:user_name_deactivated))

    test_perm = permission_types[0]

    add_subject_with_permission(@node_people, 'Norbert', test_perm)

    @node_form.click_on(I18n.t(:permissions_table_save_btn))
    @entry.reload

    expect(current_path).to eq permissions_media_entry_path(@entry)
    expect(page).to have_content(@another_user.person.to_s)

    deactivate_user(@another_user)

    page.evaluate_script('window.location.reload()')

    expect(page).to have_content(I18n.t(:user_name_deactivated))
    expect(page).not_to have_content(@another_user.person.to_s)
  end

  def deactivate_user(user)
    user.update_attribute(:is_deactivated, true)
  end
end
