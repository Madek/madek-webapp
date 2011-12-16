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

    context "meta contexts" do

      it "should respond to individual_contexts" do
        @media_project.should respond_to(:individual_contexts)
      end

      it "should be possible to append a context" do
        lambda {@media_project.individual_contexts << @meta_context}.should_not raise_error
      end

      context "the projects individual_contexts contains a context" do

        before :each do
          @media_project.individual_contexts << @meta_context
        end

        it "should include a previously appended context" do
          @media_project.individual_contexts(true).should include(@meta_context)
        end

      end
    end

    context "inheritable contexts" do 

      it "should respond to inheritable_contexts" do
        @media_project.should respond_to(:inheritable_contexts)
      end

      context "existing parents and contexts" do
        before :each do
          @media_project.parent_sets << (@parent1 = FactoryGirl.create :media_project)
          @media_project.parent_sets << (@parent2 = FactoryGirl.create :media_project)
          @parent1.individual_contexts << (@meta_context11 = FactoryGirl.create :meta_context)
          @parent1.individual_contexts << (@meta_context12 = FactoryGirl.create :meta_context)
          @parent2.individual_contexts << (@meta_context22 = FactoryGirl.create :meta_context)
          @parent2.individual_contexts << (@meta_context12)
        end

        it "inheritable_contexts should equal the union of the contexts of all parents" do
          @media_project.inheritable_contexts.to_a.sort.should == [@meta_context11,@meta_context12,@meta_context21].sort
        end

      end
      

    end

  end

end
