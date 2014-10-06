class ReindexMediaResources04 < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do 
        MediaResource.find_in_batches do |mrs|
          mrs.each do |mr|
            mr.reindex
          end
        end
      end
    end
  end
end
