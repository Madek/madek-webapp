module Concerns
  module MetaData
    extend ActiveSupport::Concern

    included do
      has_many :meta_data
    end

    def title
      meta_data.find_by(meta_key_id: 'madek:core:title').try(:value)
    end

    def description
      meta_data.find_by(meta_key_id: 'description').try(:value)
    end

    def keywords
      Keyword
        .joins(:meta_datum)
        .where(meta_data: Hash[
          :meta_key_id, 'madek:core:keywords',
          "#{self.class.model_name.singular}_id".to_sym, id])
    end
  end
end
