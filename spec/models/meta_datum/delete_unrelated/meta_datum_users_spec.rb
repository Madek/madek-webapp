require 'spec_helper'
require 'spec_helper_no_tx'

def create_meta_datum
  FactoryGirl.create :meta_datum_users
end

describe MetaDatum::Users do

  describe 'with a few users' do

    before :each do
      PgTasks.truncate_tables
      @collection = FactoryGirl.create :collection
      @meta_key_users = FactoryGirl.create :meta_key_users
      @meta_datum = FactoryGirl.create :meta_datum_users,
                                       collection: @collection,
                                       meta_key: @meta_key_users
    end

    it 'deleting all users deletes the meta_datum' do
      expect(MetaDatum.find_by id: @meta_datum.id).to be
      expect(@meta_datum.users.count).to be >= 1
      @meta_datum.users.delete_all
      expect(MetaDatum.find_by id: @meta_datum.id).not_to be
    end

  end

  describe 'creating an empty one' do

    before :each do
      PgTasks.truncate_tables
      @collection = FactoryGirl.create :collection
      @meta_key_users = FactoryGirl.create :meta_key_users
    end

    it 'will be deleted after closing the transaction' do

      ActiveRecord::Base.transaction do

        @meta_datum = FactoryGirl.create :meta_datum_users,
                                         collection: @collection,
                                         meta_key: @meta_key_users,
                                         users: []

        expect(@meta_datum.users.count).to be == 0

        expect(MetaDatum.find_by id: @meta_datum.id).to be
      end

      expect(MetaDatum.find_by id: @meta_datum.id).not_to be

    end
  end
end
