class Media::FeaturedSet < Media::Set
end

class DropFeaturedSet < ActiveRecord::Migration
  def up
    
    if(featured_set = Media::FeaturedSet.first)
      Media::Set.featured_set = featured_set
      featured_set.type = "Media::Set"
      featured_set.save
    end

    set_id = case Rails.env
      when "production"
        543
      else
        1
    end
    Settings.splashscreen_slideshow_set_id ||= set_id if Media::Set.exists?(set_id)

  end

  def down
  end
end
