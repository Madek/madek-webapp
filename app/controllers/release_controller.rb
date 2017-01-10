class ReleaseController < ApplicationController

  def show
    skip_authorization
    @get = Presenters::Release::ReleaseShow.new
    respond_with @get
  end
end
