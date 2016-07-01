# NOTE: will be refactored wholesome anyway, so disable this cop here
# rubocop:disable Metrics/ClassLength
class MyController < ApplicationController
  include Concerns::ResourceListParams
  include Concerns::UserScopes::Dashboard
  include Concerns::NewCollectionModal
  layout 'my'

  after_action :verify_policy_scoped

  # TMP
  before_action do
    @feature_toggle_debug_dashboard = params.permit(:debug_dashboard).present?
  end

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

  SECTIONS = {
    unpublished_entries: {
      title: I18n.t(:sitemap_my_unpublished),
      icon: 'icon-privacy-private',
      partial: :media_resources,
      allowed_filter_params: MediaEntriesController::ALLOWED_FILTER_PARAMS
    },
    content_media_entries: {
      title: I18n.t(:sitemap_my_content_media_entries),
      icon: 'icon-privacy-private',
      partial: :media_resources,
      allowed_filter_params: MediaEntriesController::ALLOWED_FILTER_PARAMS
    },
    content_collections: {
      title: I18n.t(:sitemap_my_content_collections),
      icon: 'icon-privacy-private',
      partial: :media_resources,
      allowed_filter_params: CollectionsController::ALLOWED_FILTER_PARAMS
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
      allowed_filter_params: MediaEntriesController::ALLOWED_FILTER_PARAMS
    },
    favorite_media_entries: {
      title: I18n.t(:sitemap_my_favorite_media_entries),
      icon: 'icon-privacy-private',
      partial: :media_resources,
      allowed_filter_params: MediaEntriesController::ALLOWED_FILTER_PARAMS
    },
    favorite_collections: {
      title: I18n.t(:sitemap_my_favorite_collections),
      icon: 'icon-privacy-private',
      partial: :media_resources,
      allowed_filter_params: CollectionsController::ALLOWED_FILTER_PARAMS
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
      allowed_filter_params: MediaEntriesController::ALLOWED_FILTER_PARAMS
    },
    entrusted_collections: {
      title: I18n.t(:sitemap_my_entrusted_collections),
      icon: 'icon-privacy-group',
      partial: :media_resources,
      allowed_filter_params: CollectionsController::ALLOWED_FILTER_PARAMS
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
    }
  }

  before_action do
    authorize :dashboard, :logged_in?
    # needed for the sidebar nav, also in controllers that inherit from us:
    init_for_view
  end

  private

  def current_section
    @current_section ||= \
      begin
        section_name = params[:section].try(:to_sym)
        @sections[section_name]
      end
  end

  def list_config
    if (params[:action] == 'dashboard')
      { per_page: 6, page: 1 }
    else
      { per_page: 12 }.merge \
        resource_list_params(params, current_section.try(:[],
                                                         :allowed_filter_params))
    end
  end

  def init_for_view
    # NOTE: uses as separate presenter, for counting regardless of
    # any possible user-given (filter, …)-config!
    # TODO: port this logic to dashboard presenter, build table of contents there
    @sections = set_async_below_fold order_sections_according_to_counts(
      SECTIONS,
      Presenters::Users::UserDashboard.new(current_user,
                                           user_scopes_for_dashboard(current_user),
                                           nil,
                                           with_count: false,
                                           list_conf: { page: 1, per_page: 1 }))

    @get = Presenters::Users::UserDashboard.new(
      current_user,
      user_scopes_for_dashboard(current_user),
      Presenters::Users::DashboardHeader.new(nil),
      list_conf: { order: 'created_at DESC' }.merge(list_config))
  end

  def order_sections_according_to_counts(sections, presenter)
    sections = \
      put_empty_sections_last_and_set_is_empty_key_true(SECTIONS, presenter)

    sections = (sections[false].presence || [])
      .concat(
        (sections[true].presence || [])
          .map { |s| [s[0], s[1].merge(is_empty?: true)] })
      .to_h

    remove_the_presenter_so_it_is_not_accidently_used_in_view(sections)
  end

  def put_empty_sections_last_and_set_is_empty_key_true(sections, presenter)
    sections.map do |id, section|
      [id, prepare_section_with_count(id, sections, presenter)]
    end
    .group_by { |sec| (sec[1][:presenter].try(:empty?) ? true : false) }
  end

  def remove_the_presenter_so_it_is_not_accidently_used_in_view(sections)
    sections.map { |id, section| [id, section.except(:presenter)] }.to_h
  end

  def prepare_section_with_count(id, sections, presenter)
    section = sections[id]
    section[:id] = id
    section[:presenter] = \
      case section[:partial]
      when :media_resources, :groups, :keywords
        presenter.send(id)
      end
    section
  end

end

# HACK: set async render if section is "below the fold"
def set_async_below_fold(sections)
  return sections if @feature_toggle_debug_dashboard

  conf_prerender_sections_nr = 1 # just the drafts, if there are some.
  sections.map.with_index do |a, i|
    [a[0], a[1].merge(render_async?: ((i + 1) > conf_prerender_sections_nr))]
  end.to_h
end
# rubocop:enable Metrics/ClassLength
