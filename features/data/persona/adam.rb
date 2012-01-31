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
      media_set = Factory(:media_set, :user => user)
      media_set.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set.individual_contexts << context



      # TODO create with meta_keys
      name = "Zett"
      context = MetaContext.send(name) || Factory(:meta_context, :name => name)

      title = "Zett"
      media_set = Factory(:media_set, :user => user)
      media_set.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title}}})
      media_set.individual_contexts << context



      # TODO create with meta_keys
      name = "Games"
      context = Factory(:meta_context, :name => name) unless MetaContext.exists?(:name => name)


    end
  end  
end