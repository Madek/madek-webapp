require_relative './_shared'

feature 'Embed aka. "Madek-Player"' do
  let :video_entry do
    FactoryBot.create(:embed_test_video_entry)
  end

  context 'video player interaction' do
    it 'starts with SD resolution and can change to HD', ci_group: :embed do
      do_oembed_client(url: media_entry_url(video_entry), maxwidth: 550)
      page.within_frame(page.find('iframe')) do
        play_btn = find('.vjs-big-play-button')
        play_btn.click

        within('.vjs-control-bar') do
          res_btn = find('.vjs-resolution-button')
          expect(res_btn.text).to eq "Quality\nSD"
          res_btn.click
          hd_btn = res_btn.find('.vjs-menu-content li', text: 'HD')
          hd_btn.click
        end
        find('.vjs-tech').click
        expect(find('.vjs-control-bar .vjs-resolution-button').text).to eq "Quality\nHD"
      end
    end
  end
end
