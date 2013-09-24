# -*- encoding : utf-8 -*-
class FilterSet < MediaResourceCollection
  store :settings

  def media_type
    self.type.gsub(/Media/, '')
  end

  def get_filter
    settings[:filter] || {} 
  end

  def filtered_resources(user)
    settings[:filter] ||= {}
    MediaResource.filter(user, settings[:filter])
  end

  def included_resources_accessible_by_user user, action
    filtered_resources user
  end

  def get_media_file(user = nil)
    # we just provide the first public media_entry's image
    # we provide random image for filter sets
    filtered_resources(user).media_entries.where(view: true).ordered_by(:random).first.try(:media_file)
  end

  def sections possible_filters
    sections = []
    filter = self.get_filter[:meta_data]
    if filter
      filter.each_pair do |k,v|
        next unless v[:ids].include? "any"
        next unless existing_filter = possible_filters.detect{|x| x[:keys].detect{|y| y[:key_name] == "#{k}"} }
        existing_filter[:keys].detect{|y| y[:key_name] == "#{k}" }[:terms].each do |term|
          sections << { :id => term[:id],
                        :key => k,
                        :name => term[:value],
                        :count => term[:count],
                        :image => begin
                          media_file = MediaEntry.filter(nil, {:meta_data => {k => {:ids => [term[:id]]}}}).where(view: true).ordered_by(:updated_at).first.try(:media_file)
                          # TODO consider provide url images instead of base64
                          media_file.thumb_base64(:medium) unless media_file.nil?
                        end
                      }
        end
      end
      sections
    else
      []
    end
  end

end
