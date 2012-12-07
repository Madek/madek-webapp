# -*- encoding : utf-8 -*-
class FilterSet < MediaSet

  # NOTE provides alias for routes and used for sti type switcher
  def self.model_name
    MediaSet.model_name
  end

  # extending settings
  ACCEPTED_SETTINGS[:filter] = {:default => {}}

  def get_filter
    settings[:filter] || ACCEPTED_SETTINGS[:filter][:default]
  end

  def child_media_resources(user = nil)
    settings[:filter] ||= ACCEPTED_SETTINGS[:filter][:default]
    MediaResource.filter(user, settings[:filter])
  end

  def get_media_file(user = nil)
    # we just provide the first public media_entry's image
    child_media_resources.media_entries.where(view: true).ordered_by(:updated_at).first.try(:media_file)
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
                          media_file = MediaResource.filter(nil, {:meta_data => {k => {:ids => [term[:id]]}}}).where(view: true).ordered_by(:updated_at).first.try(:media_file)
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
