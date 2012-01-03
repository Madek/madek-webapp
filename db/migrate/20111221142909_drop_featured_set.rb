class Media::FeaturedSet < Media::Set
end

class DropFeaturedSet < ActiveRecord::Migration
  def up
    
    if(featured_set = Media::FeaturedSet.first)
      Media::Set.featured_set = featured_set
      featured_set.type = "Media::Set"
      featured_set.save
    end

  end

  def down
  end
end
