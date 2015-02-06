require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Collections#show' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end

  scenario 'is rendered with title and responsible user' do
    # TODO: dynamically get it?
    id = 'd316b369-6d20-4eb8-b76a-c83f1a4c2682'
    @collection = Collection.find(id)
    expect(@collection.id).to be

    # TODO: visit collections_path(@collection)
    visit "/collections/#{@collection.id}"
    expect(page).to have_content 'Normin Normalo'
    expect(page).to have_content 'Konzepte'
  end

end
