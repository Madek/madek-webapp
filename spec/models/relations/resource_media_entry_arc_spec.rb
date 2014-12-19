require 'spec_helper'

describe CollectionMediaEntryArc do

  context 'A MediaEntry and a Collection' do

    before :each do
      @media_entry = FactoryGirl.create :media_entry
      @collection = FactoryGirl.create :collection
    end

    describe CollectionMediaEntryArc do

      it 'is producible by a factory ' do
        expect do
          FactoryGirl.create :collection_media_entry_arc,
                             media_entry: @media_entry,
                             collection: @collection
        end.not_to raise_error
      end

      context %(a CollectionMediaEntryArc connects the media_entry \
                with the collection ) do

        before :each do
          @arc = FactoryGirl.create :collection_media_entry_arc,
                                    media_entry: @media_entry,
                                    collection: @collection
        end

        it 'belongs_to the media_entry' do
          expect(@arc.media_entry).to be == @media_entry
        end

        it 'belongs_to the collection' do
          expect(@arc.collection).to be == @collection
        end

        describe 'collection.media_resource_arcs' do
          it 'includes the arc' do
            expect(@collection.collection_media_entry_arcs).to include @arc
          end
        end

        describe 'the collection.media_entries ' do
          it 'includes the media_entry' do
            expect(@collection.media_entries).to include @media_entry
          end
        end

        describe 'the media_entry.collection_media_entry_arcs ' do
          it 'includes the arc' do
            expect(@media_entry.collection_media_entry_arcs).to include @arc
          end
        end

        describe 'the media_entry.collections ' do
          it 'includes the collection' do
            expect(@media_entry.collections).to include @collection
          end
        end

      end

    end

  end

end
