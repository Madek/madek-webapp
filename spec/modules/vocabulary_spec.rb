require 'spec_helper'

describe ::Vocabulary do

  include MetaContextTermTestFactory

  context "personas data, user normin, and the Character context from MetaContextTermTestFactory, " do

    before :all do
      DBHelper.truncate_tables
      DBHelper.load_data Rails.root.join('db','personas.data.psql')
      @user = User.find_by login: 'normin'
      clean_and_then_build_minimal_vocabulary
      build_vocabulary_example_media_resources @user
    end

    describe "getting the included (individual) media_entries" do

      it "should not raise an error" do
        expect{ ::Vocabulary.media_entries(@context_character, @user) }.not_to raise_error
      end

      it "includes 'EmptyCharacterEntry' e.g." do
        ::Vocabulary.media_entries(@context_character,@user).map(&:id).should include @empty_character_entry.id
      end

      it "includes 'Nike' e.g." do
        ::Vocabulary.media_entries(@context_character,@user).map(&:id).should include @nike_entry.id
      end

      describe " the count" do
        it "should be== 3" do 
          ::Vocabulary.media_entries_count(@context_character,@user).should be== 3
        end
      end
    end

    describe "building the vocabulary for context and user," do

      it "should not raise an error" do
        expect{ ::Vocabulary.build_for_context_and_user(@context_character,@user) }.not_to raise_error
      end


      describe "the vocabulary, " do

        before :each do 
          @vocabulary= ::Vocabulary.build_for_context_and_user @context_character, @user
        end

        it "contains an item with the label 'Goddess'" do 
          @vocabulary.select{|item| item[:label]== 'Goddess'}.should_not be_empty
        end

        describe "the 'Godess' item" do
          before :each do
            @goddess_item= @vocabulary.select{|item| item[:label]== 'Goddess'}.first
          end
          it "contains a 'Athena' term which is used at least once"  do
            meta_term_athena= @goddess_item[:meta_terms].select{|mt| mt[:term] ==  'Athena'}.first
            meta_term_athena.should be
            meta_term_athena[:usage_count].should be>= 1
          end
        end

      end
    end


    describe "building the vocabulary for context, set  and user," do

      context "the set_for_contex_character " do

        before :each do
          @set = @context_character.media_sets.first
        end

        it "exists" do 
          expect{@set}.to be 
        end

        it "is the character set" do
          expect(@set).to be== @set_for_contex_character
        end

        it "has children" do
           @set_for_contex_character.child_media_resources.count.should be== 3
        end

        describe "::Vocabulary.meta_terms_for_set" do

          before :each do
            @terms = ::Vocabulary.meta_terms_for_set(@set_for_contex_character) 
          end

          it "has 2 terms" do
            @terms.count.should be== 2
          end
        end

        describe "build_for_context_set_and_user" do

          it "succeeds" do
            expect{  
              ::Vocabulary.build_for_context_set_and_user(
                @context_character,@set_for_contex_character,@user)
            }.not_to raise_error
          end

          describe "the vocabulary, " do

            before :each do 
              @vocabulary= ::Vocabulary.build_for_context_set_and_user @context_character,@set_for_contex_character, @user
            end

            it "contains an item with the label 'Goddess'" do 
              @vocabulary.select{|item| item[:label]== 'Goddess'}.should_not be_empty
            end

            describe "the 'Goddess' item" do

              before :each do
                @item= @vocabulary.select{|item| item[:label]== 'Goddess'}.first
              end

              it "contains a 'Nike' term which is used twice"  do
                meta_term_nike= @item[:meta_terms].select{|mt| mt[:term] ==  'Nike'}.first
                meta_term_nike.should be
                meta_term_nike[:usage_count].should be== 2
              end

              it "contains a 'Athena' term which is used once"  do
                meta_term_athena= @item[:meta_terms].select{|mt| mt[:term] ==  'Athena'}.first
                meta_term_athena.should be
                meta_term_athena[:usage_count].should be== 1
              end

            end

          end

        end

      end

    end

  end

end

