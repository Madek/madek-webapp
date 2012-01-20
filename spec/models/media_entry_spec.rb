require 'spec_helper'

describe MediaEntry do

  it "should be producible by a factory" do
    (FactoryGirl.create :media_entry).should_not == nil
  end
  
  it "if not explicitly provided, should not contain any meta_data after creation" do
    media_entry = FactoryGirl.create :media_entry
    media_entry.meta_data.blank?.should == true
  end

  context "an existing MediaEntry" do

    before :each do 
      @media_entry = FactoryGirl.create :media_entry
    end

    it "title should be assignable using meta_key_id" do
      params = {:meta_data_attributes => {"0" => {:meta_key_id => MetaKey.find_by_label("title").id, :value => "My new value using meta_key_id"}}}
      @media_entry.update_attributes(params)
      @media_entry.title.should == "My new value using meta_key_id"
    end

    it "title should be assignable using meta_key_label" do
      params = {:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => "My new value using meta_key_label"}}}
      @media_entry.update_attributes(params)
      @media_entry.title.should == "My new value using meta_key_label"
    end

  end

end
