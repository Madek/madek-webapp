# app/helpers/application_helper.rb

module ApplicationHelper
  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end

  def semver 
    MadekSemver.semver
  end

  def zhdk_login?
    Settings.zhdk_integration
  end

end
