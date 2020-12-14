require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MediaEntry' do
  describe 'Action: browse similiar entries ("Stöbern")' do

    let(:public_entry) { MediaEntry.find('cb655264-6fa5-4a7e-bfbe-8f1404ee6323') }
    let(:public_entry_browse_ui) do
      [
        {
          text: 'Schlagworte AudioinstallationKlang' + \
            I18n.t(:browse_entries_filter_link),
          entries: [
            '1cda2f1e-38f2-4005-85dd-156d3cd21af7',
            '3754fd64-032d-4887-ab5c-87eada4a3fd4'] },
        {
          text: 'Genre Punk Rock' + I18n.t(:browse_entries_filter_link),
          entries: [
            '0f144311-b782-4f24-b6ab-2b3ad654bf7a',
            '89dabb6a-ef39-433b-a5e7-90e2a05e078f'] }]
    end

    it 'works for public' do
      visit media_entry_path public_entry
      within_browse_list { expect(browse_list_ui).to eq public_entry_browse_ui }
    end

    it 'has stand-alone view/action' do
      visit browse_media_entry_path public_entry
      within_browse_list { expect(browse_list_ui).to eq public_entry_browse_ui }
    end

    it 'works for user' do
      entry = MediaEntry.find('5ea71900-3379-4ad7-85c6-ea4c31d6d06c')
      sign_in_as :normin
      visit media_entry_path entry
      within_browse_list do
        expect(browse_list_ui).to eq [
          {
            text: 'Gattung KunstSchlagworte Installation' + \
              I18n.t(:browse_entries_filter_link),
            entries:           [
              '36b18184-8a7c-4447-a972-4529a0245236',
              '3bef7d31-e018-4785-9194-0531c0459fce']
          },
          {
            text: 'Gattung Kunst' + I18n.t(:browse_entries_filter_link),
            entries: [
              '104768d8-9a36-4d00-bbd7-bcca12bbec6e',
              '1cda2f1e-38f2-4005-85dd-156d3cd21af7',
              '29950f7c-8a2d-41d9-b45c-3ccd5ffa5890',
              '2a4cdd11-2a7d-4664-8c21-749a42add454',
              '3754fd64-032d-4887-ab5c-87eada4a3fd4',
              '4854a4fc-5c4b-4b01-bcdd-edc779d967ef',
              '5702528a-ac3f-4c8f-a658-a5f829b8a9a6',
              '9f497fe1-a331-485a-8a25-32ccdf24d2d8',
              'ac5f52d3-53e3-4c51-8f82-d2de8504f550',
              'c8be5b85-d481-4a57-bc38-81200aeb979e'] }]
      end
    end

    it 'show message if nothing found' do
      entry = MediaEntry.find('0d744145-53b0-4933-8ad7-783e213d858c')
      visit media_entry_path entry

      within_browse_list do
        expect(page).to have_content I18n.t(:no_content_fallback)
      end
    end

    it 'has no-JS fallback', browser: :firefox_nojs do
      entry = MediaEntry.find('cb655264-6fa5-4a7e-bfbe-8f1404ee6323')
      visit media_entry_path entry
      fallback_link = find('a', text: I18n.t(:browse_entries_title))
      href = URI.parse(fallback_link[:href])
      expect(href.path).to eq browse_media_entry_path entry
    end

    it 'works when ignored_keyword_keys_for_browsing setting is NULL' do
      allow_any_instance_of(AppSetting)
        .to receive(:ignored_keyword_keys_for_browsing).and_return(nil)

      visit media_entry_path public_entry
      within_browse_list { expect(page).to be } # just checks that it doesn't throw
    end

  end

end

private

def within_browse_list
  selector = '[data-ui-entry-browse-list]'
  wait_until(10) { all(selector).any? }
  within('[data-ui-entry-browse-list]') do
    yield
  end
end

def browse_list_ui_entries(row)
  row.find('.ui-featured-entries-list').all('li a.ui-featured-entry').map do |a|
    a[:href].split('/').last
  end.sort
end

def browse_list_ui
  all('.ui-container.pbm').map do |row|
    {
      text: row.text,
      entries: browse_list_ui_entries(row)
    }
  end
end
