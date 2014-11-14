class CheckMediaResourceAspectWithPgTrigger < ActiveRecord::Migration
  def change

    reversible do |dir|

      #
      # These triggers and checks are disabled; the new plan is to remove the resource table entirely 
      #

      return ### DISABLED 

      dir.up do 


        %w( media_entries collections filter_sets).each do |table_name|

          execute %[
            CREATE OR REPLACE FUNCTION check_#{table_name}_sibbling()
            RETURNS TRIGGER AS $$
            DECLARE
              resources_sibblings_count int;
            BEGIN
                IF (TG_OP = 'DELETE') THEN
                
                  IF (SELECT count(*) FROM resources WHERE id = OLD.id ) <> 0 THEN
                    RAISE EXCEPTION 'The resource with % should have been deleted with its sibling row in #{table_name} ', OLD.id ;
                  END IF; 

                ELSE

                  IF (SELECT count(*) FROM #{table_name}
                    JOIN resources ON resources.id = #{table_name}.id
                    WHERE resources.id = NEW.id
                    ) <> 1 THEN
                    RAISE EXCEPTION 'Every row in #{table_name} with id % must have exactly one and only one resource sibbling.', NEW.id ;
                  END IF; 

                  resources_sibblings_count := (SELECT count(collections.id) + count(media_entries.id) + count(filter_sets.id)
                       FROM resources
                       LEFT OUTER JOIN media_entries ON resources.id = media_entries.id
                       LEFT OUTER JOIN collections ON resources.id = collections.id
                       LEFT OUTER JOIN filter_sets ON resources.id = filter_sets.id
                       WHERE resources.id = NEW.id
                       GROUP BY resources.id, collections.id, media_entries.id, filter_sets.id ); 

                  IF  resources_sibblings_count <> 1 THEN
                    RAISE EXCEPTION 'Every row in resources with id % must have exactly one sibbling but this has %.', NEW.id, resources_sibblings_count;
                  END IF; 

                END IF;
                  
                RETURN NEW;

            END;
            $$ language 'plpgsql'; ]

          execute %[ CREATE CONSTRAINT TRIGGER check_#{table_name}_sibbling
                      AFTER INSERT OR UPDATE OR DELETE
                      ON #{table_name}
                      INITIALLY DEFERRED 
                      FOR EACH ROW 
                      EXECUTE PROCEDURE check_#{table_name}_sibbling() ]
        end


        resources_delete_checks = 
          %w( media_entries collections filter_sets).map{ |table_name|
          %[ IF (SELECT count(*) FROM #{table_name} WHERE id = OLD.id ) <> 0 THEN 
                 RAISE EXCEPTION 'The sibling in #{table_name} of the resource with % should have been deleted too', OLD.id ;
             END IF; ]}.join("\n")


        execute %[
          CREATE OR REPLACE FUNCTION check_resources_sibbling()
          RETURNS TRIGGER AS $$
          DECLARE
            resources_sibblings_count int;
          BEGIN
              IF (TG_OP = 'DELETE') THEN

                #{resources_delete_checks} 
                 
              ELSE

                resources_sibblings_count := (SELECT count(collections.id) + count(media_entries.id) + count(filter_sets.id)
                     FROM resources
                     LEFT OUTER JOIN media_entries ON resources.id = media_entries.id
                     LEFT OUTER JOIN collections ON resources.id = collections.id
                     LEFT OUTER JOIN filter_sets ON resources.id = filter_sets.id
                     WHERE resources.id = NEW.id
                     GROUP BY resources.id, collections.id, media_entries.id, filter_sets.id ); 

                IF  resources_sibblings_count <> 1 THEN
                  RAISE EXCEPTION 'Every row in resources with id % must have exactly one sibbling but this has %.', NEW.id, resources_sibblings_count;
                END IF; 

              END IF;

              RETURN NEW;

          END;
          $$ language 'plpgsql'; ]

        execute %[ CREATE CONSTRAINT TRIGGER check_resources_sibbling
                    AFTER INSERT OR UPDATE OR DELETE
                    ON resources
                    INITIALLY DEFERRED 
                    FOR EACH ROW 
                    EXECUTE PROCEDURE check_resources_sibbling() ]
      end

      dir.down do

        execute %[ DROP TRIGGER check_resources_sibbling ON resources ]
        execute %[ DROP FUNCTION IF EXISTS check_resources_sibbling() ]

        %w( media_entries collections filter_sets).each do |table_name|
          execute %[ DROP TRIGGER check_#{table_name}_sibbling ON #{table_name} ]
          execute %[ DROP FUNCTION IF EXISTS check_#{table_name}_sibbling() ]
        end

      end
    end


  end
end
