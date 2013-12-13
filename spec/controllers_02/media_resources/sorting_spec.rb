require 'spec_helper'

describe MediaResourcesController, type: :controller do
  render_views

  before :each do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :meta_context_core
    @user = FactoryGirl.create :user
  end

  let :session do
    {:user_id => @user.id}
  end


  describe "sorting resources" do

    before :each do
      @media_sets = 10.times.map{FactoryGirl.create :media_set_with_title, user: @user}
    end

    let :extract_resources do
      JSON.parse(response.body)["media_resources"].map{|h| MediaResource.find_by_id(h["id"])}
    end

    describe "ordering by title" do

      before :each do
        get :index, {format: "json", sort: "title"}, session
      end

      it "should be successful" do
        response.should  be_success
      end

      it "should assign @media_resources" do
        JSON.parse(response.body)["media_resources"].should be
      end

      it "should be ordered by title" do
        # REMARK this fails sometimes, could be collation in database
        # ["at dolorem rerum impedit", "at dolor minima tempore"]
        # ["at dolor minima tempore", "at dolorem rerum impedit"]
        # not reproducible on my macbook
        resources = extract_resources 
        resources.map(&:title).sort.should ==  resources.map(&:title)
      end

    end

    describe "ordering by author" do

      before :each do
      end

      let :get_ordered_by_author do
        get :index, {format: "json", sort: "author"}, session
      end

      it "should be successful" do
        get_ordered_by_author
        response.should  be_success
      end


      describe "correct ordering" do

        before :each do
          @aa= Person.create  last_name:"A", first_name: "A"
          @ab= Person.create  last_name:"A", first_name: "B"
          @az= Person.create  last_name:"A", first_name: "Z"
          @bb= Person.create  last_name:"B", first_name: "B"
          @cc= Person.create  last_name:"C", first_name: "C"
          @zz= Person.create  last_name:"Z", first_name: "Z"
        end

        it "should list entries with multiple authors multiply" do
          @media_sets[0].set_meta_data({:meta_data_attributes => {"0" => {:meta_key_label => "author", :value => [@bb,@aa]}}})
          get_ordered_by_author
          resources = extract_resources
          resources.size.should == 2
        end

        it "should use the consider the first name" do
          @media_sets[0].set_meta_data({:meta_data_attributes => {"0" => {:meta_key_label => "author", :value => @ab}}})
          @media_sets[1].set_meta_data({:meta_data_attributes => {"0" => {:meta_key_label => "author", :value => @aa}}})
          get_ordered_by_author
          resources = extract_resources
          resources[0].should == @media_sets[1]
          resources[1].should == @media_sets[0]
        end

        it "should order them" do
          @media_sets[0].set_meta_data({:meta_data_attributes => {"0" => {:meta_key_label => "author", :value => @zz}}})
          @media_sets[1].set_meta_data({:meta_data_attributes => {"0" => {:meta_key_label => "author", :value => @aa}}})
          @media_sets[2].set_meta_data({:meta_data_attributes => {"0" => {:meta_key_label => "author", :value => @cc}}})
          @media_sets[3].set_meta_data({:meta_data_attributes => {"0" => {:meta_key_label => "author", :value => @bb}}})
          get_ordered_by_author
          resources = extract_resources
          resources[0].should == @media_sets[1]
          resources[1].should == @media_sets[3]
          resources[2].should == @media_sets[2]
          resources[3].should == @media_sets[0]
        end

      end

    end

  end

end
