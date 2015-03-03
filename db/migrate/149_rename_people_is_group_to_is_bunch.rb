class RenamePeopleIsGroupToIsBunch < ActiveRecord::Migration
  def change
    rename_column :people, :is_group, :is_bunch
  end
end
