require 'spec_helper'

describe MediaSetsController do

  before :each do
    @media_set = FactoryGirl.create :media_set
  end

  describe "GET inheritable_contexts" do

    it "assigns inheritable_contexts" do
      get :inheritable_contexts, :id => @media_set.id 
      assigns(:inheritable_contexts).should eq([])
    end

  end

end
