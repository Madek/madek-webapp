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

  def child_media_resources
    settings[:filter] ||= ACCEPTED_SETTINGS[:filter][:default]
    MediaResource.filter(nil, settings[:filter])
  end

  def get_media_file(user)
    nil
  end

  def sections possible_filters
    sections = []
    self.get_filter[:meta_data].each_pair do |k,v|
      next unless v[:ids].include? "any"
      next unless existing_filter = possible_filters.detect{|x| x[:keys].detect{|y| y[:key_name] == "#{k}"} }
      existing_filter[:keys].detect{|y| y[:key_name] == "#{k}" }[:terms].each do |term|
        sections << {:id => term[:id], :name => term[:value], :count => term[:count]}
      end
    end
    sections
  end

end
