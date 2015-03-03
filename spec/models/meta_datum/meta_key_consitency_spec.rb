require 'spec_helper'
require 'spec_helper_no_tx'

describe 'relations between meta_data and meta_keys' do

  before :all do
    @collection = FactoryGirl.create :collection
    FactoryGirl.create :meta_key_title
    MetaDatum::Text.create \
      collection: @collection,
      value: 'Blah',
      meta_key_id: 'test:title'
  end

  describe MetaDatum do

    describe %(changing the type to be incomaptible) do
      it 'raises an error ' do
        expect do
          ActiveRecord::Base.transaction do
            ActiveRecord::Base.connection.execute \
              "UPDATE meta_data SET type = 'MetaDatum::TextDate' "
          end
        end.to raise_error \
          /types of related meta_data and meta_keys must be identical/
      end
    end

    describe %(creating a new meta_datum which relates
    to an imcompatible meta_key).strip do
      it 'raises an error' do
        expect do
          MetaDatum::TextDate.transaction do
            ActiveRecord::Base.connection.execute \
              "INSERT INTO meta_data (type,meta_key_id,collection_id)
            VALUES ('MetaDatum::TextDate','test:title','#{@collection.id}')"
          end
        end.to raise_error \
          /types of related meta_data and meta_keys must be identical/
      end
    end

  end

  describe MetaKey do

    describe %(changing the type to be incomaptible) do
      it 'raises an error ' do
        expect do
          ActiveRecord::Base.transaction do
            ActiveRecord::Base.connection.execute \
              "UPDATE meta_keys SET meta_datum_object_type = 'MetaDatum::TextDate'"
          end
        end.to raise_error \
          /types of related meta_data and meta_keys must be identical/
      end
    end

  end

end
