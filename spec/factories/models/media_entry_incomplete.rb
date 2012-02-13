
FactoryGirl.define do

  factory :media_entry_incomplete do
    user {User.find_random || (FactoryGirl.create :user)}

    uploaded_data  do
      f = "#{Rails.root}/app/assets/images/icons/eye.png"
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                             :tempfile=> File.new(f, "r"),
                                             :filename=> File.basename(f))
    end

    view {FactoryHelper.rand_bool 1/10.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/10.0}
    manage {edit and FactoryHelper.rand_bool}
  end

end
