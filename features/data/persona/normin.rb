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
    def initialize
      name = "Normin"
      person = Factory(:person, :firstname => name)
      user = Factory(:user, :person => person, :login => name)
      
      ## Diplomarbeit 2012
      set1 = Factory(:media_set, :user => user)
      set1.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Diplomarbeit 2012"}}})
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Präsentation"}}})
        set1.media_entries << entry
        
        ## Ausstellung
        set2 = Factory(:media_set, :user => user)
        set2.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Ausstellung"}}})
        set1.child_sets << set2
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Austellung Sihlquai 1"}}})
        set2.media_entries << entry
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Austellung Sihlquai 2"}}})
        set2.media_entries << entry
      
        ## Konzepte
        set2 = Factory(:media_set, :user => user)
        set2.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Konzepte"}}})
        set1.child_sets << set2
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Erster Entwurf"}}})
        set2.media_entries << entry
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Bedinungskonzept"}}})
        set2.media_entries << entry
      
      ## Abgabe zum Kurs Product Design
      set = Factory(:media_set, :user => user)
      set.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Abgabe zum Kurs Product Design"}}})
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Abgabe"}}})
        set.media_entries << entry
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Konzept"}}})
        set.media_entries << entry
        
      ## Fotografie Kurs HS 2010
      set = Factory(:media_set, :user => user)
      set.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Fotografie Kurs HS 2010"}}})
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Portrait"}}})
        set.media_entries << entry
        entry = Factory(:media_entry, :user => user)
        entry.update_attributes({:meta_data_attributes => {0 => {:meta_key_label => "title", :value => "Stilleben"}}})
        set.media_entries << entry 
    end
  end  
end
