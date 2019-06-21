class AboutPagesController < ApplicationController

  before_action do
    skip_authorization # all /about pages are public!
  end

  def index
    raw_text = localize(settings[:about_pages])
    raise ActiveRecord::RecordNotFound unless raw_text.present?
    respond_with(@get = Presenters::AboutPages::AboutPageShow.new(raw_text))
  end
end
