module MediaResourceMigrationModels

  class ::MigrationMediaResource < ActiveRecord::Base
    self.table_name = 'media_resources'
    self.inheritance_column = nil
    store :settings

    has_and_belongs_to_many :migration_edit_sessions,
                            -> { reorder(:created_at, :id) },
                            join_table: 'edit_sessions',
                            foreign_key: 'resource_id',
                            association_foreign_key: 'user_id'
  end

  class ::MigrationMediaResourceArc < ActiveRecord::Base
    self.table_name = 'media_resource_arcs'
    belongs_to :child, class_name: 'MigrationMediaResource',  foreign_key: :child_id
    belongs_to :parent, class_name: 'MigrationMediaResource',  foreign_key: :parent_id
  end

  class ::MigrationMediaEntry < ActiveRecord::Base
    self.table_name = 'media_entries'
  end

  class ::MigrationCollection < ActiveRecord::Base
    self.table_name = 'collections'
  end

  class ::MigrationFilterSet < ActiveRecord::Base
    self.table_name = 'filter_sets'
  end

  class ::MigrationEditSession < ActiveRecord::Base
    self.table_name = 'edit_sessions'
  end

  class ::MigrationEntrySetArc < ActiveRecord::Base
    self.table_name = 'collection_media_entry_arcs'
  end

  class ::MigrationSetSetArc < ActiveRecord::Base
    self.table_name = 'collection_collection_arcs'
  end

  class ::MigrationFilterSetSetArc < ActiveRecord::Base
    self.table_name = 'collection_filter_set_arcs'
  end

  class ::MigrationUserPermission < ActiveRecord::Base
    self.table_name = :userpermissions
  end

  class ::MigrationMetaDatum < ActiveRecord::Base
    self.table_name = 'meta_data'
    belongs_to :media_resource, class_name: '::MigrationMediaResource', foreign_key: :media_resource_id
  end

end
