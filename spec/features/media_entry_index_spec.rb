require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MediaEntry' do

  describe 'Action: index' do

    it 'is rendered for public' do
      visit media_entries_path
      expect(page.status_code).to eq 200
    end

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit media_entries_path
      expect(page.status_code).to eq 200
    end

  end

  describe 'Action: favor' do

    it 'favorite button on thumbnail (JS)', browser: :firefox do

      @user = User.find_by(login: 'normin')
      sign_in_as @user.login

      visit media_entries_path

      @entry_id = URI(all('.ui-thumbnail-image-wrapper')[0][:href]).path[9..-1]
      @entry = MediaEntry.find @entry_id

      expect(@entry.favored?(@user)).to eq false

      link = '/entries/' + @entry_id

      clickable = find_button(link)
      clickable.click
      clickable = find_button(link)

      expect(clickable['data-pending']).to eq 'false'

      expect(@entry.favored?(@user)).to eq true

    end

  end

  private

  def find_button(link)
    thumbnail = find(:xpath, "//a[@href='" + link + "']") # <- just the link
                  .find(:xpath, './..[contains(@class, "ui-thumbnail")]')
    thumbnail.hover
    actions = thumbnail.find('.ui-thumbnail-actions')
    actions.hover
    favorite = actions.find('.ui-thumbnail-action-favorite')
    favorite.hover
    favorite
  end

end
