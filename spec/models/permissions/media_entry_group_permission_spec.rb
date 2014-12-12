require 'spec_helper'
require Rails.root.join 'spec', 'models', 'shared', 'destroy_ineffective_permissions_spec.rb'

describe Permissions::MediaEntryGroupPermission do

  it 'is creatable via a factory' do
    expect { FactoryGirl.create :media_entry_group_permission }.not_to raise_error
  end

  context 'Group and MediaEntry ' do

    before :each do
      @group = FactoryGirl.create :group
      @creator = FactoryGirl.create :group
      @media_entry = FactoryGirl.create :media_entry
    end

    describe 'destroy_ineffective' do

      context 'for permission where all permission values are false and group is not the responsible_group' do
        before :each do
          @permission = FactoryGirl.create(:media_entry_group_permission,
                                           get_metadata_and_previews: false,
                                           get_full_size: false,
                                           edit_metadata: false,
                                           group: (FactoryGirl.create :group),
                                           media_entry: @media_entry)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
