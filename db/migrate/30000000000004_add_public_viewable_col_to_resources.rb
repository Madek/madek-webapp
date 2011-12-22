class AddPublicViewableColToResources < ActiveRecord::Migration
  include Constants

  def change

    PublicActions.each do |action|
      [:media_sets,:media_entries].each do |resource|
        add_column resource, "perm_public_may_#{action}", :boolean, :default => false
        add_index resource, "perm_public_may_#{action}"
      end
    end
    
  end
end
