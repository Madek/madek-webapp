require 'spec_helper'
require Rails.root.join 'spec', 'controllers', 'shared', 'filters_spec.rb'

describe CollectionsController do

  context 'index' do
    context 'filters' do
      before :context do
        @user = FactoryGirl.create :user
      end

      let(:model) { Collection }

      it_assigns_according_to 'filter', :responsible do
        let(:user) do
          @user.collections << FactoryGirl.create(:collection)
          @user
        end
      end

      it_assigns_according_to 'filter', :favorite do
        let(:user) do
          @user.favorite_collections << FactoryGirl.create(:collection)
          @user
        end
      end

      it_assigns_according_to 'filter', :entrusted do
        let(:user) do
          FactoryGirl.create \
            :collection_user_permission,
            get_metadata_and_previews: true,
            user: @user,
            collection: FactoryGirl.create(:collection)
          @user
        end
      end
    end
  end
end
