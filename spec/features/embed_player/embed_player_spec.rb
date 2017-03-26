require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

# NOTE: there is also a spec for the oEmbed API!
#       this only tests the HTML output that is served from oEmbed (iframe etc)
feature 'Embed aka. "Madek-Player"', with_db: :test_media do

  let(:video_entry) { MediaEntry.find('29b7522c-84eb-4abd-89e0-9285075813ac') }
  VIDEO_CAPTION = 'madek-test-video Madek Team — Public Domain'.freeze

  let(:audio_entry) { MediaEntry.find('103034cd-badd-4299-aef0-d414a606d4e5') }
  AUDIO_CAPTION = 'madek-test-audio Madek Team — Public Domain'.freeze

  context 'video player interaction' do
    # NOTE: tested here because test video is already set up

    it 'starts with SD resolution and can change to HD' do
      do_oembed_client(url: media_entry_path(video_entry), maxwidth: 550)
      page.within_frame(page.find('iframe')) do
        play_btn = find('.vjs-big-play-button')
        play_btn.click

        within('.vjs-control-bar') do
          res_btn = find('.vjs-resolution-button')
          expect(res_btn.text).to eq 'Quality SD'
          res_btn.click
          hd_btn = res_btn.find('.vjs-menu-content li', text: 'HD')
          hd_btn.click
        end
        expect(find('.vjs-control-bar .vjs-resolution-button').text)
          .to eq 'Quality HD'
      end
    end
  end

  context 'video embed with caption and size config' do

    it 'gives default sizes if no sizes requested' do
      do_oembed_client(
        url: media_entry_path(video_entry))

      expected_size = { height: 1080 + 55, width: 1920 } # height: source + caption

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION))
    end

    it 'scales down heigth and width if requested' do
      # NOTE: same sizes like default wordpress theme (twenty sixteen)
      do_oembed_client(
        url: media_entry_path(video_entry),
        maxheight: 628,
        maxwidth: 839
      )
      expected_size = { height: 526, width: 839 }

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION))
    end

    it 'scales down width and heigth if requested' do
      do_oembed_client(
        url: media_entry_path(video_entry),
        maxheight: 1200,
        maxwidth: 550
      )
      expected_size = { height: 364, width: 550 }

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION))
    end

    it 'does not scale below supported minimum (320x140px)' do
      do_oembed_client(
        url: media_entry_path(video_entry), maxheight: 1, maxwidth: 1)
      expected_size = { height: 195, width: 320 }

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION))
    end

    it 'scales down heigth if requested and sets proportional width' do
      do_oembed_client(url: media_entry_path(video_entry), maxheight: 420)
      expected_size = { height: 420, width: 648 }

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION))
    end

    it 'scales down width if requested and sets proportional heigth' do
      do_oembed_client(url: media_entry_path(video_entry), maxwidth: 550)
      expected_size = { height: 364, width: 550 }

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION))
    end

  end

  context 'audio embed with caption and size config' do

    it 'plays without error' do
      do_oembed_client(
        url: media_entry_path(audio_entry)
      )
      page.within_frame(page.find('iframe')) do
        # NOTE: webdriver can't interact with native element, use its JS api:
        execute_script('document.getElementsByTagName("audio")[0].play()')
        sleep 5
      end
    end

    it 'gives default sizes if no sizes requested' do
      do_oembed_client(
        url: media_entry_path(audio_entry)
      )
      expected_size = { height: 200, width: 500 }

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, AUDIO_CAPTION))
    end

    it 'scales down heigth and width if requested' do
      do_oembed_client(
        url: media_entry_path(audio_entry),
        maxheight: 320,
        maxwidth: 400
      )
      expected_size = { height: 195, width: 400 }

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, AUDIO_CAPTION))
    end
  end
end

# display oembed result in a page with nothing else so we can do measurements
def do_oembed_client(params)
  # use browser as api client - just grap the JSON from the body:
  visit oembed_path(params)
  res = JSON.parse(find('body > pre').text)
  html_string = res['html']
  visit 'about:blank' # NOTE: makes sure it works from ANY origin
  execute_script "document.body.style = 'margin:0;padding:0;display:inline-block';"
  execute_script "document.body.innerHTML = '#{html_string}';"
  sleep 3 # let the DOM reticulate its spines
end

def expected_embedded_ui(size, caption)
  {
    iframe_attrs: size,
    body: size,
    embedded: {
      body: size,
      tile: size,
      caption_text: caption
    }
  }
end

def displayed_embedded_ui
  # NOTE: text will be nil if its cut off or otherwise hidden - thats on purpose!
  iframe = find('iframe')
  {
    iframe_attrs: { height: iframe[:height].to_i, width: iframe[:width].to_i },
    body: get_actual_size('document.body'),
    embedded: page.within_frame(iframe) do
      {
        body: get_actual_size('document.body'),
        tile: get_actual_size('document.getElementsByClassName("ui-tile")[0]'),
        caption_text: page.all('.ui-tile .ui-tile__foot')[0].try(:text)
      }
    end
  }.deep_symbolize_keys
end

def get_actual_size(selector)
  evaluate_script <<-JS
    (function(){
      var n = #{selector}
      return n && { height: n.offsetHeight, width: n.offsetWidth }
    }())
  JS
end
