require 'spec_helper'

describe EditSession do

  describe "Creation" do

    it "should be producible by a factory" do

      expect{ FactoryGirl.create :edit_session, media_entry: FactoryGirl.create(:media_entry) }.not_to raise_error
      expect{ FactoryGirl.create :edit_session, collection: FactoryGirl.create(:collection) }.not_to raise_error
      expect{ FactoryGirl.create :edit_session, filter_set: FactoryGirl.create(:filter_set) }.not_to raise_error

    end

    it "should raise an error if neither media entry, collection nor filter set is provided" do

      expect{ FactoryGirl.create :edit_session}.to raise_error

    end

    it "should raise an error if 2 or more of media entry, collection or filter is provided" do

      expect do
        FactoryGirl.create :edit_session,
          media_entry: FactoryGirl.create(:media_entry),
          collection: FactoryGirl.create(:collection)
      end
        .to raise_error

    end


  end
end
