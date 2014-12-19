require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions_spec.rb'

describe Permissions::FilterSetUserPermission do

  it 'is creatable via a factory' do
    expect { FactoryGirl.create :filter_set_user_permission }.not_to raise_error
  end

  context 'User and FilterSet ' do

    before :each do
      @user = FactoryGirl.create :user
      @creator = FactoryGirl.create :user
      @filter_set = FactoryGirl.create :filter_set
    end

    describe 'destroy_ineffective' do

      context 'for permissions where the user is the reponsible_user' do
        before :each do
          @permission = FactoryGirl.create(:filter_set_user_permission,
                                           get_metadata_and_previews: true,
                                           user: @filter_set.responsible_user,
                                           filter_set: @filter_set)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

      context %(for permission where all permission values are false \
                and user is not the responsible_user) do
        before :each do
          @permission = FactoryGirl.create(:filter_set_user_permission,
                                           get_metadata_and_previews: false,
                                           edit_metadata_and_filter: false,
                                           edit_permissions: false,
                                           user: (FactoryGirl.create :user),
                                           filter_set: @filter_set)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
