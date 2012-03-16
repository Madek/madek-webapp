# encoding: utf-8

module DataFactory 
  extend self

  def reset_data 
    ActiveRecord::Base.transaction do
      MediaResource.destroy_all
      Grouppermission.destroy_all
      Group.destroy_all
      Userpermission.destroy_all
      User.destroy_all
      MetaContextGroup.destroy_all
    end
    MetaHelper.import_initial_metadata
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

FactoryGirl.define do

  ### Media ....

  factory :media_set_arc , :class => MediaSetArc do
  end

  factory :media_file  do 
    uploaded_data  {
      f = "#{Rails.root}/features/data/images/berlin_wall_01.jpg"
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                             :tempfile=> File.new(f, "r"),
                                             :filename=> File.basename(f))
    } 
  end


  ### Permissions ...


  factory :permission do
    subject {FactoryHelper.rand_bool ? User.find_random : Group.find_random }
    media_resource { MediaResource.find_random }
    after_build do |perm| 
      permissions = {:view => FactoryHelper.rand_bool, :edit => FactoryHelper.rand_bool, :manage => FactoryHelper.rand_bool, :download => FactoryHelper.rand_bool}
      perm.set_actions permissions 
    end
  end
 



  factory :userpermission do
    view {FactoryHelper.rand_bool 1/4.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/4.0}
    manage {edit and FactoryHelper.rand_bool}
    user {User.find_random || (FactoryGirl.create :user)} 

    media_resource do 
      MediaResource.find_random || 
        begin
          if FactoryHelper.rand_bool 1.0/3
            FactoryGirl.create :media_set
          else
            FactoryGirl.create :media_entry
          end
        end
    end

  end


  factory :grouppermission do

    view {FactoryHelper.rand_bool 1/4.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/4.0}
    manage {edit and FactoryHelper.rand_bool}

    group {Group.find_random || (FactoryGirl.create :group)}

    media_resource do 
      if FactoryHelper.rand_bool 1.0/3
        FactoryGirl.create :media_set
      else
        FactoryGirl.create :media_entry
      end
    end

  end



  ### Groups, Users, ....

  factory :group do
    name {Faker::Name.last_name}
  end

  factory :person do
    lastname {Faker::Name.last_name}
    firstname {Faker::Name.first_name}
  end

  factory :user do |n| 
    person {FactoryGirl.create :person}
    email {Faker::Internet.email}
    login {Faker::Internet.user_name + "_#{UUIDTools::UUID.random_create.to_s.first 5}"}
    usage_terms_accepted_at {Time.now}
  end

end
