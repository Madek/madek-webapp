# -*- encoding : utf-8 -*-
#= Person
#
#  The Person class is a minimal value-object representation of a natural Person.
#

class Person < ActiveRecord::Base

  has_one :user

  has_and_belongs_to_many :meta_data, join_table: :meta_data_people

  validate do
    errors.add(:base, "Name cannot be blank") if [firstname, lastname, pseudonym].all? {|x| x.blank? }
  end
  

### SCOPES ####################################

  scope :with_meta_data, where(%Q<
    "people"."id" in ( #{Person.joins(:meta_data).select('"people"."id"').group('"people"."id"').to_sql}) >)
  scope :with_user, joins(:user)
  scope :groups, where(:is_group => true)

  scope :search, lambda { |query|
    return scoped if query.blank?

    q = query.split.map{|s| "%#{s}%"}
    where(arel_table[:firstname].matches_any(q).
          or(arel_table[:lastname].matches_any(q)).
          or(arel_table[:pseudonym].matches_any(q)))
  }

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
