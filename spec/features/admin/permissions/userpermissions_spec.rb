require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin Userpermissions' do
  let(:media_set) { create(:media_set_with_children) }
  let(:user) { create(:user) }
  before do
    sign_in_as 'adam'
    visit app_admin_media_set_path(media_set)
  end

  scenario 'Adding userpermission to a media set and its children', browser: :firefox do
    click_link 'Add person permission to a set and its children'

    fill_in '[query]', with: user.name
    select_entry_from_autocomplete_list

    check 'userpermission[view]'
    check 'userpermission[download]'
    check 'userpermission[edit]'

    check 'children_media_entries[view]'
    check 'children_media_entries[download]'
    check 'children_media_entries[edit]'

    check 'children_media_sets[view]'
    check 'children_media_sets[download]'
    check 'children_media_sets[edit]'

    click_button 'Create'

    assert_success_message

    check_userpermission_for(media_set, user)
    media_set.child_media_resources.each do |resource|
      check_userpermission_for(resource, user)
    end
  end

  def check_userpermission_for(resource, owner)
    expect(
      Userpermission.find_by(media_resource_id: resource.id,
                             user_id: owner.id,
                             view: true,
                             download: true,
                             edit: true)
    ).not_to be_nil
  end
end
