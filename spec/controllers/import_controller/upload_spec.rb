require 'spec_helper'

describe ImportController do
  include Controllers::Shared
  render_views

  before :all do
    truncate_tables
    ENV['ZENCODER_CONFIG_FILE']= (Rails.root.join "spec","data","zencoder.yml").to_s
    FactoryGirl.create :usage_term
    FactoryGirl.create :meta_key, id: "copyright status", :meta_datum_object_type => "MetaDatumCopyright"
    FactoryGirl.create :meta_key, id: "description author", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, id: "description author before import", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, id: "uploaded by", :meta_datum_object_type => "MetaDatumUsers"
    FactoryGirl.create :context, id: 'upload'
    FactoryGirl.create :io_interface
    @user = FactoryGirl.create :user
  end

  after :all do
    truncate_tables
  end

  describe "prerequisite MetaKey.meta_key_for " do
    it "returns an meta_key object" do
      expect(MetaKey.meta_key_for("XMP-madek:PortrayedObjectDates")).to be
    end
  end

  describe "updoad" do

    context "without providing a file" 
    it "fails" do
      expect{
        post :upload,{} , valid_session(@user)
      }.to raise_exception
    end

    context "with a jpg file"  do
      
      before :each do
        f = "#{Rails.root}/spec/data/images/grumpy_cat.jpg"
        f_temp = "#{Rails.root}/tmp/#{File.basename(f)}"
        FileUtils.cp(f, f_temp)
        @uploaded_file= ActionDispatch::Http::UploadedFile.new(type: Rack::Mime.mime_type(File.extname(f_temp)),
                                                               tempfile: File.new(f_temp, "r"),
                                                               filename:  File.basename(f_temp))
      end

      it "is is successful" do 
        expect{ post :upload,{file: @uploaded_file} , valid_session(@user) }.not_to raise_error
        expect(response).to be_success
      end

      context " successful upload " do

        before :each do
          @media_entry_incompletes_count_before= MediaEntryIncomplete.all.count
          post :upload,{file: @uploaded_file} , valid_session(@user)
        end

        it "creates media_entry_incomplete " do
          expect(MediaEntryIncomplete.all.count).to be== (@media_entry_incompletes_count_before + 1)
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
        end

        it "creates a media_file with actual file and properties" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
          expect(@media_file= @media_entry_incomplete.media_file).to be
          expect(File.exist? @media_file.file_storage_location).to be
          expect(File.new(@media_file.file_storage_location).size).to be> 0
        
          expect(@media_file.filename).to be== "grumpy_cat.jpg"
          expect(@media_file.content_type).to be== "image/jpeg"
          expect(@media_file.size).to be== 54335
          expect(@media_file.width).to be== 480 
          expect(@media_file.height).to be== 360
          expect(@media_file.extension).to be== "jpg" 
          expect(@media_file.media_type).to be== "image"
        end

        it "creates previews with actual files" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
          expect(@media_file= @media_entry_incomplete.media_file).to be

          expect(@media_file.previews.count).to be>= 4
          @media_file.previews.each do |preview|
            expect(File.exist? preview.full_path).to be
            expect(File.new(preview.full_path).size).to be> 0
          end
        end

        it "sets the embedded meta data from the file" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
          expect(@meta_data = @media_entry_incomplete.meta_data).to be

          expect(@meta_data.get("author").value.first.to_s).to be==  "Cahenzli, Ramon"
          expect(@meta_data.get("marked").value).to be== "t"
          expect(@meta_data.get("portrayed object dates").value).to be== "30.05.2011"
          expect(@meta_data.get("rights").value).to be==  "Ramón Cahenzli"
          expect(@meta_data.get("title").value).to be== "Grumpy Cat"
          expect(@meta_data.get("uploaded by").value.first).to be== @user
          expect(@meta_data.get("usage terms").value).to be== "Bitte jeweils die angegebenen Nutzungsmodifikationen beachten."
          expect(@meta_data.get("web statement").value).to be== "http://creativecommons.org/licenses/by/2.5/ch/"

        end

      end

    end

    context "with a pdf file"  do
      
      before :each do
        f = "#{Rails.root}/spec/data/files/test_pdf_for_metadata.pdf"
        f_temp = "#{Rails.root}/tmp/#{File.basename(f)}"
        FileUtils.cp(f, f_temp)
        @uploaded_file= ActionDispatch::Http::UploadedFile.new(type: Rack::Mime.mime_type(File.extname(f_temp)),
                                                               tempfile: File.new(f_temp, "r"),
                                                               filename:  File.basename(f_temp))
      end

      it "is is successful" do 
        expect{ post :upload,{file: @uploaded_file} , valid_session(@user) }.not_to raise_error
        expect(response).to be_success
      end

      context " successful upload " do

        before :each do
          @media_entry_incompletes_count_before= MediaEntryIncomplete.all.count
          post :upload,{file: @uploaded_file} , valid_session(@user) 
        end

        it "creates media_entry_incomplete " do
          expect(MediaEntryIncomplete.all.count).to be== (@media_entry_incompletes_count_before + 1)
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
        end

        it "creates a media_file with actual file and properties" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
          expect(@media_file= @media_entry_incomplete.media_file).to be
          expect(File.exist? @media_file.file_storage_location).to be
          expect(File.new(@media_file.file_storage_location).size).to be> 0
        
          expect(@media_file.filename).to be== "test_pdf_for_metadata.pdf"
          expect(@media_file.content_type).to be== "application/pdf"
          expect(@media_file.size).to be== 24469
          expect(@media_file.width).to be== nil
          expect(@media_file.height).to be== nil
          expect(@media_file.extension).to be== "pdf"
          expect(@media_file.media_type).to be== "document"
        end

        it "creates previews with actual files" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
          expect(@media_file= @media_entry_incomplete.media_file).to be

          expect(@media_file.previews.count).to be>= 5
          @media_file.previews.each do |preview|
            expect(File.exist? preview.full_path).to be
            expect(File.new(preview.full_path).size).to be> 0
          end
        end

        it "uploaded by meta-datum" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
          expect(@meta_data = @media_entry_incomplete.meta_data).to be
          expect(@meta_data.get("uploaded by").value.first).to be== @user
        end

      end

    end

  end

end




