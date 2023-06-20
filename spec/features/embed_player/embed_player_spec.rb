require_relative './_shared'

# Specs for video and audio player via oembed (see `embed_image_player_spec.rb` for image files)
# For plain tests of the oEmbed discovery and endpoint see `oembed_spec.rb`
feature 'Embed aka. "Madek-Player"', ci_group: :embed  do
  let :video_entry do
    FactoryBot.create(:embed_test_video_entry)
  end
  VIDEO_CAPTION = "madek-test-video\nMadek Team — Public Domain".freeze

  let :audio_entry do
    FactoryBot.create(:embed_test_audio_entry)
  end
  AUDIO_CAPTION = "madek-test-audio\nMadek Team — Public Domain".freeze

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
      entry.update!(get_metadata_and_previews: false, get_full_size: false)
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

  context 'image embed' do
    context 'landscape format, known size (1024 x 709)' do
      let :image_entry do
        FactoryBot.create(:embed_test_image_landscape_entry)
      end
    
      example 'no parameters -> default width' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url)

        within_frame(find('iframe')) do
          expect(page).to have_text "madek-test-image-landscape\nMadek Team — Public Domain"
          expect(get_actual_image_size()).to eq({ 'height' => 443, 'width' => 640 })
          expect(get_actual_body_size()).to eq({ 'height' => 443 + 55, 'width' => 640 })
        end
      end

      example 'maxwidth 400 -> width 400' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 277, 'width' => 400 })
          expect(get_actual_body_size()).to eq({ 'height' => 277 + 55, 'width' => 400 })
        end
      end

      example 'maxwidth 2000 -> width 1024 (avoiding left/right gutter)' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 2000)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 709, 'width' => 1024 })
          expect(get_actual_body_size()).to eq({ 'height' => 709 + 55, 'width' => 1024 })
        end
      end

      example 'maxwidth 1 -> width 1 (no minimum size is enforced)' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 1)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 1, 'width' => 1 })
          expect(get_actual_body_size()).to eq({ 'height' => 1 + 55, 'width' => 1 })
        end
      end

      example 'maxwidth 400, maxheight 400 -> maxheight has no effect' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400, maxheight: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 277, 'width' => 400 })
          expect(get_actual_body_size()).to eq({ 'height' => 277 + 55, 'width' => 400 })
        end
      end
      
      example 'maxwidth 1000, maxheight 400 -> maxheight will be applied' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 1000, maxheight: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 400 - 55, 'width' => 498 })
          expect(get_actual_body_size()).to eq({ 'height' => 400, 'width' => 1000 })
        end
      end
    end

    context 'portrait format, known size (532 x 768)' do
      let :image_entry do
        FactoryBot.create(:embed_test_image_portrait_entry)
      end

      example 'no parameters -> default width, but height constrained to media height' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url)

        within_frame(find('iframe')) do
          expect(page).to have_text "madek-test-image-portrait\nMadek Team — Public Domain"
          expect(get_actual_image_size()).to eq({ 'height' => 768, 'width' => 532 })
          expect(get_actual_body_size()).to eq({ 'height' => 768 + 55, 'width' => 640 })
        end
      end

      example 'maxwidth 400 -> width 400' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 577, 'width' => 400 })
          expect(get_actual_body_size()).to eq({ 'height' => 577 + 55, 'width' => 400 })
        end
      end

      example 'maxwidth 1000 -> width 1000, but height constrained to media height' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 1000)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 768, 'width' => 532 })
          expect(get_actual_body_size()).to eq({ 'height' => 768 + 55, 'width' => 1000 })
        end
      end

      example 'maxwidth 1 -> width 1 (no minimum size is enforced)' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 1)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 1, 'width' => 1 })
          expect(get_actual_body_size()).to eq({ 'height' => 1 + 55, 'width' => 1 })
        end
      end

      example 'maxwidth 400, maxheight 1000 -> maxheight has no effect' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 577, 'width' => 400 })
          expect(get_actual_body_size()).to eq({ 'height' => 577 + 55, 'width' => 400 })
        end
      end
      
      example 'maxwidth 400, maxheight 400 -> height is set to maxheight' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400, maxheight: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 400 - 55, 'width' => 239 })
          expect(get_actual_body_size()).to eq({ 'height' => 400, 'width' => 400 })
        end
      end

      example 'maxheight 400 -> default width, height set to maxheight' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxheight: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 400 - 55, 'width' => 239 })
          expect(get_actual_body_size()).to eq({ 'height' => 400, 'width' => 640 })
        end
      end
    end

    context 'landscape format, unknown size (assumes 1024 x 768)' do
      let :image_entry do
        FactoryBot.create(:embed_test_image_landscape_entry_with_unknown_size)
      end
    
      example 'no parameters -> default width, vertical gutter' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 443, 'width' => 640 })
          expect(get_actual_body_size()).to eq({ 'height' => 480 + 55, 'width' => 640 })
        end
      end

      example 'maxwidth 400 -> width 400' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 277, 'width' => 400 })
          expect(get_actual_body_size()).to eq({ 'height' => 300 + 55, 'width' => 400 })
        end
      end

      example 'maxwidth 2000 -> width 1024 (avoiding left/right gutter)' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 2000)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 709, 'width' => 1024 })
          expect(get_actual_body_size()).to eq({ 'height' => 768 + 55, 'width' => 1024 })
        end
      end

      example 'maxwidth 1 -> width 1 (no minimum size is enforced)' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 1)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 1, 'width' => 1 })
          expect(get_actual_body_size()).to eq({ 'height' => 1 + 55, 'width' => 1 })
        end
      end

      example 'maxwidth 400, maxheight 400 -> maxheight has no effect' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400, maxheight: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 277, 'width' => 400 })
          expect(get_actual_body_size()).to eq({ 'height' => 300 + 55, 'width' => 400 })
        end
      end
      
      example 'maxwidth 1000, maxheight 400 -> maxheight will be applied' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 1000, maxheight: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 400 - 55, 'width' => 498 })
          expect(get_actual_body_size()).to eq({ 'height' => 400, 'width' => 1000 })
        end
      end
    end

    context 'portrait format, unknown size (assumes 1024 x 768)' do
      let :image_entry do
        FactoryBot.create(:embed_test_image_portrait_entry_with_unknown_size)
      end
    
      example 'no parameters -> default width, but height constrained to media height' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 480, 'width' => 333 })
          expect(get_actual_body_size()).to eq({ 'height' => 480 + 55, 'width' => 640 })
        end
      end

      example 'maxwidth 400 -> width 400' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 300, 'width' => 208 })
          expect(get_actual_body_size()).to eq({ 'height' => 300 + 55, 'width' => 400 })
        end
      end

      example 'maxwidth 1000 -> width 1000, but height constrained to media height' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 1000)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 750, 'width' => 520 })
          expect(get_actual_body_size()).to eq({ 'height' => 750 + 55, 'width' => 1000 })
        end
      end

      example 'maxwidth 1 -> width 1 (no minimum size is enforced)' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 1)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 1, 'width' => 1 })
          expect(get_actual_body_size()).to eq({ 'height' => 1 + 55, 'width' => 1 })
        end
      end

      example 'maxwidth 400, maxheight 1000 -> maxheight has no effect' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 300, 'width' => 208 })
          expect(get_actual_body_size()).to eq({ 'height' => 300 + 55, 'width' => 400 })
        end
      end
      
      example 'maxwidth 400, maxheight 400 -> height is set to maxheight' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxwidth: 400, maxheight: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 300, 'width' => 208 })
          expect(get_actual_body_size()).to eq({ 'height' => 300 + 55, 'width' => 400 })
        end
      end

      example 'maxheight 400 -> default width, height set to maxheight' do
        url = media_entry_path(image_entry)
        do_oembed_client(url: url, maxheight: 400)

        within_frame(find('iframe')) do
          expect(get_actual_image_size()).to eq({ 'height' => 345, 'width' => 239 })
          expect(get_actual_body_size()).to eq({ 'height' => 345 + 55, 'width' => 640 })
        end
      end
    end
  end
end
