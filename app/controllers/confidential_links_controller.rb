class ConfidentialLinksController < ApplicationController

  before_action :set_resource
  before_action do
    auth_authorize @resource, :confidential_links?
  end

  def new
    @get = generate_presenter(action_name).new(@resource, current_user)
    respond_with(@get, layout: 'application', template: template_name)
  end

  def create
    attrs = confidential_link_params(:description, :expires_at)
    cf_link = @resource.confidential_links.create(user: current_user)
    cf_link.update!(attrs) && cf_link.reload

    redirect_to \
      confidential_link_path(@resource, cf_link, just_created: true)
  end

  def update
    attrs = confidential_link_params(:revoked)
    cf_link = ConfidentialLink.find(params.require(:confidential_link_id))
    auth_authorize cf_link
    cf_link.update!(attrs) && cf_link.reload

    respond_with(@resource, location: confidential_links_path(@resource))
  end

  def show
    cf_link = @resource.confidential_links.find(params[:confidential_link_id])
    @get = generate_presenter(:show)
             .new(cf_link, current_user, settings.madek_external_base_url)
    @get.just_created = params[:just_created] == 'true'
    render template_name
  end

  private

  def confidential_link_params(*props)
    params.permit(confidential_link: props).fetch(:confidential_link, {})
  end

  def resource_type
    @_resource_type ||=
      case request.path
      when %r{\A\/entries\/}
        MediaEntry
      when %r{\A\/sets\/}
        Collection
      end
  end

  def template_name
    "#{resource_type.name.tableize}/#{action_name}_confidential_link"
  end

  def set_resource
    @resource = resource_type.find(params[:id])
  end

  def generate_presenter(action)
    [
      'Presenters',
      resource_type.name.pluralize,
      "#{resource_type.name}ConfidentialLink#{action.capitalize}"
    ]
      .join('::')
      .constantize
  end

  def confidential_link_path(resource, url, options = {})
    send(
      "confidential_link_#{resource_type.name.underscore}_path",
      resource,
      url,
      options
    )
  end

  def confidential_links_path(resource)
    send("confidential_links_#{resource_type.name.underscore}_path", resource)
  end
end
