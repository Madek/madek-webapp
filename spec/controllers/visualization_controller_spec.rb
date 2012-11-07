require 'spec_helper'

describe VisualizationController do
  render_views

  before :all do
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user

    #  @set 
    #    -> @child_of_set
    #    -> @childset_of_set
    #         -> @childset_of_childset_of_set
    #             -> #@child_of_childset_of_childset_of_set

    @set = FactoryGirl.create :media_set_with_title, user: @user

    @child_of_set = FactoryGirl.create :media_entry, user: @user
    @set.child_media_resources << @child_of_set

    @childset_of_set = FactoryGirl.create :media_set_with_title, user: @user
    @set.child_media_resources << @childset_of_set

    @childset_of_childset_of_set = FactoryGirl.create :media_set_with_title, user: @user
    @childset_of_set.child_media_resources << @childset_of_childset_of_set

    @child_of_childset_of_childset_of_set = FactoryGirl.create :media_entry_with_title, user: @user
    @childset_of_childset_of_set.child_media_resources << @child_of_childset_of_childset_of_set

    @all_nodes = [@set,@child_of_set,@childset_of_set,@childset_of_childset_of_set,@child_of_childset_of_childset_of_set]
    @all_sets = [@set,@childset_of_set,@childset_of_childset_of_set]

  end

  def valid_session
    {user_id: @user.id}
  end


  describe "GET 'my_sets'" do

    def get_request  
      get 'my_component_with',{format: 'html',id: @child_of_set.id,insert_to_dom: true}, valid_session
    end

    it "returns http success" do
      get 'my_sets',{format: 'html', insert_to_dom: true}, valid_session
      response.should be_success
    end

    it "assignes @resources, @arcs, @resource_identifier, @control_settings  and @layout " do
      get 'my_sets',{format: 'html', insert_to_dom: true}, valid_session
      expect(assigns(:resources)).to be
      expect(assigns(:arcs)).to be
      expect(assigns(:resource_identifier)).to be
      expect(assigns(:control_settings)).to be
      expect(assigns(:layout)).to be
    end

    describe "@resources" do
      it "should include all sets" do
        get_request
        @all_sets.each do |node| 
          expect(assigns[:resources].map(&:id)).to include node.id
        end
      end
    end

    describe "nodes in the rendered html" do
      it "should be equal to the number or resources" do
        get_request
        page = Capybara::Node::Simple.new(@response.body)
        nodes = JSON.parse(page.find("#graph-data")['data-nodes'])
        expect(nodes.size).to eq assigns[:resources].size
      end
    end

    describe "nodes in the rendered html" do
      it "should be equal to the number or resources" do
        get_request
        page = Capybara::Node::Simple.new(@response.body)
        nodes = JSON.parse(page.find("#graph-data")['data-nodes'])
        expect(nodes.size).to eq assigns[:resources].size
      end
    end

  end

  ### component ############################################################################
 
  describe "GET 'my_component_with'" do

    def get_request  
      get 'my_component_with',{format: 'html',id: @child_of_set.id,insert_to_dom: true}, valid_session
    end


    it "returns http success" do
      get_request
      response.should be_success
    end

    it "assignes @resources, @arcs, @resource_identifier, @control_settings  and @layout " do
      get_request
      expect(assigns(:resources)).to be
      expect(assigns(:arcs)).to be
      expect(assigns(:resource_identifier)).to be
      expect(assigns(:control_settings)).to be
      expect(assigns(:layout)).to be
    end

    describe "@resources" do
      it "should include all resources" do
        get_request
        @all_nodes.each do |node| 
          expect(assigns[:resources].map(&:id)).to include node.id
        end
      end
    end

    describe "nodes in the rendered html" do
      it "should be equal to the number or resources" do
        get_request
        page = Capybara::Node::Simple.new(@response.body)
        nodes = JSON.parse(page.find("#graph-data")['data-nodes'])
        expect(nodes.size).to eq assigns[:resources].size
      end
    end

    describe "arcs in the rendered html" do
      it "should be present and not empty" do
        get_request
        page = Capybara::Node::Simple.new(@response.body)
        arcs = JSON.parse(page.find("#graph-data")['data-arcs'])
        expect(arcs).to be
        expect(arcs.size).to_not eq(0)
      end
    end

  end

  ### descendants ############################################################################

  describe "GET 'my_descendants_of'" do

    def get_request  
      get 'my_descendants_of',{format: 'html',id: @set.id,insert_to_dom: true}, valid_session
    end

    it "returns http success" do
      get_request
      response.should be_success
    end

    it "assignes @resources, @arcs, @resource_identifier, @control_settings  and @layout " do
      get_request
      expect(assigns(:resources)).to be
      expect(assigns(:arcs)).to be
      expect(assigns(:resource_identifier)).to be
      expect(assigns(:control_settings)).to be
      expect(assigns(:layout)).to be
    end

    describe "@resources" do
      it "should include all resources" do
        get_request
        @all_nodes.each do |node| 
          expect(assigns[:resources].map(&:id)).to include node.id
        end
      end
    end

    describe "arcs in the rendered html" do
      it "should be present and not empty" do
        get_request
        page = Capybara::Node::Simple.new(@response.body)
        arcs = JSON.parse(page.find("#graph-data")['data-arcs'])
        expect(arcs).to be
        expect(arcs.size).to_not eq(0)
      end
    end

    describe "nodes in the rendered html" do
      it "should be equal to the number or resources" do
        get_request
        page = Capybara::Node::Simple.new(@response.body)
        nodes = JSON.parse(page.find("#graph-data")['data-nodes'])
        expect(nodes.size).to eq assigns[:resources].size
      end
    end

    describe "the size property of a resource" do
      it "should be equal to the number of descendants" do
        get_request
        page = Capybara::Node::Simple.new(@response.body)
        nodes = Hash[JSON.parse(page.find("#graph-data")['data-nodes']).map{|r| [r['id'],r]}]
        expect(nodes[@set.id]["size"].to_i).to eq(4)
        expect(nodes[@child_of_set.id]["size"].to_i).to eq(0)
        expect(nodes[@childset_of_set.id]["size"].to_i).to eq(2)
        expect(nodes[@childset_of_childset_of_set.id]["size"].to_i).to eq(1)
        expect(nodes[@child_of_childset_of_childset_of_set.id]["size"].to_i).to eq(0)
      end
    end

  end

end
