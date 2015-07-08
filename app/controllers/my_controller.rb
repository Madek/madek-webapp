class MyController < ApplicationController
  layout 'my'

  # NOTE: conventions for sections:
  # - if it has resources: UserDashboardPresenter has a method with name of section
  # - `partial: :foobar` → `section_partial_foobar.haml`, used for index and show

  SECTIONS = {
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
    },
    autocomplete_test: {
      title: 'Autocomplete test',
      icon: 'icon-api',
      partial: :autocomplete_test
    }
  }

  before_action do
    authorize :dashboard, :logged_in?
    # just for the sidebar nav, also needed in controllers that inherit from us:
    @get = \
      Presenters::Users::UserDashboard.new \
        current_user,
        order: 'created_at DESC',
        page: 1 # always shows only the items from the first page!

    @sections = prepare_sections_with_presenter(@get)
  end

  private

  # we need this everywhere to build the sidebar
  def prepare_sections_with_presenter(presenter)
    sections = Hash[SECTIONS.map do |id, section|
      [id, prepare_section(id, SECTIONS, presenter)]
    end]
    # we currently skip "emtpy" sections everywhere (dashboard and sidebar nav)
    # move this to partials if needed:
    sections.reject do |i, s| # ignore section if its an empty object or presenter
      true if s[:resources].try(:empty?)
    end
  end

  def prepare_section(id, sections, presenter)
    section = sections[id]
    section[:id] = id
    section[:resources] = \
      case section[:partial]
      when :media_resources, :groups
        presenter.send(id)
      end
    section
  end
end
