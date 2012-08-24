require 'spec_helper'

describe MetaDatum do

  before :each do
    @mk = MetaKey.find_by_label("title") || FactoryGirl.create(:meta_key_title) 
    @mr = FactoryGirl.create :media_set
  end

  it "should raise an error when created without type and meta_key" do
    expect {MetaDatum.create }.to raise_error
  end

  it "should raise an error when instantiated without type and meta_key" do
    expect {MetaDatum.create }.to raise_error
  end

  it "should be of correct type when created with a meta_key" do
    (MetaDatum.create meta_key: @mk, media_resource: @mr).class.should == MetaDatumString
  end

end


 
