module UserModules
  module AutoCompletion
    extend ActiveSupport::Concern

    included do
      after_save :update_autocomplete
    end

    def canonical_name
      ((person.last_name.blank? ? '' : "#{person.last_name},") \
       << (person.first_name.blank? ? '' : " #{person.first_name}") \
       << (person.pseudonym.blank? ? '' : " (#{person.pseudonym})") \
       << " [#{login}]")  \
      .squish
    end

    def update_autocomplete
      update_columns autocomplete: canonical_name
    end

  end
end

