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
    def initialize
      name = "Adam"
      person = Factory(:person, firstname: name, lastname: "Admin")
      crypted_password = Digest::SHA1.hexdigest("password")

      user = Factory(:user, :person => person, :login => name, :password => crypted_password)

      # TODO is it correct that the admin creates all these contexts?
      
      # TODO create with meta_keys
      name = "Landschaftsvisualisierung"
      context = if MetaContext.exists?(:name => name)
        MetaContext.send(name)
      else
        Factory(:meta_context, :name => name)
      end

      title = "Landschaften"
      media_set1 = Factory(:media_set, :user => user)
      media_set1.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set1.individual_contexts << context

      
      # TODO create with meta_keys
      name = "Zett"
      context = if MetaContext.exists?(:name => name)
        MetaContext.send(name)
      else
        Factory(:meta_context, :name => name)
      end

      title = "Zett"
      media_set2 = Factory(:media_set, :user => user)
      media_set2.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set2.individual_contexts << context

      # TODO create with meta_keys
      name = "Games"
      context = if MetaContext.exists?(:name => name)
        MetaContext.send(name)
      else
        Factory(:meta_context, :name => name)
      end

      title = "Zett über Landschaften"
      media_set3 = Factory(:media_set, :user => user)
      media_set3.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set3.individual_contexts << context
      media_set3.parent_sets << [media_set1, media_set2]


    end
  end  
end
