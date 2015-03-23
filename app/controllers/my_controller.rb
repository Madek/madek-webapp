class MyController < ApplicationController
  include Concerns::Pagination

  layout 'app_with_sidebar'

  before_action do
    @sections = SECTIONS # we need this everywhere to build the sidebar
  end

  PER_PAGE = 12
  LIMIT_SHOW = 4096 # TMP: TODO: pagination!

  # TODO: is this the best place to define the sections?
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
    }
  }

  # "index" action
  def dashboard
    @get = \
      Presenters::Users::UserDashboard.new \
        current_user,
        order: 'created_at DESC',
        page: params[:page],
        per: PER_PAGE

    respond_with_presenter_formats
  end

  # "show" actions
  def dashboard_section
    section_name = params[:section].to_sym
    unless SECTIONS[section_name]
      raise ActionController::RoutingError.new(404), 'Section Not Found!'
    end
    render 'my/dashboard_section',
           locals: {
             sections: @sections,
             section_name: section_name,
             get: \
               Presenters::Users::UserDashboard.new(
                 current_user,
                 page: params[:page],
                 per: PER_PAGE)
           }
  end

end
