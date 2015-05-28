require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin Grouppermissions' do
  let(:media_set) { create(:media_set_with_children) }
  let(:group) { create(:group) }
  before do
    sign_in_as 'adam'
    visit app_admin_media_set_path(media_set)
  end

  scenario 'Adding grouppermission to a media set and its children', browser: :firefox do
    click_link 'Add group permission to a set and its children'

    fill_in '[query]', with: group.name
    select_entry_from_autocomplete_list

    check 'grouppermission[view]'
    check 'grouppermission[download]'
    check 'grouppermission[edit]'

    check 'children_media_entries[view]'
    check 'children_media_entries[download]'
    check 'children_media_entries[edit]'

    check 'children_media_sets[view]'
    check 'children_media_sets[download]'
    check 'children_media_sets[edit]'

    click_button 'Create'

    assert_success_message

    check_grouppermission_for(media_set, group)
    media_set.child_media_resources.each do |resource|
      check_grouppermission_for(resource, group)
    end
  end

  def check_grouppermission_for(resource, owner)
    expect(
      Grouppermission.find_by(media_resource_id: resource.id,
                             group_id: owner.id,
                             view: true,
                             download: true,
                             edit: true)
    ).not_to be_nil
  end
end
