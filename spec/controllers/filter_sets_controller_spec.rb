require 'spec_helper'
require Rails.root.join 'spec', 'controllers', 'shared', 'filters_spec.rb'

describe FilterSetsController do

  context 'index' do
    context 'filters' do
      before :context do
        @user = FactoryGirl.create :user
      end

      let(:model) { FilterSet }

      it_assigns_according_to 'filter', :responsible do
        let(:user) do
          @user.filter_sets << FactoryGirl.create(:filter_set)
          @user
        end
      end

      it_assigns_according_to 'filter', :favorite do
        let(:user) do
          @user.favorite_filter_sets << FactoryGirl.create(:filter_set)
          @user
        end
      end

      it_assigns_according_to 'filter', :entrusted do
        let(:user) do
          FactoryGirl.create \
            :filter_set_user_permission,
            get_metadata_and_previews: true,
            user: @user,
            filter_set: FactoryGirl.create(:filter_set)
          @user
        end
      end
    end
  end
end
