class ClosedReservationsContractStateValidation < ActiveRecord::Migration[5.0]
  class ::MigrationReservation < ActiveRecord::Base
    self.inheritance_column = nil
    self.table_name = 'reservations'
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
    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_closed_reservations_contract_state()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          NEW.status = 'closed' AND
          NOT EXISTS(
            SELECT 1
            FROM reservations
            WHERE contract_id = NEW.contract_id AND status != 'closed')
          ) AND
          (SELECT state FROM contracts WHERE contracts.id = NEW.contract_id) != 'closed'
        THEN
          RAISE EXCEPTION 'If all reservations are closed then the contract must be closed as well';
        END IF;

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER trigger_check_closed_reservations_contract_state
      AFTER INSERT OR UPDATE
      ON reservations
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW
      EXECUTE PROCEDURE check_closed_reservations_contract_state()
    SQL

    contracts = \
      ::MigrationContract
        .where(state: :open)
        .where(<<-SQL)
          NOT EXISTS (
            SELECT 1
            FROM reservations
            WHERE reservations.contract_id = contracts.id
              AND reservations.status != 'closed'
            )
        SQL

    contracts.update_all(state: :closed)
  end

  def down
    execute 'DROP TRIGGER trigger_check_closed_reservations_contract_state ON reservations'
    execute 'DROP FUNCTION IF EXISTS check_closed_reservations_contract_state()'
  end
end
