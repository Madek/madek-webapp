# coding: UTF-8
module Persona
  class Adam
    def initialize
      name = "Adam"
      person = Factory(:person, :firstname => name)
      user = Factory(:user, :person => person, :login => name)

      # TODO is it correct that the admin creates all these contexts?
      
      # TODO create with meta_keys
      name = "Landschaftsvisualisierung"
      context = MetaContext.send(name) || Factory(:meta_context, :name => name)

      title = "Landschaften"
      media_set1 = Factory(:media_set, :user => user)
      media_set1.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set1.individual_contexts << context



      # TODO create with meta_keys
      name = "Zett"
      context = MetaContext.send(name) || Factory(:meta_context, :name => name)

      title = "Zett"
      media_set2 = Factory(:media_set, :user => user)
      media_set2.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set2.individual_contexts << context

      title = "Zett über Landschaften"
      media_set3 = Factory(:media_set, :user => user)
      media_set3.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set3.parent_sets << [media_set1, media_set2]


      # TODO create with meta_keys
      name = "Games"
      context = Factory(:meta_context, :name => name) unless MetaContext.exists?(:name => name)


    end
  end  
end