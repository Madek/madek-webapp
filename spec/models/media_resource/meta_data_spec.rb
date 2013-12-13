require 'spec_helper'

describe "MetaData" do

  before :each do
    FactoryGirl.create :meta_key, id: "title"
  end

  context "an existing MediaEntry" do

    before :each do 
      @media_entry = FactoryGirl.create :media_entry
    end

    describe "the title meta datum" do

      it "should be assignable using meta_key_id" do
        meta_key_id = MetaKey.find_by_id("title").id
        title= "Some Title"
        params = {meta_data_attributes: {"0" =>  {meta_key_id: meta_key_id,value: title}}}
        @media_entry.set_meta_data(params)
        @media_entry.reload.title.should == title
      end

    end
  end
end

