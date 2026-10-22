require 'spec_helper'

describe PreviewsController do
  let(:entry) { FactoryBot.create(:embed_test_video_entry) }
  let(:preview) { entry.media_file.previews.find_by!(conversion_profile: 'hls') }

  describe '#hls_file' do
    it 'serves a playlist as mpegurl' do
      get :hls_file, params: { id: preview.id, path: 'master.m3u8' }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq 'application/vnd.apple.mpegurl'
      expect(response.body).to include('360.m3u8')
      expect(response.headers['Cache-Control']).to include('no-cache')
    end

    it 'serves a media file with byte ranges' do
      request.headers['Range'] = 'bytes=0-1372'
      get :hls_file, params: { id: preview.id, path: '360.mp4' }

      expect(response).to have_http_status(206)
      expect(response.media_type).to eq 'video/mp4'
      expect(response.body.bytesize).to eq 1373
    end

    it 'rejects paths outside the package' do
      expect {
        get :hls_file, params: { id: preview.id, path: '../360.mp4' }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'appends a confidential-link token to playlist uris' do
      get :hls_file, params: { id: preview.id, path: '360.m3u8', accessToken: 'link-token' }

      expect(response.body).to include('360.mp4?accessToken=link-token')
      expect(response.body).to include('URI="360.mp4?accessToken=link-token"')
    end

    it 'refuses a preview the user cannot view' do
      outsider = FactoryBot.create(:user)
      entry.update_columns(is_published: false, get_metadata_and_previews: false)

      expect {
        get :hls_file, params: { id: preview.id, path: 'master.m3u8' }, session: { user_id: outsider.id }
      }.to raise_error(Errors::ForbiddenError)
    end
  end

  describe '#hls_package' do
    it 'downloads a zip of the package' do
      FileUtils.rm_f(HlsPackage.new(preview.media_file).zip_path)
      get :hls_package, params: { id: preview.id }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq 'application/zip'
      expect(response.headers['Content-Disposition']).to include('attachment')
      expect(response.headers['Content-Disposition']).to include('-hls.zip')

      names = []
      methods = []
      Zip::File.open(HlsPackage.new(preview.media_file).zip_path) do |zip|
        names = zip.entries.map(&:name)
        methods = zip.entries.map(&:compression_method)
      end
      expect(names).to include('master.m3u8', '360.m3u8', '360.mp4', '720.mp4', '1080.mp4')
      expect(methods).to all(eq(Zip::Entry::STORED))
    end
  end
end
