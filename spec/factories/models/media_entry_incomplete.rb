
FactoryGirl.define do

  factory :media_entry_incomplete do
    user {User.find_random || (FactoryGirl.create :user)}

    uploaded_data  do
      f = "#{Rails.root}/features/data/images/berlin_wall_01.jpg"

      # Need to copy this file to a temporary new file because files are moved away after succesful
      # uploads!
      f_temp = "#{Rails.root}/tmp/#{File.basename(f)}"

      FileUtils.cp(f, f_temp)
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f_temp)),
                                             :tempfile=> File.new(f_temp, "r"),
                                             :filename=> File.basename(f_temp))
    end
  end

end
