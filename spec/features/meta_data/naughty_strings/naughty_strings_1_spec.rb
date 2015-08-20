require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'naughty strings 1', browser: :firefox do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user
    meta_key = FactoryGirl.create :meta_key_text, id: 'media_content:test'
    @meta_datum = FactoryGirl.create :meta_datum_text,
                                     meta_key: meta_key,
                                     media_entry: @media_entry
  end

  scenario 'naughty strings 1' do
    strings = \
      JSON.parse \
        File.read \
          "#{Rails.root}/node_modules/big-list-of-naughty-strings/blns.json"

    strings[0..50].each do |s|
      visit meta_datum_path(@meta_datum)
      click_on 'Edit'
      fill_in '_value_content_', with: s
      click_on 'Save'

      puts s
      unless Madek::Constants::SPECIAL_WHITESPACE_CHARS.include? s
        expect(find('.app-body', match: :first)).to have_content s
      else
        expect(page.text).to match /Error 4\d\d/
      end
    end
  end
end
