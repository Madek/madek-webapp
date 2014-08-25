class RenameSplashscreenSlideshowSetId < ActiveRecord::Migration
  def change
    rename_column :app_settings, :splashscreen_slideshow_set_id, :teaser_set_id
  end
end
