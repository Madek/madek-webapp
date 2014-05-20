require 'spec_helper'

describe Concerns::MetaContext::Vocabulary do

  context "personas data, user normin, and the Landschaftsvisualisierung context, " do

    # TODO we use the personas data for now since we do not have a minimal # meta data set; 
    # this MUST BE FIXED; the personas data is to variable and messy to perform 
    # checks in this manner


    before :all do
      DBHelper.truncate_tables
      DBHelper.load_data Rails.root.join('db','personas.data.psql')

      @user = User.find_by login: 'normin'
      @context = MetaContext.find_by name: 'Landschaftsvisualisierung'
    end

    describe "getting the included (individual) media_entries" do

      it "should not raise an error" do
        expect{ @context.media_entries @user }.not_to raise_error
      end

      it "includes 'Diplom' (8b5050fe-280d-4712-9acb-fe8323e5c33e) e.g." do
        @context.media_entries(@user).map(&:id).should include '8b5050fe-280d-4712-9acb-fe8323e5c33e'
      end

      describe " the count" do
        it "should be >= 5" do 
          @context.media_entries_count(@user).should be>= 5
        end
      end
    end

    describe "building the vocabulary," do

      it "should not raise an error" do
        expect{ @context.build_vocabulary @user }.not_to raise_error
      end

    end

    describe "the vocabulary, " do

      before :each do 
        @vocabulary= @context.build_vocabulary @user
      end

      it "contains an item with the label 'Landschaftstyp'" do 
        @vocabulary.select{|item| item[:label]== 'Landschaftstyp'}.should_not be_empty
      end

      describe "the 'Landschaftstyp' item" do
        before :each do
          @landschaftstyp_item= @vocabulary.select{|item| item[:label]== 'Landschaftstyp'}.first
        end
        it "contains a 'Agglomeration' term which is used at least once"  do
          agglomeration_term= @landschaftstyp_item[:meta_terms].select{|mt| mt[:term] ==  'Agglomeration'}.first
          agglomeration_term.should be
          agglomeration_term[:usage_count].should be>= 1
        end
      end

    end
  end
end

