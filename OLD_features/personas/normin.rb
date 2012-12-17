# coding: UTF-8
# Persona:  Normin
# Job:      Student
# Age:      21
#
# User_Id:  113868
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
    
    @@name = "Normin"
    @@lastname = "Normalo"
    @@password = "password"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_person
        create_user
        create_dropbox_dir if  AppSettings.dropbox_root_dir
        
        # NORMINS'S GROUPS
        create_diplomarbeitsgruppe
        join_zhdk_group
        
        # NORMIN'S RESOURCES
        create_abgabe_zum_kurs_product_design
        create_fotografie_kurs_hs_2010
        create_meine_ausstellungen
        create_meine_highlights
        create_dropbox_set
        create_diplomarbeit_2012
      end
    end

    def create_person
      @name = @@name
      @lastname = @@lastname  
      @person = FactoryGirl.create(:person, firstname: @name, lastname: @lastname)
    end

    def create_user
      @user = FactoryGirl.create(:user, person: @person, login: @name.downcase, password: @@password)
    end

    def create_dropbox_dir
      user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, @user.dropbox_dir_name)
      FileUtils.mkdir_p(user_dropbox_root_dir)
      File.new(user_dropbox_root_dir).chmod(0770)
    end
    
    def create_diplomarbeitsgruppe
      @diplomarbeitsgruppe = FactoryGirl.create(:group,
                                     name: "Diplomarbeitsgruppe",
                                     type: "Group",
                                     users: [@user])
    end
    
    def join_zhdk_group
      @zhdk_group= Group.find_or_create_by_name("ZHdK")
      @zhdk_group.users << @user
    end
    
    def create_abgabe_zum_kurs_product_design # Abgabe zum Kurs Product Design
      @abgabe_zum_kurs_product_design_set = FactoryGirl.create(:media_set,
                                                    user: @user, 
                                                    meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Abgabe zum Kurs Product Design"}})
      FactoryGirl.create(:userpermission, 
              media_resource: @abgabe_zum_kurs_product_design_set, 
              user: Persona.create(:petra), view: true, edit: false, manage: false, download: false)

      FactoryGirl.create(:grouppermission,
              group: @diplomarbeitsgruppe,
              media_resource: @abgabe_zum_kurs_product_design_set,
              view: true, edit:false, manage: false, download: true)


      @abgabe_zum_kurs_product_design_abgabe = FactoryGirl.create(:media_entry, 
                                                       user: @user, 
                                                       parent_sets: [@abgabe_zum_kurs_product_design_set], 
                                                       meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Abgabe"}})
      @abgabe_zum_kurs_product_design_konzepte = FactoryGirl.create(:media_entry, 
                                                         user: @user, 
                                                         parent_sets: [@abgabe_zum_kurs_product_design_set], 
                                                         meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Konzepte"}})    
    end
    
    def create_fotografie_kurs_hs_2010 # Fotografie Kurs HS 2010
      @fotografie_kurs_hs_2010_set = FactoryGirl.create(:media_set, 
                                             user: @user,
                                             view: true,
                                             meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Fotografie Kurs HS 2010"}})
      @fotografie_kurs_hs_2010_portrait = FactoryGirl.create(:media_entry,
                                                  user: @user, 
                                                  parent_sets: [@fotografie_kurs_hs_2010_set], 
                                                  meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Portrait"}})
      @fotografie_kurs_hs_2010_stillleben = FactoryGirl.create(:media_entry, 
                                                    user: @user, 
                                                    parent_sets: [@fotografie_kurs_hs_2010_set], 
                                                    meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Stilleben"}})
      arc = @fotografie_kurs_hs_2010_set.out_arcs.where(:child_id => @fotografie_kurs_hs_2010_stillleben.id).first.update_attributes({:highlight => true})
    end
    
    def create_meine_ausstellungen # Meine Ausstellungen
      @meine_ausstellungen_set = FactoryGirl.create(:media_set, 
                                         user: @user,
                                         meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Meine Ausstellungen"}})
    end
    
    def create_meine_highlights # Meine Highlights
      @meine_highlights_set = FactoryGirl.create(:media_set, 
                                      user: @user,
                                      meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Meine Highlights 2012"}})
      FactoryGirl.create(:grouppermission, 
              media_resource: @meine_highlights_set, 
              group: @zhdk_group, 
              view: true, 
              edit: false, 
              download: false)
    end
    
    def create_dropbox_set
      @dropbox_set = FactoryGirl.create(:media_set, 
                             user: @user,
                             meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Dropbox"}})
    end
    
    def create_diplomarbeit_2012
      @diplomarbeiten_2012_set = FactoryGirl.create(:media_set, 
                                         user: @user,
                                         meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Diplomarbeit 2012"}})
      FactoryGirl.create(:grouppermission, 
              media_resource: @diplomarbeiten_2012_set, 
              group: @diplomarbeitsgruppe, 
              view: true, 
              edit: false, 
              download: false)
      FactoryGirl.create(:grouppermission, 
              media_resource: @diplomarbeiten_2012_set, 
              group: @zhdk_group, 
              view: true, 
              edit: false, 
              download: false)
      @diplomarbeiten_2012_prasentation = FactoryGirl.create(:media_entry, 
                                                  view: true,
                                                  user: @user, 
                                                  parent_sets: [@diplomarbeiten_2012_set], 
                                                  meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Präsentation"}})
      FactoryGirl.create(:userpermission, 
              media_resource: @diplomarbeiten_2012_prasentation, 
              user: Persona.create(:norbert), view: true, edit: true, manage: false, download: false)
      @diplomarbeiten_2012_ausstellungen = FactoryGirl.create(:media_set, 
                                                   user: @user, 
                                                   parent_sets: [@diplomarbeiten_2012_set, @meine_highlights_set, @meine_ausstellungen_set, @dropbox_set], 
                                                   meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellungen"}})
      @diplomarbeiten_2012_austellung_photo_1 = FactoryGirl.create(:media_entry, 
                                                        user: @user, 
                                                        parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 1"}})    
      @diplomarbeiten_2012_austellung_photo_2 = FactoryGirl.create(:media_entry, 
                                                        user: @user, 
                                                        parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 2"}})    
      @diplomarbeiten_2012_austellung_photo_3 = FactoryGirl.create(:media_entry, 
                                                        user: @user, 
                                                        parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 3"}})    
      @diplomarbeiten_2012_austellung_photo_4 = FactoryGirl.create(:media_entry, 
                                                        user: @user, 
                                                        parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 4"}})    
      @diplomarbeiten_2012_ausstellungen_zhdk_set = FactoryGirl.create(:media_set, 
                                                            user: @user, 
                                                            parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                            meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung ZHdK"}})                                                  
      @diplomarbeiten_2012_ausstellungen_museum_zuerich_set = FactoryGirl.create(:media_set, 
                                                                      user: @user, 
                                                                      parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                                      meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Museum Zürich"}})
      @diplomarbeiten_2012_austellung_photo_5 = FactoryGirl.create(:media_entry, 
                                                        user: @user, 
                                                        parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 5"}})
      @diplomarbeiten_2012_ausstellungen_limatquai_set = FactoryGirl.create(:media_set, 
                                                                 user: @user, 
                                                                 parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                                 meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Gallerie Limatquai"}})                                              
      @diplomarbeiten_2012_konzepte = FactoryGirl.create(:media_set, 
                                              user: @user, 
                                              parent_sets: [@diplomarbeiten_2012_set], 
                                              meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Konzepte"}})
      @diplomarbeiten_2012_konzepte_erster_entwurf = FactoryGirl.create(:media_entry, 
                                                             user: @user, 
                                                             parent_sets: [@diplomarbeiten_2012_konzepte], 
                                                             meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Erster Entwurf"}})
      @diplomarbeiten_2012_konzepte_zweiter_entwurf = FactoryGirl.create(:media_entry, 
                                                              user: @user, 
                                                              parent_sets: [@diplomarbeiten_2012_konzepte], 
                                                              meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Zweiter Entwurf"}})
    end
  end  
end
