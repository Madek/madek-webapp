require 'spec_helper'

describe MediaResource do

  before :all do
    FactoryGirl.create :meta_key, :label => "title"
  end

  context "an existing MediaEntry" do

    before :each do 
      @media_entry = FactoryGirl.create :media_entry
    end

    describe "the title meta_datum" do

      it "it should be assignable using meta_key_id" do
        meta_key_id = MetaKey.find_by_label("title").id

        title = "My new value using meta_key_id with symbol keys"
        params = {meta_data_attributes: {"0" =>  {meta_key_id: meta_key_id,value: title}}}
        @media_entry.update_attributes(params)
        @media_entry.reload.title.should == title

        title = "My new value using meta_key_id with string keys"
        params = {"meta_data_attributes" =>  {"0" =>  {"meta_key_id" => meta_key_id, "value" => title}}}
        @media_entry.update_attributes(params)
        @media_entry.reload.title.should == title
      end

      it "it should be assignable using meta_key_label" do
        title = "My new value using meta_key_label with symbol keys"
        params = {meta_data_attributes: {"0" =>  {meta_key_label: "title",value: title}}}
        @media_entry.update_attributes(params)
        @media_entry.reload.title.should == title

        title = "My new value using meta_key_label with string keys"
        params = {"meta_data_attributes" => {"0" =>  {"meta_key_label" => "title", "value" => title}}}
        @media_entry.update_attributes(params)
        @media_entry.reload.title.should == title
      end

    end

  end


end


