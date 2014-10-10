require 'spec_helper'

describe MediaEntryIncomplete do

  before :each do 
    FactoryGirl.create :meta_key, id: "copyright status", :meta_datum_object_type => "MetaDatumCopyright"
    FactoryGirl.create :meta_key, id: "description author", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, id: "description author before import", :meta_datum_object_type => "MetaDatumPeople"
    @user = FactoryGirl.create :user
    @uploader= FactoryGirl.create :user
    @mei = FactoryGirl.create :media_entry_incomplete, user: @user
  end

  it "should be producible by a factory" do
    @mei.should_not be_nil
  end

  context "existing media_entry_incomplete and existing meta key 'uploaded by'" do

    before :each do
      @media_entry_incomplete = FactoryGirl.create :media_entry_incomplete
      FactoryGirl.create :meta_key, id: "uploaded by", :meta_datum_object_type => "MetaDatumUsers"
    end

    describe "method set_meta_data_for_importer! " do

      before :each do
        @media_entry_incomplete.set_meta_data_for_importer! @uploader
      end

      it "sets the uploader" do
        @media_entry_incomplete.meta_data.map(&:meta_key).map(&:label).include?("uploaded by").should be true
        @media_entry_incomplete.meta_data.get_value_for("uploaded by").should == @uploader.to_s
      end

    end

  end

end
