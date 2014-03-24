class API::MediaResourceRepresenter < API::RepresenterBase

  property :id
  property :type

  #property :created_at
  #property :updated_at

  property :view, as: :public_view_permission
  property :download, as: :public_download_permission
  
  #property :public_permissions, writer: lambda{ |doc,args|
  #  doc[:public_permissions]= API::PermissionRepresenter.new(self).as_json
  #}
    
  link :self do api_media_resource_path(@represented) end

  link "madek:media_resources" do api_media_resources_path end 


end
