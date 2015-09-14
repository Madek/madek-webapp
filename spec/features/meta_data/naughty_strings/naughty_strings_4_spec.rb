require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

def read_and_parse_strings
  JSON.parse \
    File.read \
      "#{Rails.root}/node_modules/big-list-of-naughty-strings/blns.json"
end

feature 'naughty strings 4' do
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

  scenario 'naughty strings 4', browser: :firefox do
    strings = read_and_parse_strings

    strings[151..200].each do |s|
      visit meta_datum_path(@meta_datum)
      click_on 'Edit'
      fill_in 'values_', with: s
      click_on 'Save'

      puts s
      unless Madek::Constants::SPECIAL_WHITESPACE_CHARS.include? s
        expect(find('.app-body', match: :first)).to have_content s
      else
        expect(page.text).to match /Error 4\d\d/
      end
    end
  end

  # TODO: fails on CI
  # scenario 'check if all strings tested' do
  #   strings = read_and_parse_strings
  #   expect(strings.length).to be <= 200
  # end
end
