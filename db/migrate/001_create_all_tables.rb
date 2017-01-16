class CreateAllTables < ActiveRecord::Migration

  # So we dropped all previous migrations and restarted from the schema.rb file
  def self.up

    # This is a fresh install, let's create all leihs tables in the DB

    create_table :access_rights, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :inventory_pool_id
      t.date       :suspended_until
      t.text       :suspended_reason
      t.date       :deleted_at
      t.timestamps null: false
      t.string    :role, null: false
    end

    execute <<-SQL.strip_heredoc
      ALTER TABLE access_rights
        ADD CONSTRAINT check_allowed_roles
        CHECK (
          role IN ('#{AccessRight::AVAILABLE_ROLES.join("', '")}')
        );
    SQL

    change_table :access_rights do |t|
      t.index :suspended_until
      t.index :deleted_at
      t.index :inventory_pool_id
      t.index :role
      t.index [:user_id, :inventory_pool_id, :deleted_at], :name => :index_on_user_id_and_inventory_pool_id_and_deleted_at
    end


    create_table :accessories, id: :uuid do |t|
      t.uuid :model_id
      t.string     :name
      t.integer    :quantity
    end
    change_table :accessories do |t|
      t.index :model_id
    end


    create_table :accessories_inventory_pools, :id => false do |t|
      t.uuid :accessory_id
      t.uuid :inventory_pool_id
    end
    change_table :accessories_inventory_pools do |t|
      t.index [:accessory_id, :inventory_pool_id], :unique => true, :name => 'index_accessories_inventory_pools'
      t.index :inventory_pool_id
    end

    create_table :addresses, id: :uuid do |t|
      t.string :street
      t.string :zip_code
      t.string :city
      t.string :country_code
      t.float :latitude
      t.float :longitude
    end
    change_table :addresses do |t|
      t.index [:street, :zip_code, :city, :country_code], :unique => true, name: 'index_addresses_szcc'
    end


    create_table :attachments, id: :uuid do |t|
      t.uuid :model_id
      t.boolean    :is_main,  :default => false
      ### attachment_fu
      t.string  :content_type
      t.string  :filename
      t.integer :size
      ###
    end

    change_table :attachments do |t|
      t.index :model_id
    end


    create_table :authentication_systems, id: :uuid do |t|
      t.string  :name
      t.string  :class_name
      t.boolean :is_default, :default => false
      t.boolean :is_active,  :default => false
    end


    create_table :buildings, id: :uuid do |t|
      t.string :name
      t.string :code
    end


    create_table :reservations, id: :uuid do |t|
      t.uuid :contract_id
      t.uuid :inventory_pool_id
      t.uuid :user_id
      t.uuid :delegated_user_id
      t.uuid :handed_over_by_user_id
      t.string     :type,     :default => 'ItemLine', :null => false # STI (single table inheritance)
      t.string     :status, null: false
      t.uuid :item_id
      t.uuid :model_id
      t.integer    :quantity, :default => 1
      t.date       :start_date
      t.date       :end_date
      t.date       :returned_date
      t.uuid :option_id, :null => true
      t.uuid :purpose_id
      t.uuid :returned_to_user_id
      t.timestamps null: false
    end


    execute <<-SQL.strip_heredoc
      ALTER TABLE reservations
        ADD CONSTRAINT check_allowed_statuses
        CHECK (
          status IN ('#{Reservation::STATUSES.join("', '")}')
        );
    SQL

    change_table :reservations do |t|
      t.index :start_date
      t.index :end_date
      t.index :option_id
      t.index :contract_id
      t.index :item_id
      t.index :model_id
      t.index [:returned_date, :contract_id]
      t.index [:type, :contract_id]
      t.index :status
    end

    create_table :contracts, id: :uuid do |t|
      t.text       :note
      t.timestamps null: false
    end

    create_table :database_authentications, id: :uuid do |t|
      t.string     :login
      t.string     :crypted_password, :limit => 40
      t.string     :salt,             :limit => 40
      t.uuid :user_id
      t.timestamps null: false
    end


    create_table :delegations_users, :id => false do |t|
      t.uuid :delegation_id
      t.uuid :user_id
    end
    change_table :delegations_users do |t|
      t.index [:user_id, :delegation_id], :unique => true
      t.index :delegation_id
    end

    create_table :groups, id: :uuid do |t|
      t.string     :name
      t.uuid :inventory_pool_id
      t.boolean    :is_verification_required, default: false
      t.timestamps null: false
    end
    change_table :groups do |t|
      t.index :inventory_pool_id
      t.index   :is_verification_required
    end


    create_table :groups_users, :id => false do |t|
      t.uuid :user_id
      t.uuid :group_id
    end

    change_table :groups_users do |t|
      t.index [:user_id, :group_id], :unique => true
      t.index :group_id
    end

    create_table :holidays, id: :uuid do |t|
      t.uuid :inventory_pool_id
      t.date       :start_date
      t.date       :end_date
      t.string     :name
    end
    change_table :holidays do |t|
      t.index :inventory_pool_id
      t.index [:start_date, :end_date]
    end


    create_table :images, id: :uuid do |t|
      t.uuid :target_id
      t.string :target_type
      t.boolean    :is_main,      :default => false
      ### attachment_fu
      t.string  :content_type
      t.string  :filename
      t.integer :size
      t.integer :height
      t.integer :width
      t.uuid :parent_id
      t.string  :thumbnail
      ###
    end
    change_table :images do |t|
      t.index [:target_id, :target_type]
    end


    create_table :inventory_pools, id: :uuid do |t|
      t.string     :name
      t.text       :description
      t.string     :contact_details
      t.string     :contract_description
      t.string     :contract_url
      t.string     :logo_url
      t.text       :default_contract_note, :null => true
      t.string     :shortname
      t.string     :email
      t.text       :color
      t.boolean    :print_contracts,       :default => true
      t.text       :opening_hours
      t.uuid :address_id
      t.boolean    :automatic_suspension, null: false, default: false
      t.text       :automatic_suspension_reason
      t.boolean    :automatic_access
      t.boolean    :required_purpose, default: true
    end
    change_table :inventory_pools do |t|
      t.index :name, :unique => true
    end


    create_table :inventory_pools_model_groups, :id => false do |t|
      t.uuid :inventory_pool_id
      t.uuid :model_group_id
    end
    change_table :inventory_pools_model_groups do |t|
      t.index :inventory_pool_id
      t.index :model_group_id
    end


    create_table :items, id: :uuid do |t|
      t.string     :inventory_code
      t.string     :serial_number
      t.uuid :model_id
      t.uuid :location_id
      t.uuid :supplier_id
      t.uuid :owner_id, :null => false
      t.uuid :inventory_pool_id, :null => false
      t.uuid :parent_id, :null => true # used for packages
      t.string     :invoice_number
      t.date       :invoice_date
      t.date       :last_check,            :default => nil
      t.date       :retired,               :default => nil
      t.string     :retired_reason,        :default => nil
      t.decimal    :price,                 :precision => 8, :scale => 2
      t.boolean    :is_broken,             :default => false
      t.boolean    :is_incomplete,         :default => false
      t.boolean    :is_borrowable,         :default => false
      t.text       :status_note
      t.boolean    :needs_permission,      :default => false
      t.boolean    :is_inventory_relevant, :default => false # per Ramon the default should be "not inventory relevant" by default
      t.string     :responsible
      t.string     :insurance_number
      t.text       :note
      t.text       :name
      t.string     :user_name
      t.text       :properties
      t.timestamps null: false
    end
    change_table :items do |t|
      t.index :inventory_pool_id
      t.index :retired
      t.index :inventory_code, :unique => true
      t.index :is_borrowable
      t.index :is_broken
      t.index :is_incomplete
      t.index :location_id
      t.index :owner_id
      t.index [:parent_id, :retired]
      t.index [:model_id, :retired, :inventory_pool_id]
    end


    create_table :languages, id: :uuid do |t|
      t.string  :name
      t.string  :locale_name
      t.boolean :default
      t.boolean :active
    end
    change_table :languages do |t|
      t.index :name, :unique => true
      t.index [:active, :default]
    end


    create_table :locations, id: :uuid do |t|
      t.string     :room
      t.string     :shelf
      t.uuid :building_id
    end
    change_table :locations do |t|
      t.index :building_id
    end

    create_table :mail_templates, id: :uuid do |t|
      t.uuid :inventory_pool_id, null: true # NOTE when null, then is system-wide
      t.uuid :language_id
      t.string :name
      t.string :format
      t.text :body
    end

    # acts_as_dag
    create_table :model_group_links, id: :uuid do |t|
      t.uuid :parent_id, index: true
      t.uuid :child_id, index: true
      t.string  :label
    end

    create_table :model_groups, id: :uuid do |t|
      t.string   :type   # STI (single table inheritance)
      t.string   :name
      t.timestamps null: false
    end
    change_table :model_groups do |t|
      t.index :type
    end


    create_table :model_links, id: :uuid do |t|
      t.uuid :model_group_id
      t.uuid :model_id
      t.integer    :quantity,   :default => 1
    end
    change_table :model_links do |t|
      t.index [:model_id, :model_group_id]
      t.index [:model_group_id, :model_id]
    end


    create_table :models, id: :uuid do |t|
      t.string   :type,                :default => 'Model', :null => false # STI (single table inheritance)
      t.string   :manufacturer
      t.string   :product,             :null => false
      t.string   :version
      t.string   :description
      t.string   :internal_description
      t.string   :info_url
      t.decimal  :rental_price,        :precision => 8, :scale => 2
      t.integer  :maintenance_period,  :default => 0
      t.boolean  :is_package,          :default => false
      t.string   :technical_detail
      t.text     :hand_over_note
      t.text     :description
      t.text     :internal_description
      t.text     :technical_detail
      t.timestamps null: false
    end
    change_table :models do |t|
      t.index :type
      t.index :is_package
    end


    create_table :models_compatibles, :id => false do |t|
      t.uuid :model_id
      t.uuid :compatible_id
    end
    change_table :models_compatibles do |t|
      t.index :compatible_id
      t.index :model_id
    end


    create_table :notifications, id: :uuid do |t|
      t.uuid :user_id
      t.string     :title,      :default => ""
      t.datetime   :created_at, :null => false
    end
    change_table :notifications do |t|
      t.index :user_id
      t.index [:created_at, :user_id]
    end


    create_table :numerators, id: :uuid do |t|
      t.integer :item
    end


    create_table :options, id: :uuid do |t|
      t.uuid :inventory_pool_id
      t.string     :inventory_code
      t.string     :manufacturer
      t.string     :product,        :null => false
      t.string     :version
      t.decimal    :price,          :precision => 8, :scale => 2
    end
    change_table :options do |t|
      t.index :inventory_pool_id
    end

    create_table :partitions, id: :uuid do |t|
      t.uuid :model_id
      t.uuid :inventory_pool_id
      t.uuid :group_id, :null => true
      t.integer :quantity
    end
    change_table :partitions do |t|
      t.index [:model_id, :inventory_pool_id, :group_id], :unique => true
    end

    create_table :properties, id: :uuid do |t|
      t.uuid :model_id
      t.string     :key
      t.string     :value
    end
    change_table :properties do |t|
      t.index :model_id
    end

    create_table :purposes, id: :uuid do |t|
      t.text :description
    end


    create_table :settings, id: :uuid do |t|
      t.string  :smtp_address
      t.integer :smtp_port
      t.string  :smtp_domain
      t.string  :local_currency_string
      t.text    :contract_terms
      t.text    :contract_lending_party_string
      t.string  :email_signature
      t.string  :default_email
      t.boolean :deliver_order_notifications
      t.string  :user_image_url
      t.string  :ldap_config
      t.string  :logo_url
      t.string  :mail_delivery_method
      t.string  :smtp_username
      t.string  :smtp_password
      t.boolean :smtp_enable_starttls_auto, null: false, default: false
      t.string  :smtp_openssl_verify_mode, null: false, default: 'none'
      t.string  :time_zone, null: false, default: 'Bern'
      t.boolean :disable_manage_section, null: false, default: false
      t.text    :disable_manage_section_message
      t.boolean :disable_borrow_section, null: false, default: false
      t.text    :disable_borrow_section_message, :text
      t.integer :timeout_minutes, default: 30, null: false
    end


    create_table :suppliers, id: :uuid do |t|
      t.string   :name, :null => false
      t.timestamps null: false
    end
    change_table :suppliers do |t|
      t.index   :name, :unique => true
    end

    create_table :users, id: :uuid do |t|
      t.string     :login
      t.string     :firstname
      t.string     :lastname
      t.string     :phone
      t.uuid :authentication_system_id, :default => 1
      t.string     :unique_id
      t.string     :email
      t.string     :badge_id
      t.string     :address
      t.string     :city
      t.string     :zip
      t.string     :country
      t.uuid :language_id, :default => nil
      t.text       :extended_info  # serialized
      t.string     :settings, :limit => 1024
      t.uuid :delegator_user_id
      t.timestamps null: false
    end
    change_table :users do |t|
      t.index :authentication_system_id
    end

    create_table :workdays, id: :uuid do |t|
      t.uuid :inventory_pool_id
      t.boolean    :monday,        :default => true
      t.boolean    :tuesday,       :default => true
      t.boolean    :wednesday,     :default => true
      t.boolean    :thursday,      :default => true
      t.boolean    :friday,        :default => true
      t.boolean    :saturday,      :default => false
      t.boolean    :sunday,        :default => false
      t.integer    :reservation_advance_days,  :default => 0, :null => true
      t.text       :max_visits # serialized
    end
    change_table :workdays do |t|
      t.index :inventory_pool_id
    end

    begin
      add_foreign_key(:access_rights, :inventory_pools, on_delete: :cascade)
      add_foreign_key(:access_rights, :users)
      add_foreign_key(:accessories, :models, on_delete: :cascade)
      add_foreign_key(:attachments, :models, on_delete: :cascade)
      add_foreign_key(:database_authentications, :users, on_delete: :cascade)
      add_foreign_key(:groups, :inventory_pools)
      add_foreign_key(:holidays, :inventory_pools, on_delete: :cascade)
      add_foreign_key(:inventory_pools, :addresses)
      add_foreign_key(:items, :inventory_pools)
      add_foreign_key(:items, :inventory_pools, column: 'owner_id')
      add_foreign_key(:items, :items, column: 'parent_id', on_delete: :nullify)
      add_foreign_key(:items, :locations)
      add_foreign_key(:items, :models)
      add_foreign_key(:items, :suppliers)
      add_foreign_key(:locations, :buildings)
      add_foreign_key(:model_group_links, :model_groups, column: 'parent_id', on_delete: :cascade)
      add_foreign_key(:model_group_links, :model_groups, column: 'child_id', on_delete: :cascade)
      add_foreign_key(:model_links, :model_groups, on_delete: :cascade)
      add_foreign_key(:model_links, :models, on_delete: :cascade)
      add_foreign_key(:notifications, :users, on_delete: :cascade)
      add_foreign_key(:options, :inventory_pools)
      add_foreign_key(:partitions, :groups)
      add_foreign_key(:partitions, :inventory_pools)
      add_foreign_key(:partitions, :models, on_delete: :cascade)
      add_foreign_key(:properties, :models, on_delete: :cascade)
      add_foreign_key(:reservations, :inventory_pools)
        add_foreign_key(:reservations, :users)
        add_foreign_key(:reservations, :users, column: 'delegated_user_id')
        add_foreign_key(:reservations, :users, column: 'handed_over_by_user_id')
        add_foreign_key(:reservations, :items)
        add_foreign_key(:reservations, :models)
        add_foreign_key(:reservations, :options)
        add_foreign_key(:reservations, :purposes)
        add_foreign_key(:reservations, :contracts, on_delete: :cascade)
        add_foreign_key(:reservations, :users, column: 'returned_to_user_id')
        add_foreign_key(:users, :authentication_systems)
        add_foreign_key(:users, :languages)
        add_foreign_key(:users, :users, column: 'delegator_user_id', name: 'fkey_users_delegators')
        add_foreign_key(:workdays, :inventory_pools, on_delete: :cascade)

        # join tables
        add_foreign_key(:accessories_inventory_pools, :accessories)
        add_foreign_key(:accessories_inventory_pools, :inventory_pools)
        add_foreign_key(:delegations_users, :users)
        add_foreign_key(:delegations_users, :users, column: 'delegation_id')
        add_foreign_key(:groups_users, :groups)
        add_foreign_key(:groups_users, :users)
        add_foreign_key(:inventory_pools_model_groups, :inventory_pools)
        add_foreign_key(:inventory_pools_model_groups, :model_groups)
        add_foreign_key(:models_compatibles, :models)
        add_foreign_key(:models_compatibles, :models, column: 'compatible_id')

      rescue
        puts %Q(
        *************************************************************************************
        Error: the database has inconsistency issues caused by dead references.
        Please visit the consistency report at the following url: /admin/database/consistency
        After solving the issues, run again: rake db:migrate
        *************************************************************************************
      )

        raise
    end


    ############################################################

    create_table :audits, :force => true, id: :uuid do |t|
      t.column :auditable_id, :uuid
      t.column :auditable_type, :string
      t.column :associated_id, :uuid
      t.column :associated_type, :string
      t.column :user_id, :uuid
      t.column :user_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :audited_changes, :text
      t.column :version, :integer, :default => 0
      t.column :comment, :string
      t.column :remote_address, :string
      t.column :request_uuid, :string
      t.column :created_at, :datetime
    end
    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:associated_id, :associated_type], :name => 'associated_index'
    add_index :audits, [:user_id, :user_type], :name => 'user_index'
    add_index :audits, :request_uuid
    add_index :audits, :created_at

    create_table :hidden_fields, id: :uuid do |t|
      t.string :field_id
      t.uuid :user_id
    end

    create_table :fields, id: false do |t|
      t.primary_key :id, :string, limit: 50
      t.text :data # serialized
      t.boolean :active, default: true
      t.integer :position
    end

    change_table :fields do |t|
      t.index :active
    end

  end

end
