require 'spec_helper'

describe MediaEntryIncomplete do

  before :all do 
    FactoryGirl.create :meta_key, :label => "copyright status", :meta_datum_object_type => "MetaDatumCopyright"
    FactoryGirl.create :meta_key, :label => "description author", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, :label => "description author before import", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, :label => "uploaded by", :meta_datum_object_type => "MetaDatumUsers"
    @mei = FactoryGirl.create :media_entry_incomplete
  end

  it "should be producible by a factory" do
    @mei.should_not be_nil
  end
  
  it "should contain the 'uploaded by' meta_datum after creation" do
    @mei.meta_data.map(&:meta_key).map(&:label).include?("uploaded by").should be_true
    @mei.meta_data.get_value_for("uploaded by").should == @mei.user.to_s
  end

end
