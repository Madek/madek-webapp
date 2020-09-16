require_relative './_shared'

feature 'Embed aka. "Madek-Player"', with_db: :test_media do
  let(:video_entry) { MediaEntry.find('29b7522c-84eb-4abd-89e0-9285075813ac') }
  VIDEO_CAPTION = 'madek-test-video Madek Team — Public Domain'.freeze

  let(:audio_entry) { MediaEntry.find('103034cd-badd-4299-aef0-d414a606d4e5') }
  AUDIO_CAPTION = 'madek-test-audio Madek Team — Public Domain'.freeze

  context 'video player interaction' do
    it 'starts with SD resolution and can change to HD' do
      do_oembed_client(url: media_entry_url(video_entry), maxwidth: 550)
      page.within_frame(page.find('iframe')) do
        play_btn = find('.vjs-big-play-button')
        play_btn.click

        # binding.pry

        within('.vjs-control-bar') do
          res_btn = find('.vjs-resolution-button')
          expect(res_btn.text).to eq 'Quality SD'
          res_btn.click
          hd_btn = res_btn.find('.vjs-menu-content li', text: 'HD')
          hd_btn.click
        end
        find('.vjs-poster').click
        expect(find('.vjs-control-bar .vjs-resolution-button').text).to eq 'Quality HD'
      end
    end
  end
end
