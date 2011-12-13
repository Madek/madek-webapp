require 'spec_helper'

describe Media::Set do

  before :all do
    @media_set = FactoryGirl.create :media_set
  end

  it "should contain sets" do
    @media_set.should respond_to :child_sets
  end
  
  pending "should contain media entries" do
    
  end
  

end
