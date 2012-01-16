# -*- encoding : utf-8 -*-
#= Person
#
#  The Person class is a minimal value-object representation of a natural Person.
#

class Person < ActiveRecord::Base

  has_one :user

  default_scope order(:lastname)

  validate do |record|
    errors.add(:base, "Name cannot be blank") if [record.firstname, record.lastname, record.pseudonym].all? {|x| x.blank? }
  end
  
  # TODO has_many :media_entries (where the person is related through meta_data)
#  def media_entries
#    MediaEntry.search self.to_s
#    # TODO through new method meta_data
#  end

  def self.with_media_entries
    # OPTIMIZE
    ids = MetaDatum.joins(:meta_key).
            where(:meta_keys => {:object_type => self.name}).
            collect(&:value).flatten.uniq
    find(ids)
  end

  def meta_data
    MetaDatum.joins(:meta_key).
      where(:meta_keys => {:object_type => self.class.name}).
      where(["value REGEXP ?", "-\ #{id}\n" ])
  end

#######################################

=begin #tmp#
  has_one :full_text, :as => :resource, :dependent => :destroy
  after_save { reindex }

  def reindex
    ft = full_text || build_full_text
    new_text = "#{firstname} #{lastname} #{pseudonym}"
    ft.update_attributes(:text => new_text)
  end
=end

  def self.search(s)
    w = s.split.map do |q|
      "firstname LIKE '%#{q}%' OR lastname LIKE '%#{q}%' OR pseudonym LIKE '%#{q}%'"
    end
    where(w.join(' OR '))
  end
  

#######################################

  def to_s
    name
  end

  def name
    a = []
    a << lastname unless lastname.blank? 
    a << firstname unless firstname.blank? 
    r = a.join(", ")
    r += " (#{pseudonym})" unless pseudonym.blank?
    r += " [Gruppe]" if is_group?
    r
  end

  # TODO drop this method, use to_s instead
  def ullname
    r = "#{firstname} #{lastname}"
    r += " (#{pseudonym})" unless pseudonym.blank?
    r
  end

# class method to parse a name out of something that purports 
# to be a name representing a natural person.
# Input is presented either as:
#   Firstname Lastname , or
#   Lastname, Firstname
  def self.parse(value)
    #TODO untrivialise this name splitter
    #TODO does this really belong here?
    value.gsub!(/[*%;]/,'')
    if value.include?(",") # input comes to us as lastname<comma>firstname(s)
      x = value.strip.squeeze(" ").split(/\s*,\s*/,2)
      fn = x.pop
      ln = x.pop
    else # Last word is family name, everything else is firstname(s)
      x = value.strip.split(/\s{1}/,-1)
      ln = x.pop
      fn = x.each {|e| e.capitalize }.join(' ')
    end
    # OPTIMIZE
    fn = nil if fn.blank?
    ln = nil if ln.blank?
    return fn, ln
  end

  def self.split(values)
    values.map {|v| v.respond_to?(:split) ? v.split(';') : v }.flatten
  end

#######################################

#temp#
#  def to_tms(xml)
#    xml.person do
#      xml.firstname do
#        firstname
#      end
#      xml.lastname do
#        lastname
#      end
#    end
#  end

end
