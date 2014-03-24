class API::IndexRepresenter < API::RepresenterBase

  property :welcome_message
  property :authenticated

  link :self do api_path end

  link 'madek:media_resources' do  api_media_resources_path end


end
