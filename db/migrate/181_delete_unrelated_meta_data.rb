class DeleteUnrelatedMetaData < ActiveRecord::Migration
  def change

    [ 
      {join_table: 'meta_data_groups',
        type: 'MetaDatum::Groups'},
      {join_table: 'keywords',
        type: 'MetaDatum::Keywords'},
      {join_table: 'meta_data_licenses',
        type: 'MetaDatum::Licenses'},
      {join_table: 'meta_data_people',
       type: 'MetaDatum::People'},
      {join_table: 'meta_data_users',
       type: 'MetaDatum::Users'},
    ].each do |item|

      reversible do |dir|
        dir.up do 

          # the case when rows in the join table were deleted

          execute " CREATE OR REPLACE FUNCTION delete_empty_#{item[:join_table]}_after_delete_join()
                    RETURNS TRIGGER AS $$
                    BEGIN
                      IF (EXISTS (SELECT 1 FROM meta_data WHERE meta_data.id = OLD.meta_datum_id)
                          AND NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN  #{item[:join_table]} ON meta_data.id = #{item[:join_table]}.meta_datum_id
                                            WHERE meta_data.id = OLD.meta_datum_id)
                            ) THEN
                        DELETE FROM meta_data WHERE meta_data.id = OLD.meta_datum_id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$ language 'plpgsql'; "


          execute " CREATE CONSTRAINT TRIGGER trigger_delete_empty_#{item[:join_table]}_after_delete_join
                    AFTER DELETE 
                    ON #{item[:join_table]}
                    INITIALLY DEFERRED
                    FOR EACH ROW
                    EXECUTE PROCEDURE delete_empty_#{item[:join_table]}_after_delete_join()  "


          # the case when en empty meta datum was created 

          execute " CREATE OR REPLACE FUNCTION delete_empty_#{item[:join_table]}_after_insert()
                    RETURNS TRIGGER AS $$
                    BEGIN
                      IF ( NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN #{item[:join_table]} ON meta_data.id = #{item[:join_table]}.meta_datum_id
                                            WHERE meta_data.id = NEW.id)) THEN
                        DELETE FROM meta_data WHERE meta_data.id = NEW.id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$ language 'plpgsql'; "

          execute " CREATE CONSTRAINT TRIGGER trigger_delete_empty_#{item[:join_table]}_after_insert
                    AFTER INSERT
                    ON meta_data
                    INITIALLY DEFERRED
                    FOR EACH ROW
                    WHEN ( NEW.type = '#{item[:type]}' )
                    EXECUTE PROCEDURE delete_empty_#{item[:join_table]}_after_insert() "


        end

        dir.down do

          execute " DROP TRIGGER trigger_delete_empty_#{item[:join_table]}_after_insert ON meta_data "
          execute " DROP FUNCTION  IF EXISTS delete_empty_#{item[:join_table]}_after_insert() "

          execute " DROP TRIGGER trigger_delete_empty_#{item[:join_table]}_after_delete_join ON #{item[:join_table]} "
          execute " DROP FUNCTION  IF EXISTS delete_empty_#{item[:join_table]}_after_delete_join() "

        end

      end

    end
  end
end
