# encoding: utf-8

module DataFactory 
  extend self

  def reset_data 
    DatabaseCleaner.clean_with :truncation
    DevelopmentHelpers::MetaDataPreset.load_minimal_yaml
  end

  def create_permission_migration_dataset
    ActiveRecord::Base.transaction do
      (1..50).each {FactoryGirl.create :user}
      (1..50).each {FactoryGirl.create :media_entry}
      (1..50).each {FactoryGirl.create :media_set}
      (1..10).each {FactoryGirl.create :permission}
    end
  end

  def create_small_dataset 
    ActiveRecord::Base.transaction do
      (1..10).each {FactoryGirl.create :user}
      (1..50).each {FactoryGirl.create :media_entry}
      (1..50).each {FactoryGirl.create :media_set}
      (1..25).each do 
        mr = MediaResource.find_random
        u =  MediaResource.find_random
        unless Userpermission.where(user: u).where(media_resource: mr)
          FactoryGirl.create(:userpermission, user: u, media_resource: mr ) 
        end
      end
    end
  end

end

class ActiveRecord::Base


  if SQLHelper.adapter_is_mysql? 

    # general strategy:
    # 1. see if there is something to find, if not return nil
    # 2. select a random row return and return it if not nil (i.e. hit a gap) otherwise recurse

    def self.find_random 
      if not (find_by_sql "SELECT * FROM #{table_name} LIMIT 1").first 
        nil
      else
        (find_by_sql "SELECT t.* FROM #{table_name} t, (SELECT @id := (FLOOR((MAX(id) - MIN(id) + 1) * RAND()) + MIN(id)) FROM #{table_name} ) t2 WHERE t.id = @id;").first  
      end
    end

  elsif SQLHelper.adapter_is_postgresql? 

    def self.find_random 
      if not (find_by_sql "SELECT * FROM #{table_name} LIMIT 1").first 
        nil
      else
        (find_by_sql "SELECT * from #{table_name} WHERE id = (SELECT floor((max(id) - min(id) + 1) * random())::int  + min(id) from #{table_name});").first 
      end
    end

  else

    def self.find_random
      raise "this function is not implemented for the currently used db adapter"
    end

  end


  # this is in O(n) and hence not very efficient, there seems to be no way to make this better 
  def self.find_nth num
    (find_by_sql "SELECT * from #{table_name} LIMIT 1 OFFSET #{num};").first
  end


end


module FactoryHelper

  def self.rand_bool *opts
    bias = ((opts and opts[0]) or 0.5)
    raise "bias must be a real number within [0,1)" if bias < 0.0 or bias >= 1.0
    (rand < bias) ? true : false
  end

end
