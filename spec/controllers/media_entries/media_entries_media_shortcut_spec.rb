require 'spec_helper'

describe MediaEntriesController do
  describe 'media shortcuts for image entry' do
    let :image_entry do
      FactoryBot.create(:embed_test_image_landscape_entry)
    end

    example 'image.jpg' do
      get :image, params: { id: image_entry, format: 'jpg' }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('image/jpeg')
      expect(response.header['Content-Disposition']).to include('test-image-wide.tif.620x429.jpg')
    end

    example 'image.jpg?download=yes' do
      get :image, params: { id: image_entry, format: 'jpg' }
      expect(response.header['Content-Disposition']).to start_with('inline')
      get :image, params: { id: image_entry, format: 'jpg', download: 'yes' }
      expect(response.header['Content-Disposition']).to start_with('attachment')
    end

    example 'image.jpg?resolution=maximum' do
      get :image, params: { id: image_entry, format: 'jpg', resolution: 'maximum' }
      expect(response.header['Content-Disposition']).to include('test-image-wide.tif.1535x1063.jpg')
    end

    example 'image.jpg?resolution=x_large' do
      get :image, params: { id: image_entry, format: 'jpg', resolution: 'x_large' }
      expect(response.header['Content-Disposition']).to include('test-image-wide.tif.1024x709.jpg')
    end

    example 'image.jpg?resolution=large' do
      get :image, params: { id: image_entry, format: 'jpg', resolution: 'large' }
      expect(response.header['Content-Disposition']).to include('test-image-wide.tif.620x429.jpg')
    end

    example 'image.jpg?resolution=medium' do
      get :image, params: { id: image_entry, format: 'jpg', resolution: 'medium' }
      expect(response.header['Content-Disposition']).to include('test-image-wide.tif.300x208.jpg')
    end

    example 'image.jpg?resolution=small_125 (not supported -> 404)' do
      expect { get :image, params: { id: image_entry, format: 'jpg', resolution: 'small_125' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end

    example 'image.jpg?resolution=small (not supported -> 404)' do
      expect { get :image, params: { id: image_entry, format: 'jpg', resolution: 'small' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end

    example '404 because of wrong resolution param' do
      expect { get :image, params: { id: image_entry, format: 'jpg', resolution: '' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :image, params: { id: image_entry, format: 'jpg', resolution: 'whatever' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end

    example '404 because of wrong format param (e.g. "image", "image.png")' do
      expect { get :image, params: { id: image_entry, format: 'png' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :image, params: { id: image_entry, format: nil } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end

    example '404 because of wrong action name (video, audio, document)' do
      expect { get :video, params: { id: image_entry, format: 'jpg' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :video, params: { id: image_entry, format: 'webm' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')

      expect { get :audio, params: { id: image_entry, format: 'jpg' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :audio, params: { id: image_entry, format: 'mp3' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')

        expect { get :document, params: { id: image_entry, format: 'jpg' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :document, params: { id: image_entry, format: 'pdf' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end
  end

  describe 'media shortcuts for video entry' do
    let :video_entry do
      FactoryBot.create(:embed_test_video_entry)
    end

    example 'video.mp4' do
      get :video, params: { id: video_entry, format: 'mp4' }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('video/mp4')
      expect(response.header['Content-Disposition']).to include('madek-test-video-5s.mp4.620x348.mp4')
    end

    example 'video.mp4?resolution=SD' do
      get :video, params: { id: video_entry, format: 'mp4', resolution: 'SD' }
      expect(response.header['Content-Disposition']).to include('madek-test-video-5s.mp4.620x348.mp4')
    end

    example 'video.mp4?resolution=HD' do
      get :video, params: { id: video_entry, format: 'mp4', resolution: 'HD' }
      expect(response.header['Content-Disposition']).to include('madek-test-video-5s.mp4.1920x1080.mp4')
    end

    example 'video.webm?resolution=SD' do
      get :video, params: { id: video_entry, format: 'webm', resolution: 'SD' }
      expect(response.content_type).to eq('video/webm')
      expect(response.header['Content-Disposition']).to include('madek-test-video-5s.mp4.620x348.webm')
    end

    example 'video.webm?resolution=HD' do
      get :video, params: { id: video_entry, format: 'webm', resolution: 'HD' }
      expect(response.header['Content-Disposition']).to include('madek-test-video-5s.mp4.1920x1080.webm')
    end

    example 'image.jpg' do
      get :image, params: { id: video_entry, format: 'jpg' }
      expect(response.header['Content-Disposition']).to include('madek-test-video-5s.mp4.620x348.jpg')
    end

    example '404 because of wrong resolution param' do
      expect { get :video, params: { id: video_entry, format: 'mp4', resolution: '4K' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :video, params: { id: video_entry, format: 'mp4', resolution: 'whatever' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end

    example '404 because of wrong format param (e.g. "video", "video.rm")' do
      expect { get :video, params: { id: video_entry, format: nil } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :video, params: { id: video_entry, format: 'rm' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end

    example '404 because of wrong action name (audio, document)' do
      expect { get :audio, params: { id: video_entry, format: 'webm' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :audio, params: { id: video_entry, format: 'mp3' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')

      expect { get :document, params: { id: video_entry, format: 'webm' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :document, params: { id: video_entry, format: 'pdf' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end
  end

  describe 'media shortcuts for audio entry' do
    let :audio_entry do
      FactoryBot.create(:embed_test_audio_entry)
    end

    example 'audio.mp3' do
      get :audio, params: { id: audio_entry, format: 'mp3' }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('audio/mpeg')
      expect(response.header['Content-Disposition']).to include('test-audio.aac.mp3')
    end

    example 'audio.ogg' do
      get :audio, params: { id: audio_entry, format: 'ogg' }
      expect(response.content_type).to eq('audio/ogg')
      expect(response.header['Content-Disposition']).to include('test-audio.aac.ogg')
    end

    example '404 because of wrong format param (e.g. "audio", "audio.rm")' do
      expect { get :audio, params: { id: audio_entry, format: nil } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :audio, params: { id: audio_entry, format: 'rm' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end

    example '404 because of wrong action name (image, video, document)' do
      expect { get :image, params: { id: audio_entry, format: 'mp3' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :image, params: { id: audio_entry, format: 'jpg' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')

      expect { get :video, params: { id: audio_entry, format: 'mp3' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :video, params: { id: audio_entry, format: 'webm' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')

      expect { get :document, params: { id: audio_entry, format: 'mp3' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :document, params: { id: audio_entry, format: 'pdf' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end
  end

  describe 'media shortcuts for document entry' do
    let :document_entry do
      FactoryBot.create(:embed_test_pdf_entry)
    end

    example 'document.pdf' do
      get :document, params: { id: document_entry, format: 'pdf' }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/pdf')
      expect(response.header['Content-Disposition']).to include('pdf-beispiel.pdf')
    end

    example 'image.jpg' do
      get :image, params: { id: document_entry, format: 'jpg' }
      expect(response.header['Content-Disposition']).to include('pdf-beispiel.pdf.353x500.jpg')
    end

    example '404 because of wrong format param (e.g. "document", "document.docx")' do
      expect { get :document, params: { id: document_entry, format: nil } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :document, params: { id: document_entry, format: 'docx' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end

    example '404 because of wrong action name (video, audio)' do
      expect { get :video, params: { id: document_entry, format: 'pdf' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :video, params: { id: document_entry, format: 'webm' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')

        expect { get :audio, params: { id: document_entry, format: 'pdf' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
      expect { get :audio, params: { id: document_entry, format: 'mp3' } }
        .to raise_error(ActionController::RoutingError, 'Not Found')
    end
  end

  describe 'permissions' do
    let :document_entry do
      FactoryBot.create(:embed_test_pdf_entry)
    end
    example 'get_metadata_and_previews is required to get the image' do
      document_entry.update!(get_metadata_and_previews: false)

      expect { get :image, params: { id: document_entry, format: 'jpg' } }
        .to raise_error(Errors::UnauthorizedError)
    end
    example 'get_full_size is required to get the pdf' do
      document_entry.update!(get_full_size: false)

      # image is OK
      get :image, params: { id: document_entry, format: 'jpg' }
      expect(response.status).to eq(200)

      # but not the PDF
      expect { get :document, params: { id: document_entry, format: 'pdf' } }
        .to raise_error(Errors::UnauthorizedError)
    end
  end
end