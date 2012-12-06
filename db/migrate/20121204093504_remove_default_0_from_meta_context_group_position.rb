class RemoveDefault0FromMetaContextGroupPosition < ActiveRecord::Migration
  def change
    change_column_default(:meta_context_groups, :position, nil) 
  end
end
