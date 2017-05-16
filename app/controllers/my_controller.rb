# rubocop:disable Metrics/ClassLength
class MyController < ApplicationController
  include Concerns::ResourceListParams
  include Concerns::UserScopes::Dashboard
  include Concerns::NewCollectionModal
  include Concerns::ActivityStream

  include Concerns::Clipboard

  layout 'my'

  after_action :verify_policy_scoped

  def session_token
    unless current_user
      raise '403'
    else
      duration = if params[:duration].present?
        ChronicDuration.parse(params[:duration]) || raise('Parser error!')
      else
        60 * 60 * 24
      end
      unless duration <= 60 * 60 * 24
        raise 'Duration may not be longer than 24 hours!'
      end
      render text: build_session_value(current_user, max_duration_secs: duration)
    end
  end

  # NOTE: conventions for sections:
  # - if it has resources: UserDashboardPresenter has a method with name of section
  # - `partial: :foobar` → `section_partial_foobar.haml`, used for index and show
  # - no `partial` but `href` renders an entry in the sidebar only

  # rubocop:disable Metrics/MethodLength
  def sections_definition
    {
      activity_stream: {
        title: 'Aktivitäten',
        icon: 'icon-privacy-private',
        partial: :activity_stream,
        hide_from_index: true
      },
      clipboard: {
        title: I18n.t(:sitemap_clipboard),
        icon: 'icon-privacy-group',
        partial: :media_resources,
        is_beta: true,
        hide_from_index: true
      },
      unpublished_entries: {
        title: I18n.t(:sitemap_my_unpublished),
        icon: 'icon-privacy-private',
        partial: :media_resources,
        allowed_filter_params:
          Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
      },
      content_media_entries: {
        title: I18n.t(:sitemap_my_content_media_entries),
        icon: 'icon-privacy-private',
        partial: :media_resources,
        allowed_filter_params:
          Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
      },
      content_collections: {
        title: I18n.t(:sitemap_my_content_collections),
        icon: 'icon-privacy-private',
        partial: :media_resources,
        allowed_filter_params:
          Concerns::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS
      },
      # content_filter_sets: {
      #   title: I18n.t(:sitemap_my_content_filter_sets),
      #   icon: 'icon-privacy-private',
      #   partial: :media_resources
      # },
      latest_imports: {
        title: I18n.t(:sitemap_my_latest_imports),
        icon: 'icon-privacy-private',
        partial: :media_resources,
        allowed_filter_params:
          Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
      },
      favorite_media_entries: {
        title: I18n.t(:sitemap_my_favorite_media_entries),
        icon: 'icon-privacy-private',
        partial: :media_resources,
        allowed_filter_params:
          Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
      },
      favorite_collections: {
        title: I18n.t(:sitemap_my_favorite_collections),
        icon: 'icon-privacy-private',
        partial: :media_resources,
        allowed_filter_params:
          Concerns::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS
      },
      # favorite_filter_sets: {
      #   title: I18n.t(:sitemap_my_favorite_filter_sets),
      #   icon: 'icon-privacy-private',
      #   partial: :media_resources
      # },
      used_keywords: {
        title: I18n.t(:sitemap_my_used_keywords),
        icon: 'icon-tag',
        partial: :keywords
      },
      entrusted_media_entries: {
        title: I18n.t(:sitemap_my_entrusted_media_entries),
        icon: 'icon-privacy-group',
        partial: :media_resources,
        allowed_filter_params:
          Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
      },
      entrusted_collections: {
        title: I18n.t(:sitemap_my_entrusted_collections),
        icon: 'icon-privacy-group',
        partial: :media_resources,
        allowed_filter_params:
          Concerns::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS
      },
      # entrusted_filter_sets: {
      #   title: I18n.t(:sitemap_my_entrusted_filter_sets),
      #   icon: 'icon-privacy-group',
      #   partial: :media_resources
      # },
      groups: {
        title: I18n.t(:sitemap_my_groups),
        icon: 'icon-privacy-group',
        partial: :groups
      },
      vocabularies: {
        title: I18n.t(:sitemap_vocabularies),
        icon: 'icon-privacy-group',
        hide_from_index: true,
        href: '/vocabulary' # NOTE: no path helper, this route is fixed
      }
    }.compact
  end
  # rubocop:enable Metrics/MethodLength

  before_action do
    auth_authorize :dashboard, :logged_in?
    # needed for the sidebar nav, also in controllers that inherit from us:
    init_for_view
  end

  private

  def init_for_view
    @sections = _set_async_below_fold \
      sections_definition.map { |id, s| [id, s.merge(id: id)] }.to_h
    @get = Presenters::Users::UserDashboard.new(
      current_user,
      user_scopes_for_dashboard(current_user),
      Presenters::Users::DashboardHeader.new(nil),
      with_count: (params[:action] != 'dashboard'),
      list_conf: { order: 'created_at DESC' }.merge(list_conf_by_dashboard_action),
      activity_stream_conf: activity_stream_params,
      action: params[:action])
  end

  def current_section
    section_name = params.permit(:section).try(:[], :section).try(:to_sym)
    return unless section_name
    @current_section ||= @sections.try(:[], section_name)
  end

  def list_conf_by_dashboard_action
    if (params[:action] == 'dashboard')
      resource_list_params.merge(per_page: 6, page: 1)
    else
      { per_page: 12 }.merge \
        resource_list_params(params, current_section.try(:[],
                                                         :allowed_filter_params))
    end
  end

  def _set_async_below_fold(sections)
    conf_prerender_sections_nr = 3 # just the drafts, if there are some.
    sections.map.with_index do |a, i|
      [a[0], a[1].merge(render_async?: ((i + 1) > conf_prerender_sections_nr))]
    end.to_h
  end

end
# rubocop:enable Metrics/ClassLength
