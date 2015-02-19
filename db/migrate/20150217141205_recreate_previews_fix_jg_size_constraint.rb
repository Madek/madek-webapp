class RecreatePreviewsFixJgSizeConstraint < ActiveRecord::Migration
  def change
    MediaFile.where("created_at > '2014-10-01'::date").find_each do |mf|
      if mf.previews_creatable?
        begin
          mf.recreate_image_previews!
        rescue Exception => e
          Rails.logger.warn Formatter.exception_to_log_s(e)
        end
      end
    end
  end
end
