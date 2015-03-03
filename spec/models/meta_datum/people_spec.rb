require 'spec_helper'

describe MetaDatum::People do

  context 'existing meta key test:people, collection, some people' do

    before :all do
      PgTasks.truncate_tables
      @meta_key_people = FactoryGirl.create :meta_key_people
      @person1 = FactoryGirl.create :person
      @person2 = FactoryGirl.create :person
      @person3 = FactoryGirl.create :person
      @collection = FactoryGirl.create :collection
    end

    after :all do
      PgTasks.truncate_tables
    end

    it 'truly exists' do
      expect { MetaKey.find('test:people') }.not_to raise_error
      expect { Collection.find(@collection.id) }.not_to raise_error
    end

    describe ':meta_datum people factory' do

      it "invocation doesn't raise an error" do
        FactoryGirl.create :meta_datum_people,
                           collection: @collection,
                           meta_key: @meta_key_people
      end

      context 'a factory created instance' do
        before :each do
          @meta_datum_people = FactoryGirl.create :meta_datum_people,
                                                  collection: @collection,
                                                  meta_key: @meta_key_people
        end

        it 'has at least 3 people associated with it' do
          expect(@meta_datum_people.people.count).to be >= 3
        end

        describe 'to_s' do
          it 'includes the stringified people' do
            @meta_datum_people.people.each do |person|
              expect(@meta_datum_people.to_s).to include person.to_s
            end
          end
        end

        describe 'value=' do

          it 'resets the associated people' do
            expect(@meta_datum_people.people).not_to be == [@person1, @person2]
            expect do
              @meta_datum_people.value = [@person1, @person2]
            end.not_to raise_error
            expect(@meta_datum_people.people).to be == [@person1, @person2]
          end

        end

      end

    end

  end

end
