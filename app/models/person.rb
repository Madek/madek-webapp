# -*- encoding : utf-8 -*-
#= Person
#
#  The Person class is a minimal value-object representation of a natural Person.
#

class Person < ActiveRecord::Base

  has_one :user

  has_and_belongs_to_many :meta_data, join_table: :meta_data_people

  default_scope order(:lastname)

  validate do
    errors.add(:base, "Name cannot be blank") if [firstname, lastname, pseudonym].all? {|x| x.blank? }
  end
  
  # TODO has_many :media_entries (where the person is related through meta_data)
#  def media_entries
#    MediaEntry.search self.to_s
#    # TODO through new method meta_data
#  end

  def self.with_meta_data
    select("DISTINCT people.*").joins("INNER JOIN meta_data_people ON people.id = meta_data_people.person_id")
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

  def self.search(query)
    return scoped unless query
    w = query.split.map do |q|
      "firstname #{SQLHelper.ilike} '%#{q}%' OR lastname #{SQLHelper.ilike} '%#{q}%' OR pseudonym #{SQLHelper.ilike}'%#{q}%'"
    end
    where(w.join(' OR '))
  end


#######################################

  def to_s
    name
  end

  def shortname
    r = ""
    r += "#{firstname[0]}. " unless firstname.blank?
    r += "#{lastname}"
    r
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
  def fullname
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
    values.flat_map {|v| v.respond_to?(:split) ? v.split(';') : v }
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
