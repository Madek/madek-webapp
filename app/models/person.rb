# -*- encoding : utf-8 -*-
#= Person
#
#  The Person class is a minimal value-object representation of a natural Person.
#

class Person < ActiveRecord::Base

  has_one :user

  has_and_belongs_to_many :meta_data, join_table: :meta_data_people

  validate do
    errors.add(:base, "Name cannot be blank") if [first_name, last_name, pseudonym].all? {|x| x.blank? }
  end
  

### SCOPES ####################################

  scope :with_meta_data, lambda{ where(%Q<
    "people"."id" in ( #{Person.joins(:meta_data).select('"people"."id"').group('"people"."id"').to_sql}) >)}
  scope :with_user, lambda{joins(:user)}
  scope :groups, lambda{where(:is_group => true)}

  scope :search, lambda { |query|
    return scoped if query.blank?

    q = query.split.map{|s| "%#{s}%"}
    where(arel_table[:first_name].matches_any(q).
          or(arel_table[:last_name].matches_any(q)).
          or(arel_table[:pseudonym].matches_any(q)))
  }

#######################################

  def to_s
    name
  end

  def shortname
    r = ""
    r += "#{first_name[0]}. " unless first_name.blank?
    r += "#{last_name}"
    r
  end

  def name
    a = []
    a << last_name unless last_name.blank? 
    a << first_name unless first_name.blank? 
    r = a.join(", ")
    r += " (#{pseudonym})" unless pseudonym.blank?
    r += " [Gruppe]" if is_group?
    r
  end

  # TODO drop this method, use to_s instead
  def fullname
    r = "#{first_name} #{last_name}"
    r += " (#{pseudonym})" unless pseudonym.blank?
    r
  end

# class method to parse a name out of something that purports 
# to be a name representing a natural person.
# Input is presented either as:
#   first_name last_name , or
#   last_name, first_name
  def self.parse(value)
    #TODO untrivialise this name splitter
    #TODO does this really belong here?
    value.gsub!(/[*%;]/,'')
    if value.include?(",") # input comes to us as last_name<comma>first_name(s)
      x = value.strip.squeeze(" ").split(/\s*,\s*/,2)
      fn = x.pop
      ln = x.pop
    else # Last word is family name, everything else is first_name(s)
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
#      xml.first_name do
#        first_name
#      end
#      xml.last_name do
#        last_name
#      end
#    end
#  end

end
