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
      @person = Factory(:person, firstname: @name, lastname: @lastname)
    end

    def create_user
      @crypted_password = Digest::SHA1.hexdigest(@@password)
      @user = Factory(:user, person: @person, login: @name.downcase, password: @crypted_password)
    end

    def create_dropbox_dir
      user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, @user.dropbox_dir_name)
      FileUtils.mkdir_p(user_dropbox_root_dir)
      File.new(user_dropbox_root_dir).chmod(0770)
    end
    
    def create_diplomarbeitsgruppe
      @diplomarbeitsgruppe = Factory(:group,
                                     name: "Diplomarbeitsgruppe",
                                     type: "Group",
                                     users: [@user])
    end
    
    def join_zhdk_group
      @zhdk_group= Group.find_or_create_by_name("ZHdK")
      @zhdk_group.users << @user
    end
    
    def create_abgabe_zum_kurs_product_design # Abgabe zum Kurs Product Design
      @abgabe_zum_kurs_product_design_set = Factory(:media_set,
                                                    user: @user, 
                                                    meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Abgabe zum Kurs Product Design"}})
      Factory(:userpermission, 
              media_resource: @abgabe_zum_kurs_product_design_set, 
              user: Persona.create(:petra), view: true, edit: false, manage: false, download: false)

      Factory(:grouppermission,
              group: @diplomarbeitsgruppe,
              media_resource: @abgabe_zum_kurs_product_design_set,
              view: true, edit:false, manage: false, download: true)


      @abgabe_zum_kurs_product_design_abgabe = Factory(:media_entry, 
                                                       user: @user, 
                                                       media_sets: [@abgabe_zum_kurs_product_design_set], 
                                                       meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Abgabe"}})
      @abgabe_zum_kurs_product_design_konzepte = Factory(:media_entry, 
                                                         user: @user, 
                                                         media_sets: [@abgabe_zum_kurs_product_design_set], 
                                                         meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Konzepte"}})    
    end
    
    def create_fotografie_kurs_hs_2010 # Fotografie Kurs HS 2010
      @fotografie_kurs_hs_2010_set = Factory(:media_set, 
                                             user: @user,
                                             view: true,
                                             meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Fotografie Kurs HS 2010"}})
      @fotografie_kurs_hs_2010_portrait = Factory(:media_entry,
                                                  user: @user, 
                                                  media_sets: [@fotografie_kurs_hs_2010_set], 
                                                  meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Portrait"}})
      @fotografie_kurs_hs_2010_stillleben = Factory(:media_entry, 
                                                    user: @user, 
                                                    media_sets: [@fotografie_kurs_hs_2010_set], 
                                                    meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Stilleben"}})
    end
    
    def create_meine_ausstellungen # Meine Ausstellungen
      @meine_ausstellungen_set = Factory(:media_set, 
                                         user: @user,
                                         meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Meine Ausstellungen"}})
    end
    
    def create_meine_highlights # Meine Highlights
      @meine_highlights_set = Factory(:media_set, 
                                      user: @user,
                                      meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Meine Highlights 2012"}})
      Factory(:grouppermission, 
              media_resource: @meine_highlights_set, 
              group: @zhdk_group, 
              view: true, 
              edit: false, 
              download: false)
    end
    
    def create_dropbox_set
      @dropbox_set = Factory(:media_set, 
                             user: @user,
                             meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Dropbox"}})
    end
    
    def create_diplomarbeit_2012
      @diplomarbeiten_2012_set = Factory(:media_set, 
                                         user: @user,
                                         meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Diplomarbeit 2012"}})
      Factory(:grouppermission, 
              media_resource: @diplomarbeiten_2012_set, 
              group: @diplomarbeitsgruppe, 
              view: true, 
              edit: false, 
              download: false)
      Factory(:grouppermission, 
              media_resource: @diplomarbeiten_2012_set, 
              group: @zhdk_group, 
              view: true, 
              edit: false, 
              download: false)
      @diplomarbeiten_2012_prasentation = Factory(:media_entry, 
                                                  user: @user, 
                                                  media_sets: [@diplomarbeiten_2012_set], 
                                                  meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Präsentation"}})
      @diplomarbeiten_2012_ausstellungen = Factory(:media_set, 
                                                   user: @user, 
                                                   parent_sets: [@diplomarbeiten_2012_set, @meine_highlights_set, @meine_ausstellungen_set, @dropbox_set], 
                                                   meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellungen"}})
      @diplomarbeiten_2012_austellung_photo_1 = Factory(:media_entry, 
                                                        user: @user, 
                                                        media_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 1"}})    
      @diplomarbeiten_2012_austellung_photo_2 = Factory(:media_entry, 
                                                        user: @user, 
                                                        media_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 2"}})    
      @diplomarbeiten_2012_austellung_photo_3 = Factory(:media_entry, 
                                                        user: @user, 
                                                        media_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 3"}})    
      @diplomarbeiten_2012_austellung_photo_4 = Factory(:media_entry, 
                                                        user: @user, 
                                                        media_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 4"}})    
      @diplomarbeiten_2012_ausstellungen_zhdk_set = Factory(:media_set, 
                                                            user: @user, 
                                                            parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                            meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung ZHdK"}})                                                  
      @diplomarbeiten_2012_ausstellungen_museum_zuerich_set = Factory(:media_set, 
                                                                      user: @user, 
                                                                      parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                                      meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Museum Zürich"}})
      @diplomarbeiten_2012_austellung_photo_5 = Factory(:media_entry, 
                                                        user: @user, 
                                                        media_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                        meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Photo 5"}})
      @diplomarbeiten_2012_ausstellungen_limatquai_set = Factory(:media_set, 
                                                                 user: @user, 
                                                                 parent_sets: [@diplomarbeiten_2012_ausstellungen], 
                                                                 meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Ausstellung Gallerie Limatquai"}})                                              
      @diplomarbeiten_2012_konzepte = Factory(:media_set, 
                                              user: @user, 
                                              parent_sets: [@diplomarbeiten_2012_set], 
                                              meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Konzepte"}})
      @diplomarbeiten_2012_konzepte_erster_entwurf = Factory(:media_entry, 
                                                             user: @user, 
                                                             media_sets: [@diplomarbeiten_2012_konzepte], 
                                                             meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Erster Entwurf"}})
      @diplomarbeiten_2012_konzepte_zweiter_entwurf = Factory(:media_entry, 
                                                              user: @user, 
                                                              media_sets: [@diplomarbeiten_2012_konzepte], 
                                                              meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Zweiter Entwurf"}})
    end
  end  
end
