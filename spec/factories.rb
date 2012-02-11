# encoding: utf-8

module DataFactory 
  extend self

  def clear_data 
    ActiveRecord::Base.transaction do
      MediaEntry.all.each {|e| e.destroy}
      MediaSet.all.each {|e| e.destroy}
      MediaResource.all.each {|e| e.destroy}
      Grouppermission.all.each {|e| e.destroy}
      Userpermission.all.each {|e| e.destroy}
      User.all.each {|e| e.destroy}
    end
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


module FactoryHelper

  def self.rand_bool *opts
    bias = ((opts and opts[0]) or 0.5)
    raise "bias must be a real number within [0,1)" if bias < 0.0 or bias >= 1.0
    (rand < bias) ? true : false
  end

end

FactoryGirl.define do

  ### Meta

  factory :meta_context do
    name {Faker::Lorem.words.join("_")}
    is_user_interface true

    label {
      h = {}
      LANGUAGES.each do |lang|
        h[lang] = name
      end
      h
    }
  end

  ### Media ....

  factory :media_set_arc , :class => MediaSetArc do
  end

  factory :media_entry do
    user {User.find_random || (FactoryGirl.create :user)}
    media_file {FactoryGirl.create :media_file}

    view {FactoryHelper.rand_bool 1/10.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/10.0}
    manage {edit and FactoryHelper.rand_bool}
  end

  factory :media_entry_incomplete do
    user {User.find_random || (FactoryGirl.create :user)}
    uploaded_data  {
      f = "#{Rails.root}/app/assets/images/icons/eye.png"
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                             :tempfile=> File.new(f, "r"),
                                             :filename=> File.basename(f))
    } 

    view {FactoryHelper.rand_bool 1/10.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/10.0}
    manage {edit and FactoryHelper.rand_bool}
  end

  factory :media_file  do 
    uploaded_data  {
      f = "#{Rails.root}/app/assets/images/icons/eye.png"
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                             :tempfile=> File.new(f, "r"),
                                             :filename=> File.basename(f))
    } 
  end

  factory :media_resource do
    user {User.find_random || (FactoryGirl.create :user)}

    view {FactoryHelper.rand_bool 1/10.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/10.0}
    manage {edit and FactoryHelper.rand_bool}
  end

  factory :media_set do

    user {User.find_random || (FactoryGirl.create :user)}

    view {FactoryHelper.rand_bool 1/10.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/10.0}
    manage {edit and FactoryHelper.rand_bool}
    
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
