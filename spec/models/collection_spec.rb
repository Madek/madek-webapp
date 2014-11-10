require 'spec_helper'

describe Collection do

  describe "Creation" do

    it "should be producible by a factory" do
      expect{ FactoryGirl.create :collection}.not_to raise_error
    end

  end

  context "an existing Collection" do

    before :each do 
      @collection = FactoryGirl.create :collection
    end


    describe "MediaResourceAspect" do

      it "has a resource" do
        expect(@collection.resource).to be
        expect(@collection.resource.id).to be== @collection.id
      end

      it "has a responsible_user" do
        expect(@collection.responsible_user).to be
      end

      it "has a creator" do
        expect(@collection.creator).to be
      end

      it "has a updator" do
        expect(@collection.creator).to be
      end

      describe "destroy" do
        it "removes the resource too" do
          id= @collection.id
          expect(@collection.resource).to be
          @collection.destroy
          expect{CollectionResource.find id}.to raise_error
        end
      end

    end 

  end

end
