require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaEntries::MediaEntryPermissionsShow do
  it_can_be 'dumped' do
    user = FactoryGirl.create(:user)
    media_entry = FactoryGirl.create(:media_entry,
                                     responsible_user: user)
    media_entry.user_permissions << \
      FactoryGirl.create(:media_entry_user_permission)
    media_entry.group_permissions << \
      FactoryGirl.create(:media_entry_group_permission)
    media_entry.api_client_permissions << \
      FactoryGirl.create(:media_entry_api_client_permission)

    let(:presenter) { described_class.new(media_entry, user) }
  end
end
