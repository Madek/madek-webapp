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

  context 'video embed with size config' do

    it 'gives default sizes if no sizes requested' do
      url = media_entry_path(video_entry)
      expected_size = { height: 360, width: 640 }

      do_oembed_client(url: url)
      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION, url))
    end

    it 'does not scale below supported minimum (345x194px)' do
      url = media_entry_path(video_entry)
      expected_size = { height: 194, width: 345 }

      do_oembed_client(url: url, maxheight: 1, maxwidth: 1)
      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION, url))
    end

    it 'sets width if requested and sets proportional heigth' do
      url = media_entry_path(video_entry)
      expected_size = { height: 281, width: 500 }

      do_oembed_client(url: url, maxwidth: 500)
      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION, url))
    end

    it 'sets width and sets ratio if requested' do
      url = media_entry_path(video_entry)
      expected_size = { height: 600, width: 800 }

      do_oembed_client(url: url, width: 800, ratio: '4:3')
      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, VIDEO_CAPTION, url))
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
      url = media_entry_path(audio_entry)
      expected_size = { height: 360, width: 640 }

      do_oembed_client(url: url)
      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, AUDIO_CAPTION, url))
    end

    it 'sets width if requested' do
      url = media_entry_path(audio_entry)
      expected_size = { height: 225, width: 400 }

      do_oembed_client(url: url, maxwidth: 400)
      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, AUDIO_CAPTION, url))
    end

    it 'set width and set ratio if requested' do
      url = media_entry_path(audio_entry)
      expected_size = { height: 400, width: 400 }

      do_oembed_client(url: url, width: 400, ratio: '1:1')

      expect(displayed_embedded_ui)
        .to eq(expected_embedded_ui(expected_size, AUDIO_CAPTION, url))
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

def expected_embedded_ui(size, caption, link)
  {
    iframe_attrs: size,
    body: size,
    embedded: {
      body: size,
      caption_text: caption,
      caption_link: URI.parse(Settings.madek_external_base_url).merge(link).to_s
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
      titlebar = page.all('.vjs-titlebar')[0]
      caption = titlebar.all('.vjs-titlebar-caption')[0]
      {
        body: get_actual_size('document.body'),
        caption_text: caption.try(:text),
        caption_link: titlebar[:href]
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
