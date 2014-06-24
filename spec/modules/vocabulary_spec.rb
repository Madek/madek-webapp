require 'spec_helper'

describe ::Vocabulary do

  context "personas data, user normin, and the Landschaftsvisualisierung context, " do

    # TODO we use the personas data for now since we do not have a minimal # meta data set; 
    # this MUST BE FIXED; the personas data is to variable and messy to perform 
    # checks in this manner


    before :all do
      DBHelper.truncate_tables
      DBHelper.load_data Rails.root.join('db','personas.data.psql')

      @user = User.find_by login: 'normin'
      @context = Context.find_by id: 'Landschaftsvisualisierung'
    end

    describe "getting the included (individual) media_entries" do

      it "should not raise an error" do
        expect{ ::Vocabulary.media_entries(@context, @user) }.not_to raise_error
      end

      it "includes 'Diplom' (8b5050fe-280d-4712-9acb-fe8323e5c33e) e.g." do
        ::Vocabulary.media_entries(@context,@user).map(&:id).should include '8b5050fe-280d-4712-9acb-fe8323e5c33e'
      end

      describe " the count" do
        it "should be >= 5" do 
          ::Vocabulary.media_entries_count(@context,@user).should be>= 5
        end
      end
    end

    describe "building the vocabulary for context and user," do

      it "should not raise an error" do
        expect{ ::Vocabulary.build_for_context_and_user(@context,@user) }.not_to raise_error
      end


      describe "the vocabulary, " do

        before :each do 
          @vocabulary= ::Vocabulary.build_for_context_and_user @context, @user
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


    describe "building the vocabulary for context, set  and user," do

      context "the first set of the Landschaftsvisualisierung" do

        before :each do
          @set = @context.media_sets.first
        end

        it "exists" do 
          expect{@set}.to be 
        end

        it "has children" do
           @set.child_media_resources.count.should be>= 1
        end

        describe "::Vocabulary.meta_terms_for_set" do

          before :each do
            @terms = ::Vocabulary.meta_terms_for_set(@set) 
          end

          it "has terms" do
            @terms.count.should be>= 1
          end
        end

        describe "build_for_context_set_and_user" do

          it "succeeds" do
            expect{  
              ::Vocabulary.build_for_context_set_and_user(
                @context,@set,@user)
            }.not_to raise_error
          end

          describe "the vocabulary, " do

            before :each do 
              @vocabulary= ::Vocabulary.build_for_context_set_and_user @context,@set, @user
            end

            it "contains an item with the label 'Landschaftstyp'" do 
              @vocabulary.select{|item| item[:label]== 'Landschaftstyp'}.should_not be_empty
            end

            describe "the 'Stil- und Kunstrichtungen' item" do
              before :each do
                @suk_item= @vocabulary.select{|item| item[:label]== 'Stil- und Kunstrichtungen'}.first
              end
              it "contains a 'Konzeptkunst' term which is used at least once"  do
                konzeptkunst_term= @suk_item[:meta_terms].select{|mt| mt[:term] ==  'Konzeptkunst'}.first
                konzeptkunst_term.should be
                konzeptkunst_term[:usage_count].should be>= 1
              end
            end

          end


        end

      end

    end

  end

end

