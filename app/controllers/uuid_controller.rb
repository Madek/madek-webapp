class UuidController < ApplicationController
  # Entity PURLs aka Permalinks:
  # find a model by uuid and redirects to canonical urls

  SUPPORTED_REDIRECTION_CLASSES = [
    MediaEntry,
    Collection,
    FilterSet,
    Person
  ]

  def redirect_to_canonical_url
    current_url = url_for
    path = url_for(find_resource_by_uuid(params[:uuid]))
    if (path && path != current_url) # we check this to prevent a redirect-loop
      redirect_to(path, status: 302)
    else
      raise(ActionController::RoutingError.new('Not Found'), 'No Resource found')
    end
  end

  private

  def find_resource_by_uuid(resource_uuid)
    SUPPORTED_REDIRECTION_CLASSES
      .map { |klass| begin klass.send(:find, resource_uuid) rescue nil end }
      .reject(&:nil?)
      .first # just take it, there can not be more than one because UUIDs
  end
end
