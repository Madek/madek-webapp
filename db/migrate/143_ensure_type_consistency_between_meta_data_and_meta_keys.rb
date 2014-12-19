class EnsureTypeConsistencyBetweenMetaDataAndMetaKeys < ActiveRecord::Migration
  def change

    reversible do |dir|
      dir.up do

        execute %{

          CREATE OR REPLACE FUNCTION check_meta_data_meta_key_type_consistency()
          RETURNS TRIGGER AS $$
          BEGIN

            IF EXISTS (SELECT 1 FROM meta_keys 
              JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
              WHERE meta_data.id = NEW.id
              AND meta_keys.meta_datum_object_type <> meta_data.type) THEN
                RAISE EXCEPTION 'The types of related meta_data and meta_keys must be identical';
            END IF;

            RETURN NEW;
          END;
          $$ language 'plpgsql'; }
              

        execute %[ CREATE CONSTRAINT TRIGGER trigger_meta_data_meta_key_type_consistency
                    AFTER INSERT OR UPDATE 
                    ON meta_data 
                    INITIALLY DEFERRED
                    FOR EACH ROW
                    EXECUTE PROCEDURE check_meta_data_meta_key_type_consistency()  ]



        execute %{

          CREATE OR REPLACE FUNCTION check_meta_key_meta_data_type_consistency()
          RETURNS TRIGGER AS $$
          BEGIN

            IF EXISTS (SELECT 1 FROM meta_keys 
              JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
              WHERE meta_keys.id = NEW.id
              AND meta_keys.meta_datum_object_type <> meta_data.type) THEN
                RAISE EXCEPTION 'The types of related meta_data and meta_keys must be identical';
            END IF;

            RETURN NEW;
          END;
          $$ language 'plpgsql'; }
              

        execute %[ CREATE CONSTRAINT TRIGGER trigger_meta_key_meta_data_type_consistency 
                    AFTER INSERT OR UPDATE 
                    ON meta_keys
                    INITIALLY DEFERRED
                    FOR EACH ROW
                    EXECUTE PROCEDURE check_meta_key_meta_data_type_consistency()  ]

      end

      dir.down do

        execute %( DROP TRIGGER trigger_meta_key_meta_data_type_consistency ON meta_keys )
 
        execute %{ DROP FUNCTION  IF EXISTS check_meta_key_meta_data_type_consistency() }

        execute %( DROP TRIGGER trigger_meta_data_meta_key_type_consistency ON meta_data)

        execute %{ DROP FUNCTION IF EXISTS check_meta_data_meta_key_type_consistency () }

      end
    end

  end
end
