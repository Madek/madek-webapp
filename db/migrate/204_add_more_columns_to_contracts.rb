class AddMoreColumnsToContracts < ActiveRecord::Migration[5.0]
  class ::MigrationPurpose < ActiveRecord::Base
    self.table_name = 'purposes'
  end

  class ::MigrationReservation < ActiveRecord::Base
    self.inheritance_column = nil
    self.table_name = 'reservations'
  end

  class ::MigrationPurpose < ActiveRecord::Base
    self.table_name = 'purposes'
  end

  class ::MigrationOldEmptyContract < ActiveRecord::Base
    self.table_name = 'old_empty_contracts'
  end

  class ::MigrationContract < ActiveRecord::Base
    self.table_name = 'contracts'
    has_many :reservations, foreign_key: :contract_id

    before_create do
      id = ::UUIDTools::UUID.random_create
      self.id = id
      b32 = ::Base32::Crockford.encode(id.to_i)
      self.compact_id ||= (3..26).lazy.map { |i| b32[0..i] } \
        .map { |c_id| !::MigrationContract.find_by(compact_id: c_id) && c_id } \
        .find(&:itself)
    end
  end

  def up
    add_column :contracts, :state, :text
    add_column :contracts, :user_id, :uuid
    add_column :contracts, :inventory_pool_id, :uuid
    add_column :contracts, :purpose, :text

    create_table :old_empty_contracts, id: :uuid do |t|
      t.text :compact_id, null: false
      t.text :note
      t.timestamps null: false
      t.index :compact_id, unique: true
    end

    execute <<-SQL
      ALTER TABLE contracts
      ADD CONSTRAINT check_valid_state
      CHECK (state IN ('open', 'closed'))
    SQL

    execute <<-SQL
      ALTER TABLE reservations
      ADD CONSTRAINT check_valid_status_and_contract_id
      CHECK (
        (status IN ('unsubmitted', 'submitted', 'approved', 'rejected') AND contract_id IS NULL) OR
        (status IN ('signed', 'closed') AND contract_id IS NOT NULL)
      )
    SQL

    ::MigrationContract.all.each do |contract|
      c_reservations = ::MigrationReservation.where(contract_id: contract.id)

      if c_reservations.empty?
        ::MigrationOldEmptyContract.create!(id: contract.id,
                                            compact_id: contract.compact_id,
                                            note: contract.note,
                                            created_at: contract.created_at,
                                            updated_at: contract.updated_at)
        execute "DELETE FROM contracts WHERE id = '#{contract.id}'"
      else
        user_ids = c_reservations.map(&:user_id).uniq
        inventory_pool_ids = c_reservations.map(&:inventory_pool_id).uniq

        statuses = c_reservations.map(&:status).uniq
        c_state = if Set.new(statuses) == Set.new(['signed', 'closed']) or statuses == ['signed']
                    'open'
                  elsif statuses == ['closed']
                    'closed'
                  else
                    raise 'unallowed reservation states for contract'
                  end

        purpose = \
          c_reservations
          .order(:start_date, :end_date, :created_at)
          .sort
          .map { |r| ::MigrationPurpose.find_by(id: r.purpose_id).try(&:description) }
          .uniq
          .delete_if(&:blank?)
          .join('; ')
        purpose ||= 'unknown purpose'

        if user_ids.count > 1
          if c_state == 'open'
            raise "several user_ids for open contract #{contract.id}"
          else
            Rails.logger.warn "several user_ids for closed contract #{contract.id}"
            c_reservations.group_by(&:user_id).each_pair do |user_id, reservations|
              new_contract = ::MigrationContract.create(user_id: user_id,
                                                        inventory_pool_id: inventory_pool_ids.first,
                                                        state: 'closed',
                                                        note: contract.note,
                                                        purpose: purpose,
                                                        created_at: contract.created_at,
                                                        updated_at: contract.updated_at)
              ::MigrationReservation
                .where(user_id: user_id, contract_id: contract.id)
                .update_all(contract_id: new_contract.id)
            end
            execute "DELETE FROM contracts WHERE id = '#{contract.id}'"
          end

        elsif inventory_pool_ids.count > 1
          if c_state == 'open'
            raise "several inventory_pool_ids for contract #{contract.id}"
          else
            Rails.logger.warn "several inventory_pool_ids for contract #{contract.id}"
            c_reservations.group_by(&:user_id).each_pair do |inventory_pool_id, reservations|
              new_contract = ::MigrationContract.create(user_id: user_ids.first,
                                                        inventory_pool_id: inventory_pool_id,
                                                        state: 'closed',
                                                        note: contract.note,
                                                        purpose: purpose,
                                                        created_at: contract.created_at,
                                                        updated_at: contract.updated_at)
              ::MigrationReservation
                .where(inventory_pool_id: inventory_pool_id, contract_id: contract.id)
                .update_all(contract_id: new_contract.id)
            end
            execute "DELETE FROM contracts WHERE id = '#{contract.id}'"
          end

        else
          contract.update_columns(purpose: purpose,
                                  state: c_state,
                                  user_id: user_ids.first,
                                  inventory_pool_id: inventory_pool_ids.first)
        end
      end
    end

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_reservations_contracts_state_consistency()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          NEW.state = 'closed' AND (
            SELECT count(*)
            FROM reservations
            WHERE contract_id = NEW.id AND status != 'closed') > 0
        )
        THEN
          RAISE EXCEPTION 'all reservations of a closed contract must be closed as well';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_reservations_contracts_state_consistency
      AFTER INSERT OR UPDATE
      ON contracts
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_reservations_contracts_state_consistency()
    SQL

    ########################################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_reservation_contract_inventory_pool_id_consistency()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          NEW.inventory_pool_id != (
            SELECT inventory_pool_id
            FROM contracts
            WHERE id = NEW.contract_id)
        )
        THEN
          RAISE EXCEPTION 'inventory_pool_id between reservation and contract is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_reservation_contract_inventory_pool_id_consistency
      AFTER INSERT OR UPDATE
      ON reservations
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_reservation_contract_inventory_pool_id_consistency()
    SQL

    ########################################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_reservation_contract_user_id_consistency()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          NEW.user_id != (
            SELECT user_id
            FROM contracts
            WHERE id = NEW.contract_id)
        )
        THEN
          RAISE EXCEPTION 'user_id between reservation and contract is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_reservation_contract_user_id_consistency
      AFTER INSERT OR UPDATE
      ON reservations
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_reservation_contract_user_id_consistency()
    SQL

    ########################################################################################

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_contract_has_at_least_one_reservation()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM reservations
          WHERE contract_id = NEW.id)
        THEN
          RAISE EXCEPTION 'contract must have at least one reservation';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_contract_has_at_least_one_reservation
      AFTER INSERT OR UPDATE
      ON contracts
      INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_contract_has_at_least_one_reservation()
    SQL

    ########################################################################################

    change_column :contracts, :state, :text, null: false
    change_column :contracts, :user_id, :uuid, null: false
    change_column :contracts, :inventory_pool_id, :uuid, null: false
    change_column :contracts, :purpose, :text, null: false

    add_foreign_key :contracts, :users
    add_foreign_key :contracts, :inventory_pools
  end

  def down
    execute 'ALTER TABLE contracts DROP CONSTRAINT check_valid_state'
    execute 'ALTER TABLE reservations DROP CONSTRAINT check_valid_status_and_contract_id'

    execute 'DROP TRIGGER trigger_check_reservations_contracts_state_consistency ON contracts'
    execute 'DROP FUNCTION IF EXISTS check_reservations_contracts_state_consistency()'

    execute 'DROP TRIGGER trigger_check_reservation_contract_inventory_pool_id_consistency ON reservations'
    execute 'DROP FUNCTION IF EXISTS check_reservation_contract_inventory_pool_id_consistency()'

    execute 'DROP TRIGGER trigger_check_reservation_contract_user_id_consistency ON reservations'
    execute 'DROP FUNCTION IF EXISTS check_reservation_contract_user_id_consistency()'

    execute 'DROP TRIGGER trigger_check_contract_has_at_least_one_reservation ON contracts'
    execute 'DROP FUNCTION IF EXISTS check_contract_has_at_least_one_reservation()'

    remove_column :contracts, :state
    remove_column :contracts, :inventory_pool_id
    remove_column :contracts, :user_id
  end
end
