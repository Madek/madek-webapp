class Meta::Date # TODO rename to Meta::DateTime ??
  
  attr_accessor :timestamp, #old# :parsed # TODO enforce to DateTime ??
                :timezone,
                :free_text

  def initialize(attributes = {})
    attributes.each_pair do |key, value|
      self.send("#{key}=", value)
    end
  end

  def id
    self
  end

  def to_s
    if parsed
      format = if parsed.to_datetime.seconds_since_midnight > 0 # TODO just .seconds_since_midnight
        :date_time
      else
        :date
      end
      parsed.to_formatted_s(format)
    else
      @free_text
    end
  end

  def parsed
    Time.at(@timestamp) if @timestamp
  end
  
###################################
  class << self

    def where(args)
      args[:id] = args[:id].first if args[:id].is_a?(Array)
      r = if args[:id].respond_to?(:ivars) and args[:id].class == "Meta::Date"
        new(args[:id].ivars)
      else
        case args[:id].class.name
          when "Meta::Date"
            args[:id]
          when "String"
            parse(args[:id])
          else
            nil
        end
      end
      [r]
    end
  
    def parse(string)
      h = {:free_text => string}
      begin
  #old#
  #      r = if string =~ /^(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})[\+|\-](\d{2}):(\d{2})$/ # EXIF standard with time and zone
  #        ::DateTime.strptime(string, DateTime::DATE_FORMATS[:exif_date_time_zone])
  #      elsif string =~ /^(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})$/ # EXIF standard with time
  #        ::DateTime.strptime(string, DateTime::DATE_FORMATS[:exif_date_time])
  #      elsif string =~ /^(\d{4}):(\d{2}):(\d{2})$/ # EXIF standard without time
  #        ::DateTime.strptime(string, Date::DATE_FORMATS[:exif_date])
  #      else
  #        ::DateTime.parse(string)
  #      end
  
        # OPTIMIZE
        if string =~ /^(\d{4}):(\d{2}):(\d{2})/
          string.sub!(':', '-').sub!(':', '-')
        end
        
        date_hash = Date._parse(string)
        unless date_hash.blank?
          h[:timezone] = date_hash[:zone] || Time.zone.formatted_offset        
          h[:timestamp] = Time.parse(string).to_i
        end
      rescue
        # there was no exact match, so we only store the free text
      end
      new(h)
    end

    def parse_all
      MetaKey.where(:object_type => "Meta::Date").each do |key|
        key.meta_data.each do |md|
          md.update_attributes(:value => md.value)
        end
      end
    end

  end
  
end