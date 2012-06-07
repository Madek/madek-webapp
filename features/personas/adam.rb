# coding: UTF-8

# Persona:  Adam Admin
# Job:      System administrator
# Age:      24
#
#
# == Responsibilities
# 
# * Setting up and maintaining the Rails server that runs MAdeK.
# * Administration of system-wide settings of MAdeK through the configuration
#   file and through the admin interface, logged in as admin.
# * Providing storage systems for MAdeK.
#
# == Biography
#
# Adam has been working in the IT department of this university for 5 years.
# He has a good knowledge of Apache, Phusion Passenger, Ruby and other Rails-
# related technologies.
# 
# == Goals
#
# 1. Spend as little time as possible on MAdeK administration.
# 2. Easily deploy new versions of MAdeK.
# 3. Reacting quickly to user requests for MAdeK (e.g. increasing storage
#    space, changing a configuration item).
# 
# == Frustrations
#
# 1. "Sorry, something went wrong!" messages.
# 2. Angry users.
# 3. Not being able to give the users the features they're asking for, 
#    because they're impossible to configure. 

module Persona
  
  class Adam
    
    @@name = "Adam"
    @@lastname = "Admin"
    @@password = "password"
    
    @@ftp_dropbox_root_dir = "#{Rails.root}/tmp/dropbox"
    @@ftp_dropbox_server = "ftp.dropbox.test"
    @@ftp_dropbox_user = "test"
    @@ftp_dropbox_password  = "password"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_person
        create_user
        add_to_admin_group
        setup_dropbox
        create_zhdk_group
        create_contexts
      end
    end
    
    def create_person
      @name = @@name
      @lastname = @@lastname  
      @person = Factory.create(:person, firstname: @name, lastname: @lastname)
    end
    
    def create_user
      @crypted_password = Digest::SHA1.hexdigest(@@password)
      @user = Factory.create(:user, :person => @person, :login => @name.downcase, :password => @crypted_password)
    end

    def add_to_admin_group
      Group.find_or_create_by_name("Admin").users << @user
    end
    

    def setup_dropbox
      AppSettings.dropbox_root_dir = @@ftp_dropbox_root_dir
      AppSettings.ftp_dropbox_server = @@ftp_dropbox_server
      AppSettings.ftp_dropbox_user = @@ftp_dropbox_user
      AppSettings.ftp_dropbox_password = @@ftp_dropbox_password
    end
    
    def create_contexts
      # TODO is it correct that the admin creates all these contexts?
      # TODO create with meta_keys
      name = "Landschaftsvisualisierung"
      context = if MetaContext.exists?(:name => name)
        MetaContext.send(name)
      else
        Factory.create(:meta_context, :name => name, :meta_context_group => MetaContextGroup.find_by_name("Kontexte"))
      end

      title = "Landschaften"
      media_set1 = Factory.create(:media_set, :user => @user, :view => true)
      media_set1.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set1.individual_contexts << context

      
      # TODO create with meta_keys
      name = "Zett"
      context = if MetaContext.exists?(:name => name)
        MetaContext.send(name)
      else
        Factory.create(:meta_context, :name => name, :meta_context_group => MetaContextGroup.find_by_name("Kontexte"))
      end

      title = "Zett"
      media_set2 = Factory.create(:media_set, :user => @user)
      media_set2.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set2.individual_contexts << context
      media_set2.grouppermissions.create(group: Group.find_by_name("ZHdK"), view: true)

      # TODO create with meta_keys
      name = "Games"
      context = if MetaContext.exists?(:name => name)
        MetaContext.send(name)
      else
        Factory.create(:meta_context, :name => name, :meta_context_group => MetaContextGroup.find_by_name("Kontexte"))
      end

      title = "Zett über Landschaften"
      media_set3 = Factory.create(:media_set, :user => @user)
      media_set3.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set3.individual_contexts << context
      media_set3.parent_sets << [media_set1, media_set2]      
    end
    
    def create_zhdk_group
      Group.find_or_create_by_name("ZHdK")
    end
    
  end  
end
