module Concerns
  module CustomUrls
    extend ActiveSupport::Concern

    UUID_MATCHER= Regexp.new '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'

    included do 
      helper_method :custom_url_path
      before_action :redirect_if_not_primary_url, only: [:show]
    end

    def redirect_if_not_primary_url 
      if UUID_MATCHER.match params[:id]
        if (@media_resource=MediaResource.find(params[:id])) and (primary_custom_url= @media_resource.primary_custom_url)
          redirect_to custom_url_path(@media_resource,primary_custom_url)
          return
        end
      elsif custom_url= CustomUrl.find_by(id: params[:id])
        if (self.class == MediaResourcesController) or ! custom_url.is_primary?
          redirect_to custom_url_path(custom_url.media_resource) 
          return
        else
          # this is the primary url of the correct controller
        end
      else
        raise "Illegal state exception"
      end
    end

    def find_media_resource 
      if UUID_MATCHER.match params[:id]
        MediaResource.find params[:id]
      else
        CustomUrl.find(params[:id]).media_resource
      end
    end

    def custom_url_path media_resource, custom_url= media_resource.primary_custom_url
      if custom_url
        case media_resource
        when MediaEntry
          media_entry_path(custom_url)
        when MediaSet 
          media_set_path(custom_url)
        when FilterSet
          filter_set_path(custom_url)
        else
          media_resource_path(custom_url)
        end
      else
        media_resource_path(media_resource)
      end
    end

  end
end
