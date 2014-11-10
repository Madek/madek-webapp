require 'spec_helper'

describe MediaEntry do

  describe "Creation" do

    it "should be producible by a factory" do
      expect{ FactoryGirl.create :media_entry}.not_to raise_error
    end

  end

  context "an existing MediaEntry" do

    before :each do 
      @media_entry = FactoryGirl.create :media_entry
    end


    describe "MediaResourceAspect" do

      it "has a resource" do
        expect(@media_entry.resource).to be
        expect(@media_entry.resource.id).to be== @media_entry.id
      end

      it "has a responsible_user" do
        expect(@media_entry.responsible_user).to be
      end
      it "has a creator" do
        expect(@media_entry.creator).to be
      end


      describe "destroy" do
        it "removes the resource too" do
          id= @media_entry.id
          expect(@media_entry.resource).to be
          @media_entry.destroy
          expect{MediaEntryResource.find id}.to raise_error
        end
      end

    end 

  end

end
