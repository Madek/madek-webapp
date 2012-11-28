require 'spec_helper'

describe Admin::PeopleController, :type => :controller do

  before :all do
    FactoryGirl.create :usage_term 
    @adam = FactoryGirl.create :user, login: "adam"
    Group.find_or_create_by_name("Admin").users << @adam
  end

  def valid_session
    {user_id: @adam.id}
  end

  describe "index" do
    it "should respond with success" do
      get :index, {}, valid_session
      response.should be_success
    end
  end

  describe "moving metadata references from a person to another" do

    context "person2 and person1 have different metadata" do
      
      before :each do
        (@mdp1 = FactoryGirl.create :meta_datum_people).people << (@person1 = FactoryGirl.create :person)
        (@mdp2 = FactoryGirl.create :meta_datum_people).people << (@person2 = FactoryGirl.create :person)
      end

      describe "posting the transfer from person1 to person2 " do 

        before :each do
          post :transfer_meta_data, {id: @person1.id, id_receiver: @person2.id}, valid_session
        end

        describe "person1"  do
          it "should should not have any metadata" do
            expect(@person1.meta_data).to eq []
          end
        end

        describe "person2" do 
          it "should have all metadata" do
            expect(@person2.meta_data).to include @mdp1
            expect(@person2.meta_data).to include @mdp2
          end
        end

      end

    end
    
    context "both people are referred from the same metadatum" do

      before :each do
        @mdp = FactoryGirl.create :meta_datum_people
        @mdp.people << (@person1 = FactoryGirl.create :person)
        @mdp.people << (@person2 = FactoryGirl.create :person)
      end

      it "the numbers should be correct before the move"  do
        expect(@mdp.people.size).to eq 2
        expect(MetaDatum.count).to eq 1
        expect(@person1.meta_data.count).to eq 1
        expect(@person2.meta_data.count).to eq 1
      end 

      describe "posting the transfer" do

        before :each do
          post :transfer_meta_data, {id: @person1.id, id_receiver: @person2.id}, valid_session
        end

        it "the response should be success" do
          expect(response.status).to be < 400
        end

        it "should remove the meta_data from person1" do
          expect(@person1.reload.meta_data.count).to eq 0
        end

        it "should decrease the number of mdp by one" do
          expect(@mdp.reload.people.reload.size).to eq 1
        end

        it "should leave the other counts as before" do
          expect(MetaDatum.where(true).reload.count).to eq 1
          expect(@person2.reload.meta_data.count).to eq 1
        end
      end
    end
  end
end
