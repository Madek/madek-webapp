module Media
end

class Media::FeaturedSet < MediaSet
end

class DropFeaturedSet < ActiveRecord::Migration
  def up
    
    if(featured_set = Media::FeaturedSet.first)
      AppSettings.featured_set_id = featured_set.id
      featured_set.type = "Media::Set"
      featured_set.save
    end

  end

  def down
  end
end
