require 'spec_helper'
require Rails.root.join 'spec', 'controllers', 'shared', 'filters.rb'

describe MediaEntriesController do

  context 'index' do
    context 'filters' do
      before :context do
        @user = FactoryGirl.create :user
      end

      let(:model) { MediaEntry }

      it_assigns_according_to 'filter', :responsible do
        let(:user) do
          @user.media_entries << FactoryGirl.create(:media_entry)
          @user
        end
      end

      it_assigns_according_to 'filter', :imported do
        let(:user) do
          FactoryGirl.create \
            :media_entry,
            responsible_user: FactoryGirl.create(:user),
            creator: @user
          @user
        end
      end

      it_assigns_according_to 'filter', :favorite do
        let(:user) do
          @user.favorite_media_entries << FactoryGirl.create(:media_entry)
          @user
        end
      end

      it_assigns_according_to 'filter', :entrusted do
        let(:user) do
          FactoryGirl.create \
            :media_entry_user_permission,
            get_metadata_and_previews: true,
            user: @user,
            media_entry: FactoryGirl.create(:media_entry)
          @user
        end
      end
    end
  end
end
