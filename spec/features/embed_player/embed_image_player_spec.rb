require_relative './_shared'

feature 'Embed image player', ci_group: :embed do

  let :image_landscape_entry do
    FactoryBot.create(:embed_test_image_landscape_entry)
  end

  let :image_portrait_entry do
    FactoryBot.create(:embed_test_image_portrait_entry)
  end

  context 'basic render tests' do
    it 'landscape image renders' do
      url = media_entry_path(image_landscape_entry)
      expected_size = { 'height' => 360, 'width' => 640 }

      do_oembed_client(url: url)

      within_frame(find('iframe')) do
        expect(page).to have_text "madek-test-image-landscape\nMadek Team — Public Domain"
        size = get_actual_size('document.body')
        expect(size).to eq expected_size
      end
    end

    it 'portrait image renders' do
      url = media_entry_path(image_portrait_entry)
      expected_size = { 'height' => 360, 'width' => 640 }

      do_oembed_client(url: url)

      within_frame(find('iframe')) do
        expect(page).to have_text "madek-test-image-portrait\nMadek Team — Public Domain"
        size = get_actual_size('document.body')
        expect(size).to eq expected_size
      end
    end
  end
end
