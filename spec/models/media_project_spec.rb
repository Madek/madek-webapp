require 'spec_helper'

describe Media::Project do |mp|

  it "should be producible by a factory" do
    (FactoryGirl.create :media_project).should_not == nil
  end

  context "an existing Media::Project" do

    before :each do 
      @media_project = FactoryGirl.create :media_project
      @meta_context = FactoryGirl.create :meta_context
    end

    it "should respond to individual_contexts" do
      @media_project.should respond_to(:individual_contexts)
    end

    it "should be possible to append a context" do
      lambda {@media_project.individual_contexts << @meta_context}.should_not raise_error
    end

    context "the projects individual_contexts contains an context" do

      before :each do
        @media_project.individual_contexts << @meta_context
      end

      it "should include a previously appended context" do
        @media_project.individual_contexts(true).should include(@meta_context)
      end

    end

  end


end
