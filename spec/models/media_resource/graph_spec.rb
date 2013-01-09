require 'spec_helper'

describe "Graph Queries" do

  before :all do
    @topset = FactoryGirl.create :media_set
    @topset.child_media_resources << (@childset1_of_topset = FactoryGirl.create :media_set)
    @topset.child_media_resources << (@childentry1_of_topset = FactoryGirl.create :media_entry)
    @childset1_of_topset.child_media_resources << (@childentry1_of_childset1_of_topset= FactoryGirl.create :media_entry)

    @disconnected_resource = FactoryGirl.create :media_set
  end

  describe "connected_resources" do 

    it "should be callable" do
      expect{MediaResource.connected_resources @topset}.not_to raise_error
    end

    it "should return the connected resources" do
      connected_of_childentry1_of_topset= MediaResource.connected_resources @childentry1_of_topset
      expect(connected_of_childentry1_of_topset).to include @topset
      expect(connected_of_childentry1_of_topset).to include @childset1_of_topset
    end

    describe "resource-condition" do

      it "should accept the condition" do
        expect{MediaResource.connected_resources@topset, MediaResource.where(type: 'MediaSet')}.not_to raise_error
      end

      it "should apply it " do
        connected_sets_of_topset = MediaResource.connected_resources @topset, MediaResource.where(type: 'MediaSet')
        expect(connected_sets_of_topset).not_to  include @childentry1_of_topset
        expect(connected_sets_of_topset).to  include @childset1_of_topset
      end

    end

  end

  describe "descendants_and_set" do

    it "should be callable" do
      expect{MediaResource.descendants_and_set @topset}.not_to raise_error
    end

    describe "the result " do

      let :result do
        MediaResource.descendants_and_set @childset1_of_topset 
      end


      it "should include the child" do
        expect(result).to include @childentry1_of_childset1_of_topset
      end

      it "should include the set itself" do
        expect(result).to include @childset1_of_topset
      end

      it "should not include the parent" do
        expect(result).not_to include @topset
      end

      
    end


  end


  describe "with_graph_size_and_title" do 

    let :graph_resources do 
      MediaResource.connected_resources @topset
    end

    it "should be callable" do
      expect{graph_resources.with_graph_size_and_title}.not_to raise_error
    end

    it "should include the correct size" do
      expect(graph_resources.with_graph_size_and_title.where(id: @topset.id).first.size.to_i).to eq 3
    end

  end

end

