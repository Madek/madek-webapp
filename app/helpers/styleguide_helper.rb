# Helper for Styleguide
module StyleguideHelper
  def css_class_to_haml(str)
    return if str.nil? or !str.is_a? String
    str.split(' ').map { |mod| ".#{mod}" }.join
  end
end
