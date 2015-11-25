class MyController < ApplicationController
  include Concerns::ResourceListParams
  layout 'my'

  # NOTE: conventions for sections:
  # - if it has resources: UserDashboardPresenter has a method with name of section
  # - `partial: :foobar` → `section_partial_foobar.haml`, used for index and show

  SECTIONS = {
    unpublished_entries: {
      title: I18n.t(:sitemap_my_unpublished),
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    content_media_entries: {
      title: I18n.t(:sitemap_my_content_media_entries),
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    content_collections: {
      title: I18n.t(:sitemap_my_content_collections),
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    content_filter_sets: {
      title: I18n.t(:sitemap_my_content_filter_sets),
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    latest_imports: {
      title: I18n.t(:sitemap_my_latest_imports),
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    favorite_media_entries: {
      title: I18n.t(:sitemap_my_favorite_collections),
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    favorite_collections: {
      title: I18n.t(:sitemap_my_favorite_media_entries),
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    favorite_filter_sets: {
      title: I18n.t(:sitemap_my_favorite_filter_sets),
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    used_keywords: {
      title: I18n.t(:sitemap_my_used_keywords),
      icon: 'icon-tag',
      partial: :keywords
    },
    entrusted_media_entries: {
      title: I18n.t(:sitemap_my_entrusted_media_entries),
      icon: 'icon-privacy-group',
      partial: :media_resources
    },
    entrusted_collections: {
      title: I18n.t(:sitemap_my_entrusted_collections),
      icon: 'icon-privacy-group',
      partial: :media_resources
    },
    entrusted_filter_sets: {
      title: I18n.t(:sitemap_my_entrusted_filter_sets),
      icon: 'icon-privacy-group',
      partial: :media_resources
    },
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
    skip_policy_scope
  end

  private

  def init_for_view
    list_config = if (params[:action] == 'dashboard')
                    { per_page: 6, page: 1, interactive: false }
                  else
                    { per_page: 12, interactive: true }.merge(resource_list_params)
                  end

    @get = Presenters::Users::UserDashboard.new(
      current_user, list_conf: { order: 'created_at DESC' }.merge(list_config))

    # NOTE: uses as separate presenter, for counting regardless of
    # any possible user-given (filter, …)-config!
    # TODO: port this logic to dashboard presenter, build table of contents there
    @sections = order_sections_according_to_counts(
      SECTIONS,
      Presenters::Users::UserDashboard.new(
        current_user, list_conf: { page: 1, per_page: 1 }))
  end

  def order_sections_according_to_counts(sections, presenter)
    # put empty sections last, and set 'is_empty' key true
    sections = SECTIONS.map do |id, section|
      [id, prepare_section_with_count(id, sections, presenter)]
    end.group_by { |sec| (sec[1][:presenter].try(:empty?) ? true : false) }
    sections = (sections[false].presence || [])
      .concat((sections[true].presence || []).map do |s|
        [s[0], s[1].merge(is_empty?: true)]
      end).to_h
    # remove the presenter so it is not accidently used in view (with wrong config)
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
