class DeleteAdminGroup < ActiveRecord::Migration
  def up
    Group.find_by(name: 'Admin').try(:destroy)
  end

  def down
    Group.create!(name: 'Admin', type: 'Group')
  end
end
