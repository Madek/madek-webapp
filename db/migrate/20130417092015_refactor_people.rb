class RefactorPeople < ActiveRecord::Migration
  def change
    remove_column :people, :wiki_links
    remove_column :people, :nationality
    rename_column :people, :firstname, :first_name 
    rename_column :people, :lastname, :last_name
    rename_column :people, :deathdate, :date_of_death
    rename_column :people, :birthdate, :date_of_birth
  end
end
