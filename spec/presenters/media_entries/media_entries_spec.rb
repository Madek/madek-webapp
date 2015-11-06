require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaEntries::MediaEntries do
  it_can_be 'dumped' do
    let(:presenter) do
      described_class.new(
        MediaEntry.unscoped, FactoryGirl.create(:user), list_conf: {})
    end
  end

  it 'page 1 per default' do
    p = described_class.new(
      MediaEntry.unscoped, FactoryGirl.create(:user), list_conf: {})
    expect(p.resources.count).to be <= 12
  end

  context 'visibility' do
    it 'public permission' do
      user = FactoryGirl.create(:user)

      media_entry_1 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: true)
      media_entry_2 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      p = described_class.new(
        MediaEntry.where(id: [media_entry_1.id, media_entry_2.id]),
        user, list_conf: {})

      expect(p.resources.count).to be == 1
      expect(p.resources.map(&:uuid)).to include media_entry_1.id
    end

    it 'user permission' do
      user = FactoryGirl.create(:user)

      media_entry_1 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      FactoryGirl.create(:media_entry_user_permission,
                         media_entry: media_entry_1,
                         user: user,
                         get_metadata_and_previews: true)

      p = described_class.new(
        MediaEntry.where(id: [media_entry_1.id, media_entry_2.id]),
        user, list_conf: {})

      expect(p.resources.count).to be == 1
      expect(p.resources.map(&:uuid)).to include media_entry_1.id
    end

    it 'group permission' do
      user = FactoryGirl.create(:user)

      media_entry_1 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      group = FactoryGirl.create(:group)
      user.groups << group

      FactoryGirl.create(:media_entry_user_permission,
                         media_entry: media_entry_1,
                         user: user,
                         get_metadata_and_previews: true)

      p = described_class.new(
        MediaEntry.where(id: [media_entry_1.id, media_entry_2.id]),
        user,
        list_conf: {})

      expect(p.resources.count).to be == 1
      expect(p.resources.map(&:uuid)).to include media_entry_1.id
    end

    it 'responsible user' do
      user = FactoryGirl.create(:user)

      media_entry_1 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: user,
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      p = described_class.new(
        MediaEntry.where(id: [media_entry_1.id, media_entry_2.id]),
        user,
        list_conf: {})

      expect(p.resources.count).to be == 1
      expect(p.resources.map(&:uuid)).to include media_entry_1.id
    end
  end
end
