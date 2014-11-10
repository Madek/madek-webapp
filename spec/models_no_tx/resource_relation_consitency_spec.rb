require 'spec_helper'
require 'spec_helper_no_tx'


describe "resources relation consistency" do


  before :each do 
    clean_db
  end

  describe "media entry factory" do

    it "doesn't raise an error" do
      expect{
        ActiveRecord::Base.transaction do
          @media_entry= FactoryGirl.create :media_entry
        end
      }.not_to raise_error
    end

  end

  context "existing media_entry with resource " do

    before (:each) do 
      ActiveRecord::Base.transaction do
        @media_entry= FactoryGirl.create :media_entry
      end
    end

    it "really exists and has a resource"  do
      expect(@media_entry).to be
      expect(@media_entry.resource).to be
    end

   
    describe "deleting the media_entry only" do
      it "raises an error" do
        expect{
          ActiveRecord::Base.transaction do
            ActiveRecord::Base.connection.execute "DELETE FROM media_entries"
          end
        }.to raise_error(ActiveRecord::StatementInvalid,/should have been deleted with its sibling/)
      end
    end

    describe "deleting the resource only" do
      it "raises an error" do
        expect{
          ActiveRecord::Base.transaction do
            ActiveRecord::Base.connection.execute "DELETE FROM resources"
          end
        }.to raise_error
      end
    end


    context "an existing collection with resource" do

      before (:each) do 
        ActiveRecord::Base.transaction do
          @collection= FactoryGirl.create :collection
        end
      end

      it "really exists and has a resource"  do
        expect(@collection).to be
        expect(@collection.resource).to be
      end

      describe "re-pointing the id media_entry and creating an inconsistency" do

        it "raises an error on commit" do
          expect{
            ActiveRecord::Base.transaction do
              ActiveRecord::Base.connection.execute \
                "UPDATE media_entries SET id = '#{@collection.id}' WHERE id = '#{@media_entry.id}'"
            end
          }.to raise_error(ActiveRecord::StatementInvalid,/must have exactly one sibbling/)
        end

      end


    end

  end

end

