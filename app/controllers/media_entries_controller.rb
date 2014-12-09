class MediaEntriesController < ApplicationController

  def index
    @media_entries = MediaEntry.all
  end

  def show
    @media_entry = MediaEntry.find params[:id]
  end

end
