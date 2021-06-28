class AboutPagesController < ApplicationController

  before_action do
    skip_authorization # all /about pages are public!
  end

  def index
    with_raw_text(settings[:about_pages]) do |raw_text|
      respond_with(@get = Presenters::AboutPages::AboutPageShow.new(raw_text))
    end
  end

  def show
    static_page = StaticPage.find_by!(name: params[:id])
    with_raw_text(static_page.contents) do |raw_text|
      respond_with(@get = Presenters::AboutPages::AboutPageShow.new(raw_text, static_page))
    end
  end

  private

  def with_raw_text(source, &_block)
    raw_text = localize(source)
    raise ActiveRecord::RecordNotFound unless raw_text.present?
    yield raw_text
  end
end
