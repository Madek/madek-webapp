module Concerns
  module MetaData
    extend ActiveSupport::Concern

    included do
      has_many :meta_data
    end

    def title
      meta_data.find_by(meta_key_id: 'title').try(:value)
    end

    def description
      meta_data.find_by(meta_key_id: 'description').try(:value)
    end
  end
end
