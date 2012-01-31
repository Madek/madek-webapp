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
      context = Factory(:meta_context, :name => name) unless MetaContext.exists?(:name => name)
       
      # TODO create with meta_keys
      name = "Zett"
      context = Factory(:meta_context, :name => name) unless MetaContext.exists?(:name => name)
      
      # TODO create with meta_keys
      name = "Games"
      context = Factory(:meta_context, :name => name) unless MetaContext.exists?(:name => name)

    end
  end  
end