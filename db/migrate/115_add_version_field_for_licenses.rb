class AddVersionFieldForLicenses < ActiveRecord::Migration[4.2]

  class MigrationField < ActiveRecord::Base
    self.table_name = 'fields'
    serialize :data, JSON
  end

  def up
    field = MigrationField.new(
      id: 'license_version',
      active: true,
      position: 3,
      data: {
        label: 'License Version',
        type: 'text',
        attribute: ['item_version'],
        target_type: 'license',
        permissions: {
          role: 'inventory_manager',
          owner: 'true'
        },
        group: nil
      }
    )
    field.save!
  end
end
