class MyController < ApplicationController
  layout 'my'

  # NOTE: conventions for sections:
  # - if it has resources: UserDashboardPresenter has a method with name of section
  # - `partial: :foobar` → `section_partial_foobar.haml`, used for index and show

  SECTIONS = {
    unpublished: {
      title: 'Unpublished Entries',
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    content: {
      title: 'My content',
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    latest_imports: {
      title: 'My latest imports',
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    favorites: {
      title: 'My favorites',
      icon: 'icon-privacy-private',
      partial: :media_resources
    },
    used_keywords: {
      title: 'My keywords',
      icon: 'icon-tag',
      partial: :keywords
    },
    entrusted_content: {
      title: 'My entrusted content',
      icon: 'icon-privacy-group',
      partial: :media_resources
    },
    groups: {
      title: 'My Groups',
      icon: 'icon-privacy-group',
      partial: :groups
    },
    filter_demo: {
      title: 'Filter demo',
      icon: 'icon-api',
      partial: :filter_demo
    }
  }

  before_action do
    authorize :dashboard, :logged_in?
    # needed for the sidebar nav, also in controllers that inherit from us:
    init_for_view
  end

  private

  def init_for_view
    # TODO: limit one (needed only for the sidebar nav)
    @get = \
      Presenters::Users::UserDashboard.new \
        current_user,
        order: 'created_at DESC',
        page: 1,
        per_page: 6
    @sections = prepare_sections_with_presenter(@get)
  end

  # we need this everywhere to build the sidebar
  def prepare_sections_with_presenter(presenter)
    Hash[SECTIONS.map do |id, section|
      [id, prepare_section(id, SECTIONS, presenter)]
    end]

    # put empty sections last, and set 'is_empty' key true
    sections = SECTIONS.map do |id, section|
      [id, prepare_section(id, SECTIONS, presenter)]
    end.group_by { |sec| (sec[1][:resources].try(:empty?) ? true : false) }

    (sections[false].presence || {})
      .concat((sections[true].presence || []).map do |s|
        [s[0], s[1].merge(is_empty?: true)]
      end).to_h
  end

  def prepare_section(id, sections, presenter)
    section = sections[id]
    section[:id] = id
    section[:resources] = \
      case section[:partial]
      when :media_resources, :groups, :keywords
        presenter.send(id)
      end
    section
  end
end
