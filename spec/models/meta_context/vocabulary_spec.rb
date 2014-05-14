require 'spec_helper'

describe Concerns::MetaContext::Vocabulary do

  context "personas data, user normin, and the Landschaftsvisualisierung context, " do

    before :all do
      # we use the personas data for now
      DBHelper.truncate_tables
      DBHelper.load_data Rails.root.join('db','personas.data.psql')

      @user = User.find_by login: 'normin'
      @context = MetaContext.find_by name: 'Landschaftsvisualisierung'
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

