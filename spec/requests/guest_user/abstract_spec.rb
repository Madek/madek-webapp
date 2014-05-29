require 'spec_helper'

describe "guest user" do

  context "accessible resources" do

    describe "should be able to access meta context pages" do
      
      before :each do
        AppSettings.create id: 0
        @meta_context = FactoryGirl.create :meta_context
      end

      it "should be able to access meta context vocabulary page" do
        get context_path @meta_context
        expect(response).to render_template(:show)
      end

      it "should be able to access meta context entries page" do
        get context_entries_path @meta_context
        expect(response).to render_template(:entries)
      end

    end

  end

end
