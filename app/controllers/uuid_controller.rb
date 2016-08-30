class UuidController < ApplicationController
  # Entity PURLs aka Permalinks:
  # find a model by uuid and redirects to canonical urls

  include UuidHelper

  def redirect_to_canonical_url
    skip_authorization # because we only redirect
    current_url = url_for
    path = url_for(UuidHelper.find_resource_by_uuid(params[:uuid]))
    if (path && path != current_url) # we check this to prevent a redirect-loop
      redirect_to(path, status: 302)
    else
      raise(ActionController::RoutingError.new('Not Found'), 'No Resource found')
    end
  end
end
