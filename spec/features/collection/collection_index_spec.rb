require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: Collection' do

  describe 'Action: index' do

    it 'is rendered for public' do
      visit collections_path
      expect(page.status_code).to eq 200
    end

    pending 'shared_test_filterbar'

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit collections_path
      expect(page.status_code).to eq 200
    end

    it 'is filtered with search param' do
      @user = User.find_by(login: 'normin')
      collection = FactoryGirl.create(:collection,
                                      get_metadata_and_previews: true)
      search_string = Faker::Lorem.characters(10)
      FactoryGirl.create(:meta_datum_text,
                         meta_key: MetaKey.find('madek_core:title'),
                         string: search_string,
                         collection: collection)

      sign_in_as @user.login
      visit collections_path(list: { filter: { search: search_string }.to_json })
      expect(page.status_code).to eq 200
      expect(all('.media-set').count).to be == 1
      expect(find('.media-set').text).to match /#{search_string}/
    end

  end

end
