class MyController < ApplicationController
  include Concerns::ResourceListParams
  include Concerns::UserScopes::Dashboard
  include Concerns::NewCollectionModal
  include Concerns::ActivityStream
  include Concerns::Clipboard
  include Concerns::My::DashboardSections

  def dashboard
    auth_authorize :dashboard, :logged_in?

    user_dashboard = create_user_dashboard(
      list_conf: { order: 'created_at DESC' }.merge(
        resource_list_params.merge(per_page: 6, page: 1)
      ),
      is_async_attribute: params['___sparse']
    )

    @get = Presenters::Users::Dashboard.new(
      user_dashboard,
      create_sections
    )

    respond_with @get, layout: 'application'
  end

  def scope_by_type(clipboard, type_filter)
    case type_filter
    when 'entries' then clipboard.media_entries
    when 'collections' then clipboard.collections
    else clipboard.child_media_resources
    end
  end

  def content_by_type(type_filter)
    case type_filter
    when 'entries' then MediaEntry
    when 'collections' then Collection
    else
      MediaResource
    end
  end

  def presenterify_clipboard_resources
    clipboard = clipboard_collection(current_user)

    type_filter = params.permit(:type).fetch(:type, nil)

    mr_scope = scope_by_type(clipboard, type_filter)

    content_type = content_by_type(type_filter)

    Presenters::Collections::ChildMediaResources.new(
      mr_scope,
      current_user,
      # NOTE: should have class of db view even if using a faster scope:
      item_type: 'MediaResources',
      can_filter: true,
      list_conf: resource_list_by_type_param,
      disable_file_search: type_filter != 'entries',
      only_filter_search: !['entries', 'collections'].include?(type_filter),
      content_type: content_type,
      json_path: 'section_content.resources.resources',
      sub_filters: { context_key_id: params[:context_key_id], search_term: params[:search_term] }
    )
  end

  def generic_section(current_section)
    user_dashboard = create_user_dashboard(
      list_conf: { order: 'created_at DESC' }.merge(
        { per_page: 12 }.merge(
          resource_list_params(
            params,
            current_section.try(:[], :allowed_filter_params)
          )
        )
      ),
      is_async_attribute: true,
      json_path: 'section_content.resources'
    )

    Presenters::Users::DashboardSection.new(
      user_dashboard.send(current_section[:id]),
      create_sections,
      current_section
    )
  end

  def clipboard_section(current_section)
    clipboard = clipboard_collection(current_user)
    section_content = \
      if clipboard
        Pojo.new(
          resources: presenterify_clipboard_resources,
          clipboard_id: clipboard.id
        )
      else
        Pojo.new(
          resources: nil,
          clipboard_id: nil
        )
      end

    Presenters::Users::DashboardSection.new(
      section_content,
      create_sections,
      current_section
    )
  end

  def dashboard_section
    auth_authorize :dashboard, :logged_in?

    current_section = determine_current_section
    @get = \
      if current_section[:id] == :clipboard
        clipboard_section(current_section)
      else
        generic_section(current_section)
      end

    respond_with @get, layout: 'app_with_sidebar'
  end

  private

  def determine_current_section
    section_name = params.permit(:section).try(:[], :section).try(:to_sym)

    unless section_name
      raise ActionController::RoutingError.new(404), 'No such dashboard section!'
    end

    section = create_sections.try(:[], section_name)

    unless section
      raise ActionController::RoutingError.new(404), 'No such dashboard section!'
    end

    section
  end

  def select_accessible_sections
    sections_definition
      .reject { |_, attrs| attrs.fetch(:is_accessible, true) == false }
  end

  def create_sections
    select_accessible_sections.map do |id, s|
      [id, s.merge(id: id)]
    end.to_h
  end

  def create_user_dashboard(
    list_conf: nil,
    is_async_attribute: nil,
    json_path: nil)

    Presenters::Users::UserDashboard.new(
      current_user,
      user_scopes_for_dashboard(current_user),
      Presenters::Users::DashboardHeader.new,
      with_count: (params[:action] != 'dashboard'),
      list_conf: list_conf,
      activity_stream_conf: activity_stream_params,
      action: params[:action],
      is_async_attribute: is_async_attribute,
      json_path: json_path,
      type_filter: params.permit(:type).fetch(:type, nil),
      sub_filters: { context_key_id: params[:context_key_id], search_term: params[:search_term] }
    )
  end
end
