
class AppAdmin::MediaEntriesController < AppAdmin::BaseController

  before_filter only: [:show] do
    if (id = params[:id]) and (not id.blank?) and (id =~ /^\d+$/)
      if mr = MediaResource.find_by(previous_id: id)
        redirect_to app_admin_media_entry_path(mr.id), status: 301
        return
      end
    end
  end



  def index
    @media_entries = MediaEntry.where(type: "MediaEntry").reorder("created_at DESC").page(params[:page]).per(16)
  end

  def show
    @media_entry = MediaEntry.find params[:id]
  end

end
