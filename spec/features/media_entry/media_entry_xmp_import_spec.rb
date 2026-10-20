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
  given(:people_meta_key) { create(:meta_key_people) }

  background do
    IoInterface.find_or_create_by(id: 'default')
    IoMapping.create!(io_interface_id: 'default',
                      meta_key_id: text_meta_key.id,
                      key_map: 'XMP-dc:Title')
    IoMapping.create!(io_interface_id: 'default',
                      meta_key_id: keywords_meta_key.id,
                      key_map: 'XMP-dc:Subject')
    IoMapping.create!(io_interface_id: 'default',
                      meta_key_id: people_meta_key.id,
                      key_map: 'XMP-dc:Creator')
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

    scenario 'stores the sidecar and shows it in usage data' do
      import_xmp(title: 'Sidecar Title', subjects: ['not-a-keyword'])

      sidecar = media_entry.xmp_sidecars.first
      expect(sidecar.user).to eq user
      expect(sidecar.xml).to include 'Sidecar Title'
      expect(sidecar.meta_data['XMP-dc:Title']).to eq 'Sidecar Title'
      expect(sidecar.meta_data.keys).not_to include 'SourceFile'
      expect(sidecar.meta_data.keys).to all(satisfy { |k| !k.start_with?('System:') })

      visit usage_data_media_entry_path(media_entry)
      expect(page).to have_content I18n.t(:media_entry_xmp_sidecars_title)
      expect(page).to have_content 'not-a-keyword'
    end

    scenario 'imports people from an XMP array' do
      person_a = create(:person)
      person_b = create(:person)

      import_xmp(creators: [person_a.id, person_b.id])

      expect(page).to have_selector('.ui-alert.success', text: people_meta_key.label)
      expect(media_entry.reload.meta_data.find_by(meta_key: people_meta_key).people)
        .to match_array [person_a, person_b]
    end

    scenario 'reports references to non-existent keywords and people as warning' do
      import_xmp(title: 'Sidecar Title',
                 subjects: [SecureRandom.uuid],
                 creators: [SecureRandom.uuid])

      expect(page).to have_selector('.ui-alert.success', text: text_meta_key.label)
      expect(page).to have_selector('.ui-alert.warning', text: keywords_meta_key.label)
      expect(page).to have_selector('.ui-alert.warning', text: people_meta_key.label)
      media_entry.reload
      expect(media_entry.meta_data.find_by(meta_key: text_meta_key).string)
        .to eq 'Sidecar Title'
      expect(media_entry.meta_data.find_by(meta_key: keywords_meta_key)).to be_nil
      expect(media_entry.meta_data.find_by(meta_key: people_meta_key)).to be_nil
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

    [['an empty file', ''],
     ['a binary file', "\x00\xFF\x00garbage".b],
     ['a text file', 'just some text'],
     ['an XMP file containing a NUL byte', "<x:xmpmeta xmlns:x=\"adobe:ns:meta/\"/>\x00"],
     ['a truncated XMP file',
      '<x:xmpmeta xmlns:x="adobe:ns:meta/"><rdf:RDF ' \
      'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"><rdf:Description>']]
      .each do |description, content|
        scenario "reports #{description} as unreadable" do
          import_xmp(content: content)

          expect(page).to have_selector(
            '.ui-alert.error', text: I18n.t(:media_entry_xmp_import_flash_unreadable).strip)
          expect(media_entry.xmp_sidecars).to be_empty
        end
      end
  end
end

private

def import_xmp(title: nil, subjects: [], creators: [], extension: '.xmp', content: nil)
  sidecar = Rails.root.join('tmp', "sidecar_#{SecureRandom.hex(8)}#{extension}")
  File.binwrite(sidecar, content || xmp_content(title: title, subjects: subjects, creators: creators))

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

def xmp_content(title:, subjects:, creators:)
  title_xml = title ? "<dc:title><rdf:Alt><rdf:li xml:lang=\"x-default\">#{title}</rdf:li></rdf:Alt></dc:title>" : ''
  subjects_xml = subjects.any? ? "<dc:subject><rdf:Bag>#{subjects.map { |s| "<rdf:li>#{s}</rdf:li>" }.join}</rdf:Bag></dc:subject>" : ''
  creators_xml = creators.any? ? "<dc:creator><rdf:Seq>#{creators.map { |c| "<rdf:li>#{c}</rdf:li>" }.join}</rdf:Seq></dc:creator>" : ''
  <<~XMP
    <?xpacket begin="" id="W5M0MpCehiHzreSzNTczkc9d"?>
    <x:xmpmeta xmlns:x="adobe:ns:meta/">
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
          #{title_xml}
          #{subjects_xml}
          #{creators_xml}
        </rdf:Description>
      </rdf:RDF>
    </x:xmpmeta>
    <?xpacket end="w"?>
  XMP
end
