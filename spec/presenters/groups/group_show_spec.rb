require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::Groups::GroupShow do

  it '#entrusted_media_resources' do
    user = FactoryBot.create(:user)
    group = FactoryBot.create(:group)
    entry = FactoryBot.create(:media_entry, creator: user, responsible_user: user)
    set = FactoryBot.create(:collection, creator: user, responsible_user: user)

    perms = { get_metadata_and_previews: true, group: group }
    create :media_entry_group_permission, perms.merge(media_entry: entry)
    create :collection_group_permission, perms.merge(collection: set)

    get = described_class.new(group, user, 'entries', {list_conf: {}}, nil)

    expect(get.resources.resources.first.uuid)
      .to eq entry.id

  end


  describe "dump" do

    before :each do
      @user = FactoryBot.create(:user)
      @group = FactoryBot.create(:group)
      3.times { @group.users << FactoryBot.create(:user) }
    end
    let(:presenter) { described_class.new(@group, @user, 'entries', {list_conf: {}}, nil) }

    include_examples 'dumped'

  end


end
