require 'spec_helper'
require 'spec_helper_no_tx'

def create_meta_datum
  FactoryGirl.create :meta_datum_licenses
end

describe MetaDatum::Licenses do

  describe 'with a few licenses' do

    before :each do
      ActiveRecord::Base.transaction do
        PgTasks.truncate_tables
        @collection = FactoryGirl.create :collection
        @meta_key_licenses = FactoryGirl.create :meta_key_licenses
        @meta_datum = FactoryGirl.create :meta_datum_licenses,
                                         collection: @collection,
                                         meta_key: @meta_key_licenses
      end
    end

    it 'deleting all licenses deletes the meta_datum' do
      expect(MetaDatum.find_by id: @meta_datum.id).to be
      expect(@meta_datum.licenses.count).to be >= 1
      @meta_datum.licenses.destroy_all
      expect(MetaDatum.find_by id: @meta_datum.id).not_to be
    end

  end

  describe 'creating an empty one' do

    before :each do
      PgTasks.truncate_tables
      @collection = FactoryGirl.create :collection
      @meta_key_licenses = FactoryGirl.create :meta_key_licenses
    end

    it 'will be deleted after closing the transaction' do

      ActiveRecord::Base.transaction do

        @meta_datum = FactoryGirl.create :meta_datum_licenses,
                                         collection: @collection,
                                         meta_key: @meta_key_licenses,
                                         licenses: []

        expect(@meta_datum.licenses.count).to be == 0

        expect(MetaDatum.find_by id: @meta_datum.id).to be
      end

      expect(MetaDatum.find_by id: @meta_datum.id).not_to be

    end
  end
end
