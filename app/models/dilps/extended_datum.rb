class Dilps::ExtendedDatum < Dilps::Base
  self.table_name = 'extended_data'

  def key
    name.split(":").first
  end

  def value
    case name
    when 'dating::date'
      date_string
    else
      nil
    end
  end

end
