require 'spec_helper'
require 'spec_helper_no_tx'

describe 'the namespace madek_core' do

  before :all do

    ActiveRecord::Base.connection.execute  \
      'SET session_replication_role = REPLICA;'

    FactoryGirl.create :meta_key_core_title

    ActiveRecord::Base.connection.execute  \
      'SET session_replication_role = DEFAULT;'

  end

  describe 'adding new meta_keys to it' do

    it "raises an exception 'may not be extended'" do
      expect do
        MetaKey.transaction do
          MetaKey.connection.execute \
            %(INSERT INTO meta_keys (id, meta_datum_object_type, vocabulary_id) \
              VALUES ('madek_core:description','MetaDatum::Text','madek_core'))
        end
      end.to raise_error(/may not be extended/)
    end

  end

  context 'with the MetaKey madek_core:title' do

    it 'madek_core:title exists' do
      expect(MetaKey.find('madek_core:title')).to be
    end

    describe 'deleting it' do
      it "raises an exception 'may not be deleted'" do
        expect do
          MetaKey.transaction do
            MetaKey.connection.execute \
              "DELETE FROM meta_keys WHERE id = 'madek_core:title'"
          end
        end.to raise_error(/may not be deleted/)
      end
    end

    describe 'mutating it' do
      it "raises an exception 'may not be modified'" do
        expect do
          MetaKey.transaction do
            MetaKey.connection.execute \
              %(UPDATE meta_keys SET meta_datum_object_type = 'MetaDatum::People' \
                WHERE id = 'madek_core:title')
          end
        end.to raise_error(/may not be modified/)
      end
    end

  end

end
