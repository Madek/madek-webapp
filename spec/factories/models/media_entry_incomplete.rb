
FactoryGirl.define do

  factory :media_entry_incomplete do
    user {User.find_random || (FactoryGirl.create :user)}

    uploaded_data  do
      f = "#{Rails.root}/features/data/images/berlin_wall_01.jpg"
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                             :tempfile=> File.new(f, "r"),
                                             :filename=> File.basename(f))
    end
  end

end
