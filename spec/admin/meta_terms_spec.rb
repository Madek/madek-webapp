require 'spec_helper'

describe Admin::MetaTermsController, :type => :controller do

  before :all do
    FactoryGirl.create :usage_term 
    @adam = FactoryGirl.create :user, login: "adam"
    Group.find_or_create_by_name("Admin").users << @adam
  end

  def valid_session
    {user_id: @adam.id}
  end

  context "two meta_terms with a meta_datum each" do

    before :each do
      (@mdmt1 = FactoryGirl.create :meta_datum_meta_terms).meta_terms << (@meta_term1 = FactoryGirl.create :meta_term)
      (@mdmt2 = FactoryGirl.create :meta_datum_meta_terms).meta_terms << (@meta_term2 = FactoryGirl.create :meta_term)
    end

    describe "posting the transfer form term1 to term2" do

      before :each do
        post :transfer_meta_data, {id: @meta_term1.id, id_receiver: @meta_term2.id}, valid_session
      end

      describe "the response" do
        it "should not fail" do
          expect(response.status).to be < 400
        end
      end

      describe "@meta_term1" do
        it "should should not have any metadata" do
          expect(@meta_term1.meta_data).to eq []
        end
      end

      describe "meta_term2" do 
        it "should have all metadata" do
          expect(@meta_term2.meta_data).to include @mdmt1
          expect(@meta_term2.meta_data).to include @mdmt2
        end
      end

    end

  end



  context "two meta_terms with a keyword each" do

    before :each do
      @keyword1 = FactoryGirl.create :keyword, meta_term: (@meta_term1 = FactoryGirl.create :meta_term)
      @keyword2 = FactoryGirl.create :keyword, meta_term: (@meta_term2 = FactoryGirl.create :meta_term)
    end

    describe "posting the transfer form term1 to term2" do

      before :each do
        post :transfer_keywords, {id: @meta_term1.id, id_receiver: @meta_term2.id}, valid_session
      end

      describe "the response" do
        it "should not fail" do
          expect(response.status).to be < 400
        end
      end

      describe "@meta_term1" do
        it "should should not have any metadata" do
          expect(@meta_term1.keywords).to eq []
        end
      end

      describe "meta_term2" do 
        it "should have all metadata" do
          expect(@meta_term2.keywords).to include @keyword1
          expect(@meta_term2.keywords).to include @keyword2
        end
      end

    end

  end

end
