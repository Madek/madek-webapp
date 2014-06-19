# -*- encoding : utf-8 -*-
#= MediaEntry
#
# This class could just as easily also be known as MediaObject..
# and one day might become so.

class MediaEntry < MediaResource
  include MediaResourceModules::MediaFile

  default_scope { reorder(:created_at) }

  alias :media_sets :parent_sets 

########################################################

  # OPTIMIZE
  def individual_contexts
    media_sets.flat_map {|set| set.individual_contexts }.uniq
  end

########################################################

  def to_s
    "#{title}"
  end

  # compares two objects in order to sort them
  # required by dot
  def <=>(other)
    self.updated_at <=> other.updated_at
  end

########################################################

  def self.to_tms_doc(resources, io_interface= IoInterface.find("tms"))
    require 'active_support/builder' unless defined?(::Builder)
    xml = ::Builder::XmlMarkup.new
    xml.instruct!
    xml.madek(:version => RELEASE_VERSION) do
      Array(resources).each do |resource|
        resource.to_tms(xml, io_interface)
      end
    end
  end
  
########################################################

  def to_tms(xml, io_interface)
    xml.snapshot do
      #old# meta_data.each do |meta_datum|
      meta_data.for_io_interface(io_interface).each do |meta_datum|
        key_map = meta_datum.meta_key.key_map_for(io_interface)
        if key_map
          # TODO use treetop gem
          key_map.split('||').each do |km|
            tokens = km.split(' ', 2)
            name = tokens.first
            attrs = {}
          
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
            case meta_datum.meta_key.meta_datum_object_type
              when "MetaDatumMetaTerms"
                xml.tag!(name, attrs) do
                  meta_datum.value.each do |dv|
                    xml.tag!("term", dv.to_s)
                  end
                end
              when "MetaDatumPeople"
                meta_datum.value.each do |dv|
                  xml.tag!(name, attrs) do
                    xml.tag!("first_name", dv.first_name)
                    xml.tag!("last_name", dv.last_name)
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
          end
        end
      end
    end
  end
  
########################################################

 def self.compared_meta_data(media_entries, context)
   compared_against, other_entries = media_entries[0], media_entries[1..-1]
   compared_meta_data = compared_against.meta_data.for_context(context)
   
   new_blank_media_entry = self.new
   compared_meta_data.map do |md_bare|
      if other_entries.any? {|me| not me.meta_data.get(md_bare.meta_key_id).same_value?(md_bare.value)}
        new_blank_media_entry.meta_data.build(:meta_key_id => md_bare.meta_key_id, :keep_original_value => true)
      else
        new_blank_media_entry.meta_data.build(:meta_key_id => md_bare.meta_key_id, :value => md_bare.value)
      end
   end
 end
end
