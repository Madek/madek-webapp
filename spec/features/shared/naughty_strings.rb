require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

description = <<-DOC
Test well-known "problem-causing" strings as value for MetaDatumText,
from UI (form input) to DB to UI (view).
See <https://github.com/minimaxir/big-list-of-naughty-strings>
DOC

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_handles_properly, 'handles properly'
end

RSpec.shared_examples '"naughty strings"' do |range|
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

  describe description do

  scenario "(items: #{range})" do
    strings = \
      JSON.parse \
        File.read \
          "#{Rails.root}/spec/_support/naughty_strings/blns-reduced.json"

    strings[range].each do |s|
      visit meta_datum_path(@meta_datum)
      click_on I18n.t(:meta_data_action_edit_btn)
      fill_in 'values_', with: s
      click_on I18n.t(:meta_data_form_save)

      puts s
      unless s.blank? or s.match Madek::Constants::VALUE_WITH_ONLY_WHITESPACE_REGEXP
        expect(find('.app-body', match: :first)).to have_content s
      else
        expect(page.text).to match /Error 4\d\d/
      end

      click_on I18n.t(:sitemap_search)
      fill_in 'search', with: s
      click_on I18n.t(:search_btn_search)
      expect(page.text).not_to match /Error 5\d\d/
    end
  end
  end
end
