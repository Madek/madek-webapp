# -*- encoding : utf-8 -*-
 
class MetaDatumCountry < MetaDatumString

  def self.get_codes
    file = "#{Rails.root}/config/definitions/helpers/country_codes.yml"
    entries = YAML.load(File.read(file))
  end

end
