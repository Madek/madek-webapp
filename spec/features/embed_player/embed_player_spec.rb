require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

# NOTE: there is also a spec for the oEmbed API!
#       this only tests the HTML output that is served from oEmbed (iframe etc)
feature 'Embed aka. "Madek-Player"', with_db: :test_media do

  context 'video sizing' do

    let(:video_entry) { MediaEntry.find('29b7522c-84eb-4abd-89e0-9285075813ac') }
    VIDEO_CAPTION = 'madek-test-video Madek Team — Public Domain'.freeze

    it 'gives default sizes if no sizes requested' do
      fake_oembed_client(
        url: media_entry_path(video_entry))

      expected_size = { height: 1080 + 55, width: 1920 } # height: source + caption

      expect(displayed_embedded_result)
        .to eq(expected_ui(expected_size, VIDEO_CAPTION))
    end

    it 'scales down heigth and width if requested' do
      # NOTE: same sizes like default wordpress theme (twenty sixteen)
      fake_oembed_client(
        url: media_entry_path(video_entry),
        maxheight: 628,
        maxwidth: 839
      )
      expected_size = { height: 526, width: 839 }

      expect(displayed_embedded_result)
        .to eq(expected_ui(expected_size, VIDEO_CAPTION))
    end

    it 'scales down width and heigth if requested' do
      fake_oembed_client(
        url: media_entry_path(video_entry),
        maxheight: 1200,
        maxwidth: 550
      )
      expected_size = { height: 364, width: 550 }

      expect(displayed_embedded_result)
        .to eq(expected_ui(expected_size, VIDEO_CAPTION))
    end

    it 'does not scale below supported minimum (320x140px)' do
      fake_oembed_client(
        url: media_entry_path(video_entry), maxheight: 1, maxwidth: 1)
      expected_size = { height: 195, width: 320 }

      expect(displayed_embedded_result)
        .to eq(expected_ui(expected_size, VIDEO_CAPTION))
    end

    it 'scales down heigth if requested and sets proportional width' do
      fake_oembed_client(url: media_entry_path(video_entry), maxheight: 420)
      expected_size = { height: 420, width: 648 }

      expect(displayed_embedded_result)
        .to eq(expected_ui(expected_size, VIDEO_CAPTION))
    end

    it 'scales down width if requested and sets proportional heigth' do
      fake_oembed_client(url: media_entry_path(video_entry), maxwidth: 550)
      expected_size = { height: 364, width: 550 }

      expect(displayed_embedded_result)
        .to eq(expected_ui(expected_size, VIDEO_CAPTION))
    end

  end

end

# display oembed result in a page with nothing else so we can do measurements
def fake_oembed_client(params)
  # use browser as api client - just grap the JSON from the body:
  visit oembed_path(params)
  res = JSON.parse(find('body > pre').text)
  html_string = res['html']
  visit 'about:blank' # NOTE: makes sure it works from ANY origin
  execute_script "document.body.style = 'margin:0;padding:0;display:inline-block';"
  execute_script "document.body.innerHTML = '#{html_string}';"
  sleep 3 # let the DOM reticulate its spines
end

def expected_ui(size, caption)
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

def displayed_embedded_result
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
