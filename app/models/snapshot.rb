# -*- encoding : utf-8 -*-
class Snapshot < MediaResource

  belongs_to :media_entry
  belongs_to :media_file
  
  # TODO type attribute ?? TMS, etc...

  before_create do
    self.media_file = media_entry.media_file
  end
  
  after_create do
    media_entry.meta_data.each do |md|
      meta_data.create(:meta_key_id => md.meta_key_id, :value => md.value )
    end
    descr_author_value = meta_data.get("description author").value
    meta_data.get("description author before snapshot").update_attributes(:value => descr_author_value) if descr_author_value
  end

  default_scope order("created_at DESC")

########################################################

  def edited?
    not edit_sessions.empty?
  end

########################################################

  def to_tms(xml, context)
    xml.snapshot do
      #old# meta_data.each do |meta_datum|
      meta_data_for_context(context, false).each do |meta_datum|
        key_map = meta_datum.meta_key.key_map_for(context)
        if key_map
          # TODO use treetop gem
          key_map.split('||').each do |km|
            tokens = km.split(' ', 2)
            name = tokens.first
            attrs = {}
#old#
#            tokens.last.split(' ').each do |token|
#              a = token.split('=', 2)
#              attrs[a.first] = a.last
#            end if tokens.size > 1
          
            tokens = (tokens.size > 1 ? tokens.last : nil)
            
            while not tokens.blank? do
              a = tokens.split('=', 2)
              k = a.first
              if a.last.first == '"'
                b = a.last.split('"', 3)
                v = b[1]
                tokens = (b.size > 2 ? b.last : nil)
              else
                b = a.last.split(' ', 2)
                v = b[0]
                tokens = (b.size > 1 ? b.last : nil)
              end
              attrs[k] = v
            end

#temp#
            case meta_datum.meta_key.object_type
              when "Meta::Term"
                xml.tag!(name, attrs) do
                  meta_datum.deserialized_value.each do |dv|
                    xml.tag!("term", dv.to_s)
                  end
                end
              when "Person"
                xml.tag!(name, attrs) do
                  meta_datum.deserialized_value.each do |dv|
                    xml.person do
                      xml.tag!("firstname", dv.firstname)
                      xml.tag!("lastname", dv.lastname)
                    end
                  end
                end
              else
                value = meta_datum.to_s
                case name
                  when "person"
                    xml.person(attrs) do
                      xml.tag!("name", value)
                    end
                  when "objects.creditline"
                    xml.tag!(name, attrs, "Verwaltet durch #{value}")
                  else
                    xml.tag!(name, attrs, value)
                end
            end

#            case name
#              when "person"
#                case meta_datum.meta_key.object_type
#                  when "Person"
#                    meta_datum.deserialized_value.each do |dv|
#                      xml.person(attrs) do
#                        xml.tag!("firstname", dv.firstname)
#                        xml.tag!("lastname", dv.lastname)
#                      end
#                    end
#                  else
#                    xml.person(attrs) do
#                      xml.tag!("name", meta_datum.to_s)
#                    end
#                end
##              when "location"
##              when "keywords"
##              when "gattung"
#              else
#                value = meta_datum.to_s
#                xml.tag!(name, attrs, value)
#            end
          
          end
        end
      end
    end
#    xml.media_set do
#      xml.id id
#      xml.owner user.to_s
#      meta_data.each do |meta_datum|
#        xml.tag!(meta_datum.object.meta_key.meta_key_definitions.for_context(context).meta_field.label.parameterize('_'), meta_datum)
#      end
#      media_entries.each do |media_entry|
#        media_entry.to_tms(xml, context)
#      end
#    end
  end

end
