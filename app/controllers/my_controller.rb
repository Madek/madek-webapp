class MyController < ApplicationController

  def dashboard
    @latest_media_entries = current_user.media_entries.reorder('updated_at DESC').limit(6)
  end

end
