
class AppAdmin::MediaEntriesController < AppAdmin::BaseController

  def index
    @media_entries = MediaEntry.reorder("created_at DESC").page(params[:page]).per(16)
  end

  def show
    @media_entry = MediaEntry.find params[:id]
  end

end
