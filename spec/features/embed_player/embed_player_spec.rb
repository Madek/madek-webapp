require_relative './_shared'

# NOTE: there is also a spec for the oEmbed API!
#       this only tests the HTML output that is served from oEmbed (iframe etc)
feature 'Embed aka. "Madek-Player"', with_db: :test_media do
  let(:video_entry) { MediaEntry.find('29b7522c-84eb-4abd-89e0-9285075813ac') }
  VIDEO_CAPTION = 'madek-test-video Madek Team — Public Domain'.freeze

  let(:audio_entry) { MediaEntry.find('103034cd-badd-4299-aef0-d414a606d4e5') }
  AUDIO_CAPTION = 'madek-test-audio Madek Team — Public Domain'.freeze

  context 'video embed with size config' do
    it 'gives default sizes if no sizes requested' do
      url = media_entry_path(video_entry)
      expected_size = { height: 360, width: 640 }

      do_oembed_client(url: url)
      expect(displayed_embedded_ui).to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION, url))
    end

    it 'does not scale below supported minimum (345x194px)' do
      url = media_entry_path(video_entry)
      expected_size = { height: 194, width: 345 }

      do_oembed_client(url: url, maxheight: 1, maxwidth: 1)
      expect(displayed_embedded_ui).to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION, url))
    end

    it 'sets width if requested and sets proportional heigth' do
      url = media_entry_path(video_entry)
      expected_size = { height: 281, width: 500 }

      do_oembed_client(url: url, maxwidth: 500)
      expect(displayed_embedded_ui).to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION, url))
    end

    it 'sets width and sets ratio if requested' do
      url = media_entry_path(video_entry)
      expected_size = { height: 600, width: 800 }

      do_oembed_client(url: url, width: 800, ratio: '4:3')
      expect(displayed_embedded_ui).to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION, url))
    end

    it 'works with a ConfidentialLink / accessToken' do
      expected_size = { height: 360, width: 640 }
      entry = video_entry
      entry.update_attributes!(get_metadata_and_previews: false, get_full_size: false)
      sikrit = create(:confidential_link, resource: entry)

      url_without_access_token = media_entry_path(video_entry)
      url_with_access_token = media_entry_path(video_entry, accessToken: sikrit.token)

      do_oembed_client(url: url_with_access_token)
      expect(displayed_embedded_ui).to eq(
        expected_embedded_ui(expected_size, VIDEO_CAPTION, url_without_access_token)
      )
    end
  end

  context 'audio embed with caption and size config' do
    it 'plays without error' do
      do_oembed_client(url: media_entry_path(audio_entry))
      page.within_frame(page.find('iframe')) do
        # NOTE: webdriver can't interact with native element, use its JS api:
        execute_script('document.getElementsByTagName("audio")[0].play()')
        sleep 5
      end
    end

    it 'gives default sizes if no sizes requested' do
      url = media_entry_path(audio_entry)
      expected_size = { height: 360, width: 640 }

      do_oembed_client(url: url)
      expect(displayed_embedded_ui).to eq(expected_embedded_ui(expected_size, AUDIO_CAPTION, url))
    end

    it 'sets width if requested' do
      url = media_entry_path(audio_entry)
      expected_size = { height: 225, width: 400 }

      do_oembed_client(url: url, maxwidth: 400)
      expect(displayed_embedded_ui).to eq(expected_embedded_ui(expected_size, AUDIO_CAPTION, url))
    end

    it 'set width and set ratio if requested' do
      url = media_entry_path(audio_entry)
      expected_size = { height: 400, width: 400 }

      do_oembed_client(url: url, width: 400, ratio: '1:1')

      expect(displayed_embedded_ui).to eq(expected_embedded_ui(expected_size, AUDIO_CAPTION, url))
    end
  end
end
