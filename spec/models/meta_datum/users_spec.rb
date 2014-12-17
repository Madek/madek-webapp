require 'spec_helper'

describe MetaDatum::Users do

  context 'existing meta key madek:test:users, collection, some users' do

    before :all do
      DBHelper.truncate_tables
      @meta_key_users = \
        MetaKey.create id: 'madek:test:users',
                       meta_datum_object_type: 'MetaDatum::Users'
      @user1 = FactoryGirl.create :user
      @user2 = FactoryGirl.create :user
      @user3 = FactoryGirl.create :user
      @collection = FactoryGirl.create :collection
    end

    after :all do
      DBHelper.truncate_tables
    end

    it 'truly exists' do
      expect { MetaKey.find('madek:test:users') }.not_to raise_error
      expect { Collection.find(@collection.id) }.not_to raise_error
    end

    describe ':meta_datum users factory' do

      it "invocation doesn't raise an error" do
        FactoryGirl.create :meta_datum_users,
                           collection: @collection,
                           meta_key: @meta_key_users
      end

      context 'a factory created instance' do
        before :each do
          @meta_datum_users = FactoryGirl.create :meta_datum_users,
                                                 collection: @collection,
                                                 meta_key: @meta_key_users
        end

        it 'has at least 3 users associated with it' do
          expect(@meta_datum_users.users.count).to be >= 3
        end

        describe 'to_s' do
          it 'includes the stringified users' do
            @meta_datum_users.users.each do |user|
              expect(@meta_datum_users.to_s).to include user.to_s
            end
          end
        end

        describe 'value=' do

          it 'resets the associated users' do
            expect(@meta_datum_users.users).not_to be == [@user1, @user2]
            expect do
              @meta_datum_users.value = [@user1, @user2]
            end.not_to raise_error
            expect(@meta_datum_users.users).to be == [@user1, @user2]
          end

        end

      end

    end

  end

end
