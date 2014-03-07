module Concerns
  module CustomUrls
    extend ActiveSupport::Concern

    UUID_MATCHER= Regexp.new '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'

    included do 
      helper_method :custom_url_path
      before_action :redirect_to_primary_url, only: [:show]
    end

    def redirect_to_primary_custom_url custom_url
      redirect_to custom_url_path(custom_url.media_resource) 
      return
    end

    def redirect_to_primary_url
      if UUID_MATCHER.match params[:id] # id is a UUID; redirect if there is a custom primary url
        if (@media_resource=MediaResource.find(params[:id])) and (primary_custom_url= @media_resource.primary_custom_url)
          redirect_to_primary_custom_url(primary_custom_url)
        end
      elsif custom_url= CustomUrl.find_by(id: params[:id])
        unless custom_url.is_primary? # custom_url is not primary so we have to redirect in any case
          redirect_to_primary_custom_url(custom_url)
        else # custom_url is primary; yet it could be the wrong contoller
          case custom_url.media_resource
          when MediaSet 
            redirect_to_primary_custom_url(custom_url) unless (self.class == MediaSetsController)
          when MediaEntry 
            redirect_to_primary_custom_url(custom_url) unless (self.class == MediaEntriesController)
          when FilterSet 
            redirect_to_primary_custom_url(custom_url) unless (self.class == FilterSetsController)
          else
            # we are on the primary url of the proper controller ; do nothing
            # (unless this es a (new) MediaResource, which is not yet handled)
          end
        end
      else
        # ID of URL is not UUID neither existing primary
        # fake a ActiveRecord::RecordNotFound which triggers a NOT FOUND page
        raise ActiveRecord::RecordNotFound.new("ID of URL is not a uuid neither existing primary url.")
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
