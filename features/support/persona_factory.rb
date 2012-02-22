# coding: UTF-8
require Rails.root+'features/support/persona'

module PersonaFactory 
  extend self

  def create(name)
    name = name.to_s
    if FileTest.exist? "features/data/persona/#{name.downcase}.rb"
      persona = Persona.get(name)
      if persona.blank?
        require Rails.root+"features/data/persona/#{name.downcase}.rb"
        Persona.const_get(name.camelize).new
        puts "#{name} was created"
        return Persona.get(name)
      else
        puts "#{name} was already created"
        return persona
      end
    else 
      raise "Persona #{name} does not exist"
    end
  end
end
