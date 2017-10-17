class AddReservationOrderConstraints < ActiveRecord::Migration[5.0]
  def up
    add_column :reservations, :order_id, :uuid

    ########################################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_item_line_state_consistency()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          (NEW.type = 'ItemLine' AND NEW.status = 'submitted' AND EXISTS (
            SELECT 1
            FROM orders
            WHERE id = NEW.order_id AND state <> 'submitted')) OR
          (NEW.type = 'ItemLine' AND NEW.status = 'rejected' AND EXISTS (
            SELECT 1
            FROM orders
            WHERE id = NEW.order_id AND state <> 'rejected')) OR
          (NEW.type = 'ItemLine' AND NEW.status IN ('approved', 'signed', 'closed') AND EXISTS (
            SELECT 1
            FROM orders
            WHERE id = NEW.order_id AND state <> 'approved'))
        )
        THEN
          RAISE EXCEPTION 'state between item line and order is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_item_line_state_consistency
      AFTER INSERT OR UPDATE
      ON reservations
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_item_line_state_consistency()
    SQL

    ########################################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_option_line_state_consistency()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          NEW.type = 'OptionLine' AND EXISTS (
            SELECT 1
            FROM orders
            WHERE id = NEW.order_id)
        )
        THEN
          RAISE EXCEPTION 'option line cannot belong to an order';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_option_line_state_consistency
      AFTER INSERT OR UPDATE
      ON reservations
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_option_line_state_consistency()
    SQL

    ########################################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_reservation_order_user_id_consistency()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          NEW.user_id != (
            SELECT user_id
            FROM orders
            WHERE id = NEW.order_id)
        )
        THEN
          RAISE EXCEPTION 'user_id between reservation and order is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_reservation_order_user_id_consistency
      AFTER INSERT OR UPDATE
      ON reservations
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_reservation_order_user_id_consistency()
    SQL

    ########################################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_reservation_order_inventory_pool_id_consistency()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          NEW.inventory_pool_id != (
            SELECT inventory_pool_id
            FROM orders
            WHERE id = NEW.order_id)
        )
        THEN
          RAISE EXCEPTION 'inventory_pool_id between reservation and order is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_reservation_order_inventory_pool_id_consistency
      AFTER INSERT OR UPDATE
      ON reservations
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_reservation_order_inventory_pool_id_consistency()
    SQL

    ########################################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION delete_empty_order()
      RETURNS TRIGGER AS $$
      DECLARE
        result text;
      BEGIN
        IF (
          NOT EXISTS (
            SELECT 1
            FROM reservations
            WHERE reservations.order_id = OLD.order_id
        ))
        THEN
          DELETE FROM orders WHERE orders.id = OLD.order_id;
        END IF;

        RETURN OLD;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_delete_empty_order
      AFTER DELETE
      ON reservations
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE delete_empty_order()
    SQL

    ########################################################################################

  end

  def down
    remove_column :reservations, :order_id

    execute 'DROP TRIGGER trigger_check_item_line_state_consistency ON reservations'
    execute 'DROP FUNCTION IF EXISTS check_item_line_state_consistency()'

    execute 'DROP TRIGGER trigger_check_option_line_state_consistency ON reservations'
    execute 'DROP FUNCTION IF EXISTS check_option_line_state_consistency()'

    execute 'DROP TRIGGER trigger_check_reservation_order_user_id_consistency ON reservations'
    execute 'DROP FUNCTION IF EXISTS check_reservation_order_user_id_consistency()'

    execute 'DROP TRIGGER trigger_check_reservation_order_inventory_pool_id_consistency ON reservations'
    execute 'DROP FUNCTION IF EXISTS check_reservation_order_inventory_pool_id_consistency()'

    execute 'DROP TRIGGER trigger_delete_empty_order ON reservations'
    execute 'DROP FUNCTION IF EXISTS delete_empty_order()'
  end
end
