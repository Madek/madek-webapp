require 'spec_helper'

describe MediaSetsController do

  before :each do
    @media_set = FactoryGirl.create :media_project
  end

  describe "GET inheritable_contexts" do

    pending "assigns inheritable_contexts" do
      get :inheritable_contexts, :id => @media_set.id 
      assigns(:inheritable_contexts).should == []
    end

  end

end
