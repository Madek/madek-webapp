class MyController < ApplicationController

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

  def dashboard
    @get = Presenters::Users::UserDashboard.new(current_user, 6)
    respond_with_presenter_formats
  end

  def dashboard_section
    locals = section_locals(SECTIONS, params[:section].to_sym)
    raise ActionController::RoutingError.new(404), 'no such section' unless locals
    render 'my/_section', locals: locals
  end

  private

  def section_locals(sections, section_name)
    locals = sections[section_name]
    return nil unless locals
    locals[:get] = Presenters::Users::UserDashboard.new(current_user, nil)
    if locals[:partial] == :media_resources
      locals[:media_resources] = locals[:get].send(section_name)
    end
    locals
  end

end
