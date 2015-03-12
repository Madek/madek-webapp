require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Collections' do
  let(:admin_user) { create :admin_user, password: 'password' }
  before { sign_in_as admin_user.login }

  scenario 'Filtering by collection name' do
    visit '/admin/collections'
    fill_in 'search_terms', with: 'zhdk'
    click_button 'Apply'
    names = all('table tbody tr').map do |tr|
      expect(tr.find('th:first').text.downcase).to have_content 'zhdk'
    end
    expect(find_field('search_terms')[:value]).to eq 'zhdk'
    expect(names).to eq names.sort
  end

  scenario 'linking to Meta Datums list' do
    collection = Collection.first
    visit admin_collection_path(collection)

    expect(page).to have_content collection.title

    click_link "Meta Datums: #{collection.meta_data.count}"

    expect(current_path).to eq admin_meta_datums_path
    expect(page).to have_field('search_term', with: collection.id)
    expect(page).to have_select('search_by', selected: 'Collection ID')
    expect(page).to have_content "Meta Datums (#{collection.meta_data.count})"
  end
end
