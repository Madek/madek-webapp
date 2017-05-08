require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::Groups::GroupShow do

  it '#entrusted_media_resources' do
    user = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)
    entry = FactoryGirl.create(:media_entry, creator: user, responsible_user: user)
    set = FactoryGirl.create(:collection, creator: user, responsible_user: user)

    perms = { get_metadata_and_previews: true, group: group }
    create :media_entry_group_permission, perms.merge(media_entry: entry)
    create :collection_group_permission, perms.merge(collection: set)

    get = described_class.new(group, user, 'entries', list_conf: {})

    expect(get.resources.resources.first.uuid)
      .to eq entry.id

  end

  it_can_be 'dumped' do
    user = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)
    3.times { group.users << FactoryGirl.create(:user) }
    let(:presenter) { described_class.new(group, user, 'entries', list_conf: {}) }
  end
end
