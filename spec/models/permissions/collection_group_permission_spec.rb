require 'spec_helper'
require Rails.root.join 'spec', 'models', 'shared', 'destroy_ineffective_permissions_spec.rb'

describe Permissions::CollectionGroupPermission do

  it 'is creatable via a factory' do
    expect { FactoryGirl.create :collection_group_permission }.not_to raise_error
  end

  context 'Group and Collection ' do

    before :each do
      @group = FactoryGirl.create :group
      @creator = FactoryGirl.create :group
      @collection = FactoryGirl.create :collection
    end

    describe 'destroy_ineffective' do

      context 'for permission where all permission values are false and group is not the responsible_group' do
        before :each do
          @permission = FactoryGirl.create(:collection_group_permission,
                                           get_metadata_and_previews: false,
                                           edit_metadata_and_relations: false,
                                           group: (FactoryGirl.create :group),
                                           collection: @collection)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
