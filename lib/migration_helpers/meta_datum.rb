module MigrationHelpers
  module MetaDatum

    class RawMetaDatum < ActiveRecord::Base 
      set_table_name :meta_data
      belongs_to :meta_key

      def to_s
        {id: id, meta_key_id: meta_key_id, value: value}.to_s
      end
    end

  end
end
