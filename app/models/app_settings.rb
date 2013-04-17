class AppSettings < ActiveRecord::Base

  serialize :footer_links, JsonSerializer

  class << self

    def method_missing method, *args, &block
      @_chached_inspector ||= first
      if block_given? 
        super
      elsif @_chached_inspector.respond_to? method
        if args == [] and attribute_names.include? method.to_s
          pluck(method).first
        else
          first.send method, *args
        end
      else
        super
      end
    end

    def authentication_systems
      @_cached_authentication_systems ||=
        begin 
          YAML.load_file(Rails.root.join("config","authentication_systems.yml"))
        rescue
          YAML.load_file(Rails.root.join("config","authentication_systems_default.yml"))
        end
    end

  end

end
