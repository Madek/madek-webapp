require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MediaEntry' do
  given(:user) { create(:user, password: 'password') }
  given(:media_entry) do
    create(:media_entry_with_image_media_file,
           creator: user, responsible_user: user, is_published: false)
  end
  given(:text_meta_key) { create(:meta_key_text) }
  given(:keywords_meta_key) { create(:meta_key_keywords) }

  background do
    IoInterface.find_or_create_by(id: 'default')
    IoMapping.create!(io_interface_id: 'default',
                      meta_key_id: text_meta_key.id,
                      key_map: 'XMP-dc:Title')
    IoMapping.create!(io_interface_id: 'default',
                      meta_key_id: keywords_meta_key.id,
                      key_map: 'XMP-dc:Subject')
    sign_in_as user.login
  end

  describe 'Action: xmp_import' do

    scenario 'menu item is not shown for a published entry' do
      media_entry.update!(is_published: true)
      visit media_entry_path(media_entry)

      within '.ui-body-title-actions .ui-dropdown' do
        find('a', text: I18n.t(:resource_action_more_actions)).click
        expect(page).to have_no_content(I18n.t(:resource_action_media_entry_xmp_import))
      end
    end

    scenario 'imports and overwrites meta data from a sidecar file' do
      create(:meta_datum_text, media_entry: media_entry,
                               meta_key: text_meta_key, string: 'Old Title')
      keyword_a = create(:keyword, meta_key: keywords_meta_key)
      keyword_b = create(:keyword, meta_key: keywords_meta_key)

      import_xmp(title: 'Sidecar Title', subjects: [keyword_a.id, keyword_b.id])

      expect(page).to have_current_path(media_entry_path(media_entry))
      expect(page).to have_selector('.ui-alert.success', text: text_meta_key.label)
      expect(page).to have_selector('.ui-alert.success', text: keywords_meta_key.label)
      expect(page).to have_no_selector('.ui-alert.warning', text: text_meta_key.label)
      expect(page).to have_no_selector('.ui-alert.warning', text: keywords_meta_key.label)
      expect(page).to have_no_selector('.ui-alert.error')

      media_entry.reload
      expect(media_entry.meta_data.find_by(meta_key: text_meta_key).string)
        .to eq 'Sidecar Title'
      expect(media_entry.meta_data.find_by(meta_key: keywords_meta_key).keywords)
        .to match_array [keyword_a, keyword_b]
    end

    scenario 'reports fields that could not be imported as warning' do
      import_xmp(title: 'Sidecar Title', subjects: ['not-a-keyword'])

      expect(page).to have_selector('.ui-alert.success', text: text_meta_key.label)
      expect(page).to have_selector('.ui-alert.warning', text: keywords_meta_key.label)
      expect(media_entry.reload.meta_data.find_by(meta_key: keywords_meta_key)).to be_nil
    end

    scenario 'reports an error if no field could be imported' do
      import_xmp(subjects: ['not-a-keyword'])

      expect(page).to have_no_selector('.ui-alert.success')
      expect(page).to have_selector('.ui-alert.error', text: keywords_meta_key.label)
    end

    scenario 'reports a sidecar without importable meta data' do
      import_xmp

      expect(page).to have_selector(
        '.ui-alert.warning', text: I18n.t(:media_entry_xmp_import_flash_nothing))
    end

    scenario 'rejects a file without .xmp extension' do
      import_xmp(title: 'Sidecar Title', extension: '.txt')

      expect(page).to have_selector(
        '.ui-alert.error', text: I18n.t(:media_entry_xmp_import_flash_invalid_file))
      expect(media_entry.reload.meta_data.find_by(meta_key: text_meta_key)).to be_nil
    end
  end
end

private

def import_xmp(title: nil, subjects: [], extension: '.xmp')
  sidecar = Rails.root.join('tmp', "sidecar_#{SecureRandom.hex(8)}#{extension}")
  File.write(sidecar, xmp_content(title: title, subjects: subjects))

  visit media_entry_path(media_entry)
  within '.ui-body-title-actions .ui-dropdown' do
    find('a', text: I18n.t(:resource_action_more_actions)).click
    find('a', text: I18n.t(:resource_action_media_entry_xmp_import)).click
  end
  within '.modal' do
    attach_file('xmp_file', sidecar.to_s)
    click_button I18n.t(:media_entry_xmp_import_submit)
  end
ensure
  FileUtils.rm_f(sidecar) if sidecar
end

def xmp_content(title:, subjects:)
  title_xml = title ? "<dc:title><rdf:Alt><rdf:li xml:lang=\"x-default\">#{title}</rdf:li></rdf:Alt></dc:title>" : ''
  subjects_xml = subjects.any? ? "<dc:subject><rdf:Bag>#{subjects.map { |s| "<rdf:li>#{s}</rdf:li>" }.join}</rdf:Bag></dc:subject>" : ''
  <<~XMP
    <?xpacket begin="" id="W5M0MpCehiHzreSzNTczkc9d"?>
    <x:xmpmeta xmlns:x="adobe:ns:meta/">
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
          #{title_xml}
          #{subjects_xml}
        </rdf:Description>
      </rdf:RDF>
    </x:xmpmeta>
    <?xpacket end="w"?>
  XMP
end
