class CreateAndMigrateRooms < ActiveRecord::Migration
  class MigrationItem < ActiveRecord::Base
    self.table_name = 'items'
  end

  class MigrationRoom < ActiveRecord::Base
    self.table_name = 'rooms'
  end

  class MigrationBuilding < ActiveRecord::Base
    self.table_name = 'buildings'
  end

  class MigrationLocation < ActiveRecord::Base
    self.table_name = 'locations'
    belongs_to :item, class_name: MigrationItem
  end

  def up

    ######################## CREATE ROOMS AND UPDATE LOCATIONS ####################

    create_table :rooms, id: :uuid do |t|
      t.string :name, null: false
      t.text :description
      t.uuid :building_id, null: false
      t.boolean :general, null: false, default: false
    end

    add_foreign_key :rooms, :buildings, on_delete: :cascade

    execute <<-SQL.strip_heredoc
      CREATE UNIQUE INDEX rooms_unique_name_and_building_id
      ON rooms ((lower(name) || ' ' || building_id))
    SQL

    execute <<-SQL.strip_heredoc
      ALTER TABLE rooms
      ADD CONSTRAINT check_non_empty_name CHECK (name !~ '^\\s*$')
    SQL

    add_column :locations, :room_id, :uuid
    add_foreign_key :locations, :rooms

    MigrationBuilding.create!(
      id: ::Leihs::Constants::GENERAL_BUILDING_UUID,
      name: 'general building'
    )

    general_general_room = MigrationRoom.create!(
      building_id: ::Leihs::Constants::GENERAL_BUILDING_UUID,
      name: 'general room',
      general: true
    )

    execute <<-SQL.strip_heredoc
      UPDATE locations
      SET building_id = '#{::Leihs::Constants::GENERAL_BUILDING_UUID}'
      WHERE building_id IS NULL
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE locations
      SET room = 'general room'
      WHERE room IS NULL
         OR room ~ '^\\s*$'
    SQL

    MigrationLocation.all.each do |location|
      room = \
        MigrationRoom
        .where('lower(name) = lower(?)', location.room)
        .where(building_id: location.building_id)
        .first
      room_attrs = { name: location.room,
                     building_id: location.building_id }
      room_attrs.merge!(general: true) if location.room == 'general room'
      room ||= MigrationRoom.create!(room_attrs)

      location.update_attributes!(room_id: room.id)
    end

    ######################## MOVE LOCATIONS TO ITEMS ##############################

    add_column :items, :shelf, :text

    execute <<-SQL.strip_heredoc
      UPDATE items
      SET shelf = (
        SELECT locations.shelf
        FROM locations
        INNER JOIN items i ON i.location_id = locations.id
        WHERE i.id = items.id
      )
    SQL

    add_column :items, :room_id, :uuid

    execute <<-SQL.strip_heredoc
      UPDATE items
      SET room_id = (
        SELECT locations.room_id
        FROM locations
        WHERE items.location_id = locations.id
      )
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE items
      SET room_id = '#{general_general_room.id}'
      WHERE room_id IS NULL OR location_id is NULL
    SQL

    add_foreign_key :items, :rooms

    ################### MIGRATE PROCUREMENT REQUESTS ##############################

    add_column :procurement_requests, :room_id, :uuid

    execute <<-SQL.strip_heredoc
      UPDATE procurement_requests
      SET room_id = (
        SELECT locations.room_id
        FROM locations
        WHERE procurement_requests.location_id = locations.id
      )
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE procurement_requests
      SET room_id = '#{general_general_room.id}'
      WHERE room_id IS NULL
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE procurement_requests
      SET inspection_comment = (
        CASE WHEN inspection_comment IS NULL THEN ('Point of delivery: ' || location_name)
             ELSE (inspection_comment || '; Point of delivery: ' || location_name)
        END
      )
      WHERE location_id IS NULL
    SQL

    add_foreign_key :procurement_requests, :rooms

    ################### CREATE GENERAL ROOMS FOR BUILDINGS WITHOUT GENERAL ROOMS ########

    MigrationBuilding.all.each do |building|
      unless MigrationRoom.find_by(building_id: building.id, general: true)
        MigrationRoom.create(name: 'general room',
                             building_id: building.id,
                             general: true)
      end
    end

    ###############################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_general_building_id_for_general_room()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          OLD.general IS TRUE
          AND OLD.building_id != NEW.building_id
          )
          THEN RAISE EXCEPTION
            'Building ID cannot be changed for a general room';
        END IF;
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_general_building_id_for_general_room
      AFTER UPDATE
      ON rooms
      FOR EACH ROW
      EXECUTE PROCEDURE check_general_building_id_for_general_room()
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION ensure_general_building_cannot_be_deleted()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (OLD.id = '#{::Leihs::Constants::GENERAL_BUILDING_UUID}')
          THEN RAISE EXCEPTION
            'Building with ID = #{::Leihs::Constants::GENERAL_BUILDING_UUID} cannot be deleted.';
        END IF;
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_ensure_general_building_cannot_be_deleted
      AFTER DELETE
      ON buildings
      FOR EACH ROW
      EXECUTE PROCEDURE ensure_general_building_cannot_be_deleted()
    SQL

    execute <<-SQL
      CREATE UNIQUE INDEX rooms_unique_building_id_general_true
      ON rooms (building_id, general)
      WHERE general IS TRUE
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION ensure_general_room_cannot_be_deleted()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          OLD.general IS TRUE
          AND EXISTS (SELECT 1 FROM buildings WHERE id = OLD.building_id)
          )
          THEN RAISE EXCEPTION
            'There must be a general room for every building.';
        END IF;
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_ensure_general_room_cannot_be_deleted
      AFTER DELETE
      ON rooms
      FOR EACH ROW
      EXECUTE PROCEDURE ensure_general_room_cannot_be_deleted()
    SQL

    ###############################################################################

    change_column_null :items, :room_id, false
    change_column_null :procurement_requests, :room_id, false

    ##################### DROP LOCATIONS ##########################################

    remove_column :items, :location_id
    remove_column :procurement_requests, :location_id
    drop_table :locations

    ##################### DROP OLD LOCATION FIELDS ################################

    execute <<-SQL.strip_heredoc
      DELETE FROM fields WHERE id IN ('location_building_id', 'location_room', 'location_shelf')
    SQL

    ###############################################################################
  end
end
