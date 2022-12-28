require_relative './_shared'

# NOTE: there is also a spec for the oEmbed API!
#       this only tests the HTML output that is served from oEmbed (iframe etc)
feature 'Embed aka. "Madek-Player"' do
  let :video_entry do
    FactoryGirl.create(:embed_test_video_entry)
  end
  VIDEO_EMBED_CAPTION = 'madek-test-video Madek Team — Public Domain'.freeze

  let(:the_support_url) { 'https://madek.example.com/help' }

  context 'error messages' do
    before do
      set_base_url
      AppSetting.first.update_attributes!(support_urls: { de: the_support_url })
    end

    it 'shows error when not found' do
      do_manual_embed(embedded_media_entry_url(id: 'does-not-exist'))
      expect(displayed_embed_error_ui).to eq(
        title: 'Fehler!',
        details: {
          reason: 'Der gewünschte Inhalt konnte nicht gefunden werden.',
          context: "Angeforderte URL: #{absolute_external_url('/entries/does-not-exist')}",
          help: "Hilfe: #{the_support_url}"
        }
      )
    end

    it 'shows error when embed not supported' do
      entry =
        create(
          :media_entry_with_other_media_file,
          get_metadata_and_previews: true, get_full_size: true
        )
      do_manual_embed(embedded_media_entry_url(entry))
      expect(displayed_embed_error_ui).to eq(
        title: 'Fehler!',
        details: {
          reason: 'Dieser Inhalt kann nicht eingebettet werden.',
          context: "Angeforderte URL: #{absolute_external_url(media_entry_url(entry))}",
          help: "Hilfe: #{the_support_url}"
        }
      )
    end

    it 'shows error when permissions are missing (non-public entry)' do
      entry = video_entry
      entry.update_attributes!(get_metadata_and_previews: false, get_full_size: false)
      do_manual_embed(embedded_media_entry_url(entry))
      expect(displayed_embed_error_ui).to eq(
        title: 'Fehler!',
        details: {
          reason:
            'Dieser Inhalt kann nicht eingebettet werden, weil die nötigen Berechtigungen fehlen.',
          context: "Angeforderte URL: #{absolute_external_url(media_entry_url(entry))}",
          help: "Hilfe: #{the_support_url}"
        }
      )
    end

    it 'shows error when permissions are missing (expired ConfidentialLink)' do
      entry = video_entry
      entry.update_attributes!(get_metadata_and_previews: false, get_full_size: false)
      sikrit = create(
        :confidential_link, resource: entry, expires_at: DateTime.now.utc - 1.second)

      do_manual_embed(embedded_media_entry_url(entry, accessToken: sikrit.token))
      expect(displayed_embed_error_ui).to eq(
        title: 'Fehler!',
        details: {
          reason:
            'Dieser Inhalt kann nicht eingebettet werden, weil die nötigen Berechtigungen fehlen.',
          context: "Angeforderte URL: #{absolute_external_url(media_entry_url(entry))}",
          help: "Hilfe: #{the_support_url}"
        }
      )
    end
  end
end
