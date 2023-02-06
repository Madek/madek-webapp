require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaEntries::MediaEntryPermissions do
  it_can_be 'dumped' do
    user = FactoryBot.create(:user)
    media_entry = FactoryBot.create(:media_entry,
                                     responsible_user: user)
    media_entry.user_permissions << \
      FactoryBot.create(:media_entry_user_permission)
    media_entry.group_permissions << \
      FactoryBot.create(:media_entry_group_permission)
    media_entry.api_client_permissions << \
      FactoryBot.create(:media_entry_api_client_permission)

    let(:presenter) { described_class.new(media_entry, user) }
  end
end
