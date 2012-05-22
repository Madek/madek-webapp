class MetaDate < ActiveRecord::Base
  has_one :meta_datum_date

  class << self
    def try_parse s
      begin
        DateTime.parse s
      rescue
        s
      end
    end
  end
  
end
