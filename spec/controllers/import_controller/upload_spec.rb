require 'spec_helper'

describe ImportController do
  render_views

  before :each do
    ENV['ZENCODER_CONFIG_FILE']= (Rails.root.join "features","data","zencoder.yml").to_s
    FactoryGirl.create :usage_term
    FactoryGirl.create :meta_key, id: "copyright status", :meta_datum_object_type => "MetaDatumCopyright"
    FactoryGirl.create :meta_key, id: "description author", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, id: "description author before import", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, id: "uploaded by", :meta_datum_object_type => "MetaDatumUsers"
    FactoryGirl.create :meta_context, name: 'io_interface', is_user_interface: false
    FactoryGirl.create :meta_context, name: 'upload', is_user_interface: false
    @user = FactoryGirl.create :user
  end

  let :session do
    {:user_id => @user.id}
  end

  describe "updoad" do

    context "without providing a file" 
    it "fails" do
      expect{
        post :upload,{} , session
      }.to raise_exception
    end

    context "with file data"  do
      
      before :each do
        f = "#{Rails.root}/features/data/images/grumpy_cat.jpg"
        f_temp = "#{Rails.root}/tmp/#{File.basename(f)}"
        FileUtils.cp(f, f_temp)
        @uploaded_file= ActionDispatch::Http::UploadedFile.new(type: Rack::Mime.mime_type(File.extname(f_temp)),
                                                               tempfile: File.new(f_temp, "r"),
                                                               filename:  File.basename(f_temp))
      end

      it "is is successful" do 
        expect{ post :upload,{file: @uploaded_file} , session }.not_to raise_error
        expect(response).to be_success
      end

      context " successful upload " do

        before :each do
          @media_entry_incompletes_count_before= MediaEntryIncomplete.all.count
          post :upload,{file: @uploaded_file} , session 
        end

        it "creates media_entry_incomplete " do
          expect(MediaEntryIncomplete.all.count).to be== (@media_entry_incompletes_count_before + 1)
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
        end

        it "creates a media_file with actual file" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
          expect(@media_file= @media_entry_incomplete.media_file).to be
          expect(File.exist? @media_file.file_storage_location).to be
          expect(File.new(@media_file.file_storage_location).size).to be> 0
        end

        it "creates previews with actual files" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be
          expect(@media_file= @media_entry_incomplete.media_file).to be

          expect(@media_file.previews.count).to be>= 6
          @media_file.previews.each do |preview|
            expect(File.exist? preview.full_path).to be
            expect(File.new(preview.full_path).size).to be> 0
          end
        end

        it "sets the embedded meta data from the file" do
          expect(@media_entry_incomplete = MediaEntryIncomplete.reorder(created_at: :desc).first).to be

          expect(@media_entry_incomplete.meta_data.where(meta_key_id: 'title').first.value).to be== "Grumpy Cat"
          # TODO add more here
        end

      end

    end

  end

end




