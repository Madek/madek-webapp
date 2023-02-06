require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/basic_data_helper_spec'
require_relative '../shared/meta_data_helper_spec'
include BasicDataHelper
include MetaDataHelper

feature 'Resource: MediaEntry' do
  describe 'Previews on Detail view' do
    let(:user) { User.find_by(login: 'normin') }

    example 'Image: shows "large" image preview and links to "largest" image' do
      entry = FactoryBot.create(
        :media_entry_with_image_media_file,
        get_metadata_and_previews: true)

      # NOTE: factory image is not large enough to determine 'largest', check all:
      large_preview = preview_path(
        entry.media_file.previews.where(thumbnail: :large).first)
      largest_preview = entry.media_file.previews.reorder(width: :DESC).first
      largest_previews = entry.media_file.previews
        .where(width: largest_preview.width)
        .map { |p| preview_path(p) + '.jpg' }

      visit media_entry_path(entry)

      preview = page.find('.ui-media-overview-preview')
      preview_link = preview.find('a:not(.ui-magnifier)')
      preview_img = preview_link.find('img')

      expect(URI.parse(preview_img[:src]).path).to eq(large_preview + '.jpg')
      expect(largest_previews) # see above
        .to include(URI.parse(preview_link[:href]).path)
    end

    example 'PDF: shows image preview and links to (original) PDF' do
      # NOTE: need to use Personas DB as there is no factory with a real PDF!

      # entry = FactoryBot.create(
      #   :media_entry_with_document_media_file,
      #   get_metadata_and_previews: true,
      #   get_full_size: true)
      entry = MediaEntry.find('c50bc33d-626b-43ac-b297-8725ac8a152b')
      entry.update!(get_full_size: true)

      large_preview = preview_path(
        entry.media_file.previews.where(thumbnail: :large).first)
      original_file = media_file_path(entry.media_file)

      visit media_entry_path(entry)

      preview = page.find('.ui-media-overview-preview')
      preview_link = preview.find('a')
      preview_img = preview_link.find('img')

      expect(URI.parse(preview_img[:src]).path).to eq(large_preview + '.jpg')
      expect(URI.parse(preview_link[:href]).path).to eq(original_file)
    end

    context 'when accessed with confidential links' do
      ['audio', 'video'].each do |type|
        example "#{type.capitalize}: shows iframe which gets accessToken param" do
          prepare_entry_and_token(type)

          visit show_by_confidential_link_media_entry_path(
            @entry,
            @token)

          within '.ui-media-overview-preview' do
            iframe = find 'iframe'
            query_params = Rack::Utils.parse_query(URI.parse(iframe[:src]).query)

            expect(query_params['accessToken']).to eq @token
          end
        end
      end
    end

    context 'Iframe embedded' do
      let(:expected_selector) do
        '[data-react-class="UI.Views.MediaEntry.MediaEntryEmbedded"]'
      end

      before do
        allow_any_instance_of(MediaEntriesController)
          .to receive(:embed_whitelisted?)
          .and_return(true)
      end

      ['audio'].each do |type|
        context 'when accessToken as param is given' do
          scenario 'it works' do
            prepare_entry_and_token(type)

            visit embedded_media_entry_path(@entry, accessToken: @token)

            expect(page).to have_selector(expected_selector)
          end
        end

        context 'when accessToken as param is not given' do
          scenario 'it does not work' do
            prepare_entry_and_token(type)

            visit embedded_media_entry_path(@entry)

            expect(page).to have_no_selector(expected_selector)
          end
        end

        context 'when accessToken as param is incorrect' do
          scenario 'it does not work' do
            prepare_entry_and_token(type)

            visit embedded_media_entry_path(@entry, accessToken: @token + 'x')

            expect(page).to have_no_selector(expected_selector)
          end
        end
      end
    end
  end

end

def prepare_entry_and_token(media_type)
  @entry = create(
    "media_entry_with_#{media_type}_media_file",
    responsible_user: user)

  @token = create(
    :confidential_link,
    user: user,
    resource: @entry).token

  create(
    :zencoder_job,
    state: 'finished',
    media_file: @entry.media_file)

  create(
    :preview,
    content_type: @entry.media_file.content_type,
    media_file: @entry.media_file)
end
