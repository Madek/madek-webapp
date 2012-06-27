FactoryGirl.define do

  factory :media_file  do
    
    # this is a mock
    meta_data { {:key => :value} }
    height { 640 }
    width { 429 }
    
    uploaded_data  {
      f = "#{Rails.root}/features/data/images/berlin_wall_01.jpg"
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                             :tempfile=> File.new(f, "r"),
                                             :filename=> File.basename(f))
    } 
  end

end
