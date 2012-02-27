# coding: UTF-8

# Persona:  Normin
# Job:      Student
# Age:      21
#
#
# == Responsibilities
# 
# * Turning in work results during his studies.
# * Working on art or design.
#
# == Biography
#
# Normin has been studying Fine Arts at the Zürich University the of the Arts 
# one year. He has completed several courses on the way to his diploma.
#
# He is extraordinarily lazy and will not work with any of the university's
# systems unless forced to do so by a lecturer. 
# 
# == Goals
#
# 1. Spend as little time as possible uploading things to university systems.
# 2. Entering only the vaguest metadata required to finish a hand-in of
#    his university projects.
# 
# == Frustrations
#
# 1. Forgetting his username/password when trying to log in to university
#    systems.
# 2. Not finding the right place in the system to submit his work to.

module Persona
  
  class Normin
    
    NAME = "Normin"
    LASTNAME = "Normalo"
    PASSWORD = "password"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_person
        create_user
        create_dropbox_dir if  AppSettings.dropbox_root_dir
        create_resources
      end
    end

    def create_person
      @name = NAME
      @lastname = LASTNAME  
      @person = Factory(:person, firstname: @name, lastname: @lastname)
    end

    def create_user
      @crypted_password = Digest::SHA1.hexdigest(PASSWORD)
      @user = Factory(:user, :person => @person, :login => @name.downcase, :password => @crypted_password)
    end

    def create_dropbox_dir
      user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, @user.dropbox_dir_name)
      FileUtils.mkdir_p(user_dropbox_root_dir)
      File.new(user_dropbox_root_dir).chmod(0770)
    end

    def create_resources
      ## Abgabe zum Kurs Product Design
      set = Factory(:media_set, :user => @user)
      set.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Abgabe zum Kurs Product Design"}}})
        entry = Factory(:media_entry, :user => @user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Abgabe"}}})
        set.media_entries << entry
        entry = Factory(:media_entry, :user => @user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Konzept"}}})
        set.media_entries << entry
      permission = Factory(:userpermission, :media_resource => set, :user => Factory(:user))
      permission.view = true 
      permission.edit = false 
      permission.manage = false 
      permission.download = false
      permission.save 
        
      ## Fotografie Kurs HS 2010
      set = Factory(:media_set, :user => @user)
      set.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Fotografie Kurs HS 2010"}}})
        entry = Factory(:media_entry, :user => @user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Portrait"}}})
        set.media_entries << entry
        entry = Factory(:media_entry, :user => @user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Stilleben"}}})
        set.media_entries << entry
      set.view = true
      set.save
      
      # Meine Ausstellungen
      meine_ausstellungen = Factory(:media_set, :user => @user)
      meine_ausstellungen.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Meine Ausstellungen"}}})
      
      # Meine Highlights 2012
      meine_highlights = Factory(:media_set, :user => @user)
      meine_highlights.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Meine Highlights 2012"}}})
      
      ## Diplomarbeit 2012
      diplomarbeit_2012 = Factory(:media_set, :user => @user)
      diplomarbeit_2012.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Diplomarbeit 2012"}}})
      
      ## Dropbox
      dropbox = Factory(:media_set, :user => @user)
      dropbox.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Dropbox"}}})
        
        # Präsentation
        praesentation = Factory(:media_entry, :user => @user)
        praesentation.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Präsentation"}}})
        diplomarbeit_2012.media_entries << praesentation
        
        ## Ausstellungen
        ausstellungen = Factory(:media_set, :user => @user)
        ausstellungen.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Ausstellungen"}}})
        ausstellungen.parent_sets << [diplomarbeit_2012, meine_highlights, meine_ausstellungen, dropbox]
          
          ## Ausstellung Photos 1 bis 4
          4.times do |i|
            entry = Factory(:media_entry, :user => @user)
            entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Ausstellung Photo #{i}"}}})
            ausstellungen.media_entries << entry
          end
          
          ## Ausstellung ZHdK
          ausstellung_zhdk = Factory(:media_set, :user => @user)
          ausstellung_zhdk.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Ausstellung ZHdK"}}})
          ausstellungen.child_sets << ausstellung_zhdk
          
          ## Ausstellung Museum Zürich
          ausstellung_museum = Factory(:media_set, :user => @user)
          ausstellung_museum.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Ausstellung Museum Zürich"}}})
          ausstellungen.child_sets << ausstellung_museum
          
          ## Ausstellung Photo 5
          entry = Factory(:media_entry, :user => @user)
          entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Ausstellung Photo 5"}}})
          ausstellungen.media_entries << entry
          
          ## Ausstellung Gallerie Limatquai
          ausstellung_limatquai = Factory(:media_set, :user => @user)
          ausstellung_limatquai.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Ausstellung Gallerie Limatquai"}}})
          ausstellungen.child_sets << ausstellung_limatquai
          
        ## Konzepte
        konzepte = Factory(:media_set, :user => @user)
        konzepte.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Konzepte"}}})
        diplomarbeit_2012.child_sets << konzepte
          
          ## Erster Entwurf
          entry = Factory(:media_entry, :user => @user)
          entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Erster Entwurf"}}})
          konzepte.media_entries << entry
          
          ## Bedinungskonzept
          entry = Factory(:media_entry, :user => @user)
          entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Bedinungskonzept"}}})
          konzepte.media_entries << entry 
    end    
      
  end  
end
