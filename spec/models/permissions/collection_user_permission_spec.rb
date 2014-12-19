require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions_spec.rb'

describe Permissions::CollectionUserPermission do

  it 'is creatable via a factory' do
    expect { FactoryGirl.create :collection_user_permission }.not_to raise_error
  end

  context 'User and MediaEntry ' do

    before :each do
      @user = FactoryGirl.create :user
      @creator = FactoryGirl.create :user
      @collection = FactoryGirl.create :collection
    end

    describe 'destroy_ineffective' do

      context ' for permissions where the user is the reponsible_user' do
        before :each do
          @permission = FactoryGirl.create(:collection_user_permission,
                                           get_metadata_and_previews: true,
                                           user: @collection.responsible_user,
                                           collection: @collection)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

      context %(for permission where all permission values are false \
               and user is not the responsible_user) do
        before :each do
          @permission = FactoryGirl.create(:collection_user_permission,
                                           get_metadata_and_previews: false,
                                           edit_metadata_and_relations: false,
                                           user: (FactoryGirl.create :user),
                                           collection: @collection)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
