require 'spec_helper'

describe MediaSet do

  before :all do
    @media_set = FactoryGirl.create :media_set
  end
  
  it "should contain media entries" do
    @media_set.should respond_to :child_media_resources
    @media_set.child_media_resources.should respond_to :media_entries
  end

  it "should be producible by a factory" do
    (FactoryGirl.create :media_set).should_not == nil
  end

  context "an existing MediaSet" do

    before :each do 
      @media_set = FactoryGirl.create :media_set
      @meta_context = FactoryGirl.create :meta_context
    end

    context "meta contexts" do

      it "should respond to individual_contexts" do
        @media_set.should respond_to(:individual_contexts)
      end

      it "should be possible to append a context" do
        lambda {@media_set.individual_contexts << @meta_context}.should_not raise_error
      end

      context "the sets individual_contexts contains a context" do

        before :each do
          @media_set.individual_contexts << @meta_context
        end

        it "should include a previously appended context" do
          @media_set.individual_contexts(true).should include(@meta_context)
        end

      end
    end

    context "inheritable contexts" do 

      it "should respond to inheritable_contexts" do
        @media_set.should respond_to(:inheritable_contexts)
      end

      context "existing parents and contexts" do
        before :each do
          @media_set.parent_sets << (@parent1 = FactoryGirl.create :media_set)
          @media_set.parent_sets << (@parent2 = FactoryGirl.create :media_set)
          @parent1.individual_contexts << (@meta_context11 = FactoryGirl.create :meta_context)
          @parent1.individual_contexts << (@meta_context12 = FactoryGirl.create :meta_context)
          @parent2.individual_contexts << (@meta_context22 = FactoryGirl.create :meta_context)
          @parent2.individual_contexts << @meta_context12
        end

        it "inheritable_contexts should equal the union of the contexts of all parents" do
          @media_set.inheritable_contexts.to_a.sort.should == [@meta_context11,@meta_context12,@meta_context22].sort
        end

      end

    end

    context "child sets" do
      it "could contain sets" do
        @media_set.should respond_to :child_media_resources
        @media_set.child_media_resources.should respond_to :media_sets
      end
    end

    context "parent sets" do
      it "could be contained in sets" do
        @media_set.should respond_to :parent_sets
      end

      it "doesn't have parents, when it's a top-level set" do
        @media_set.parent_sets.should be_empty
        MediaSet.top_level.include?(@media_set).should == true
        (FactoryGirl.create :media_set).child_media_resources << @media_set
        MediaSet.top_level.include?(@media_set).should == false
      end
      
      context "many set relationships" do
        before :all do
          existing_sets_count = MediaSet.count
          existing_top_level_count = MediaSet.top_level.count
          
          sets = 10.times.map do
            FactoryGirl.create :media_set
          end
          sets[0].child_media_resources << sets[1, 2]
          sets[2].child_media_resources << sets[3, 2]
          
          (MediaSet.count - existing_sets_count).should == 10
          (MediaSet.top_level.count - existing_top_level_count).should == 6
        end
        
        it "all top-level sets do not have parents" do
          MediaSet.top_level.each do |set|
            set.parent_sets.should be_empty
          end
        end
  
        it "all non top-level sets have parents" do
          # TODO non_top_level scope ??
          (MediaSet.all - MediaSet.top_level).each do |set|
            set.parent_sets.should_not be_empty
          end
        end
      end
      
    end
    
    context "settings" do
      it "stores the layout and sorting" do
        @media_set.should respond_to(:settings)
        @media_set.settings[:layout] = l = MediaSet::ACCEPTED_SETTINGS[:layout][:possible_values].sample
        @media_set.settings[:sorting] = s = MediaSet::ACCEPTED_SETTINGS[:sorting][:possible_values].sample
        @media_set.save.should be_true
        @media_set.reload
        @media_set.settings[:layout].should == l
        @media_set.settings[:sorting].should == s
      end
    end

  end
  
  describe "the size of a media set" do

    before :each do
      @owner = FactoryGirl.create :user
      @viewer = FactoryGirl.create :user

      @top_set1 = FactoryGirl.create :media_set, user: @owner
      @top_set1.child_media_resources << (@child_11 = FactoryGirl.create :media_set, user: @owner)
      @top_set1.child_media_resources << (@child_12 = FactoryGirl.create :media_set, user: @owner)

      @child_11.child_media_resources << (@child_111 = FactoryGirl.create :media_set, user: @owner)
      @child_12.child_media_resources << (@child_121 = FactoryGirl.create :media_resource, user: @owner)

      @top_set2 = FactoryGirl.create :media_set, user: @owner
      @top_set2.child_media_resources << (@child_21 = FactoryGirl.create :media_set, user: @owner)

      FactoryGirl.create :userpermission, user: @viewer, media_resource: @child_121, view: true

    end

    it "should report 4 without user restriction" do
      @top_set1.size().should == 4
    end

    it "should report 1 with user restriction" do
      @top_set1.size(@viewer).should == 1
    end

  end

end
