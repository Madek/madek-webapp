require 'spec_helper'

describe "guest user" do

  context "accessible resources" do

    describe "should be able to access meta context pages" do
      
      before :all do
        @meta_context = FactoryGirl.create :meta_context
      end

      it "should be able to access meta context show page" do
        get context_path @meta_context
        expect(response).to render_template(:show)
      end

      it "should be able to access meta context abstract page" do
        get context_abstract_path @meta_context
        expect(response).to render_template(:abstract)
      end

      it "should be able to access meta context vocabulary page" do
        get context_vocabulary_path @meta_context
        expect(response).to render_template(:vocabulary)
      end

    end

  end

end
