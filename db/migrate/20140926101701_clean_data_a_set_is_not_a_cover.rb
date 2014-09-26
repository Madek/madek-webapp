class CleanDataASetIsNotACover < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          MediaResourceArc.joins(:child) \
            .where("type = ?",'MediaSet').where('cover = true') \
            .each do |arc|
              arc.update_attributes! cover: false
          end
        end
      end
    end
  end
end
