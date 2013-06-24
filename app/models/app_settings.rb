class AppSettings < ActiveRecord::Base

  serialize :footer_links, JsonSerializer

  def authentication_systems
    AppSettings.authentication_systems
  end

  class << self

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
