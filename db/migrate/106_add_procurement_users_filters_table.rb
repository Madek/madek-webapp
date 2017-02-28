class AddProcurementUsersFiltersTable < ActiveRecord::Migration
  def change
    create_table :procurement_users_filters, id: :uuid do |t|
      t.uuid :user_id, foreign_key: true
      t.json :filter
    end

    add_index :procurement_users_filters, :user_id, unique: true

    execute <<~SQL
      CREATE OR REPLACE FUNCTION delete_procurement_users_filters_after_procurement_accesses()
      RETURNS TRIGGER AS $$
      BEGIN
        IF
          (EXISTS
            (SELECT 1
             FROM procurement_users_filters
             WHERE procurement_users_filters.user_id = OLD.user_id)
           AND NOT EXISTS
            (SELECT 1
             FROM procurement_accesses
             WHERE procurement_accesses.user_id = OLD.user_id))
        THEN
          DELETE FROM procurement_users_filters
          WHERE procurement_users_filters.user_id = OLD.user_id;
        END IF;
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<~SQL
      CREATE CONSTRAINT TRIGGER trigger_delete_procurement_users_filters_after_procurement_accesses
      AFTER DELETE
      ON procurement_accesses
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE delete_procurement_users_filters_after_procurement_accesses()
    SQL

    execute <<~SQL
      CREATE OR REPLACE FUNCTION delete_procurement_users_filters_after_users()
      RETURNS TRIGGER AS $$
      BEGIN
        IF
          (EXISTS
            (SELECT 1
             FROM procurement_users_filters
             WHERE procurement_users_filters.user_id = OLD.id))
        THEN
          DELETE FROM procurement_users_filters
          WHERE procurement_users_filters.user_id = OLD.id;
        END IF;
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<~SQL
      CREATE CONSTRAINT TRIGGER trigger_delete_procurement_users_filters_after_users
      AFTER DELETE
      ON users
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE delete_procurement_users_filters_after_users()
    SQL
  end
end
