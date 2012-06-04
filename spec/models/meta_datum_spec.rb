require 'spec_helper'

describe MetaDatum do

  before :each do
    @mk = MetaKey.create  meta_datum_object_type: "MetaDatumString"
  end

  it "should raise an error when created without type and meta_key" do
    expect {MetaDatum.reate }.to raise_error
  end

  it "should not raise an error when created with a type " do
    expect {MetaDatum.create type: "MetaDatumString"}.not_to raise_error
  end

  it "should be of correct type when created with a type " do
    (MetaDatum.create type: "MetaDatumString").class.should == MetaDatumString
  end

  it "should not raise an error when created with a meta_key" do
    expect {MetaDatum.create meta_key: @mk}.not_to raise_error
  end

  it "should be of correct type when created with a meta_key" do
    (MetaDatum.create meta_key: @mk).class.should == MetaDatumString
  end


end


 
