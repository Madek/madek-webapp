class AppSettings < Settings

  ACCEPTED_VARS = {
    :featured_set_id                => {:type => Integer,   :description => "Set id used for retrieve the FeaturedSet"},
    :splashscreen_slideshow_set_id  => {:type => Integer,   :description => "Set id used for retrieve the Set to display on the splash screen"},
    :dropbox_root_dir               => {:type => String,    :description => "Dropbox root directory path for FTP upload"},
    :ftp_dropbox_server             => {:type => String,    :description => "Dropbox: ftp server name"},
    :ftp_dropbox_user               => {:type => String,    :description => "Dropbox: ftp user name"},
    :ftp_dropbox_password           => {:type => String,    :description => "Dropbox: ftp password"},
    :authentication_systems         => {:type => Array,     :description => "Active authentication systems described as symbols",
                                        :possible_values => [:zhdk_agw, :local_database], :default => [:local_database]},
    :title                          => {:type => String,    :description => "The instance title"}                                        
  }

  def self.method_missing(method, *args)
    method_name = method.to_s
    get_method = if (is_setter = (method_name =~ /=$/))
      method_name.gsub(/=$/, '').to_sym
    else
      method
    end
    
    if not ACCEPTED_VARS.keys.include?(get_method)
      raise SettingNotFound, "Setting variable \"#{get_method}\" not found"
    elsif is_setter and not args.first.is_a?(ACCEPTED_VARS[get_method][:type])
      raise TypeError, "Expected #{ACCEPTED_VARS[get_method][:type]}, received #{args.first.class}"  
    end

    # TODO filter possible_values on setter

    r = super
    (not is_setter and r.blank?) ? ACCEPTED_VARS[method][:default] : r
  end

end
