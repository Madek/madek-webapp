# -*- encoding : utf-8 -*-
class Admin::SetupController < ActionController::Base
  protect_from_forgery

  #before_filter do
  # TODO reject if already setup
  #end

  def show
    methods = [:image_magick, :exiftool, :directories, :admin_user,
               :usage_terms, :copyrights, :meta_keys, :meta_contexts,
               :permission_presets, :dropbox, :special_sets]
    @checks = methods.map {|m| send("#{m}_hash") }
  end

  def directories_do
    unless directories?
      system("rake app:setup:make_directories")
    end
    redirect_to admin_setup_path
  end

  def admin_user_do
    unless admin_user?
      if request.post?
        g = Group.find_or_create_by_name("Admin")
        params_user = params[:person].delete(:user)
        params_user.delete(:password_confirmation)
        params_user[:password] = Digest::SHA1.hexdigest(params_user[:password]) 
        p = Person.create(params[:person])
        p.create_user(params_user)
        if p.valid? and p.user.valid?
          g.users << p.user
          redirect_to admin_setup_path
        else
          flash[:error]
        end
      else
        @person = Person.new
        @person.build_user
      end
    else
      redirect_to admin_setup_path
    end 
  end

  def copyrights_do
    unless copyrights?
      file = "#{Rails.root}/config/definitions/helpers/copyrights_switzerland.yml"
      entries = YAML.load_file(file)
      Copyright.save_as_nested_set(entries)
    end
    redirect_to admin_setup_path
  end
  
  def meta_keys_do
    unless meta_keys?
      DevelopmentHelpers::MetaDataPreset.load_minimal_yaml
    end
    redirect_to admin_setup_path
  end

  def meta_contexts_do
    unless meta_contexts?
      required_contexts.each do |x|
        MetaContext.create(name: x, label: x.humanize) unless MetaContext.exists?(name: x)
      end
    end
    redirect_to admin_setup_path
  end

########################################################
  private
  
  def image_magick?
    system("which convert") and system("convert --version")
  end

  def image_magick_hash
    {
      valid: image_magick?,
      title: "ImageMagick",
      success: "ImageMagick is present",
      failure: "ImageMagick is not present"
    }
  end

##########

  def exiftool?
    system("which exiftool") and system("exiftool -ver")
  end

  def exiftool_hash
    {
      valid: exiftool?,
      title: "ExifTool",
      success: "ExifTool is present",
      failure: "ExifTool is not present"
    }
  end

##########

  def directories?
    a = [DOWNLOAD_STORAGE_DIR, ZIP_STORAGE_DIR].all? do |dir|
      File.exist?(dir)
    end

    b = [FILE_STORAGE_DIR, THUMBNAIL_STORAGE_DIR].all? do |dir|
      File.exist?(dir) and [ '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' ].all? do |h|
        File.exist?(File.join(dir, h))
      end 
    end
    
     a and b
  end
  
  def directories_hash
    {
      valid: directories?,
      title: "Directories",
      success: "Success",
      failure: "Failure: <a href='/admin/setup/directories_do'>Create missing directories (existing ones will not be deleted)</a>"
    }
  end

##########
  
  def admin_user?
    (g = Group.find_by_name("Admin")) and not g.users.empty?
  end
  
  def admin_user_hash
    b = admin_user?
    {
      valid: b,
      title: "Admin user",
      success: b ? "Admin users: %s" % Group.find_by_name("Admin").users.map(&:login).join(', ') : "",
      failure: "Failure: <a href='/admin/setup/admin_user_do'>Create an admin user</a>"
    }
  end

##########

  def usage_terms?
    UsageTerm.exists? and not UsageTerm.current.intro.blank? and not UsageTerm.current.body.blank?
  end
  
  def usage_terms_hash
    {
      valid: usage_terms?,
      title: "UsageTerm",
      success: "Success (the UsageTerm is present)",
      failure: "Failure: <a href='/admin/usage_term'>create or edit on admin interface</a>"
    }
  end

##########

  def copyrights?
    Copyright.exists? # TODO and meta_keys with type
  end
  
  def copyrights_hash
    {
      valid: copyrights?,
      title: "Copyrights",
      success: "Success (some Copyrights exist)",
      failure: "Failure: <a href='/admin/copyrights'>create on admin interface</a> or <a href='/admin/setup/copyrights_do'>use default (Switzerland)</a>"
    }
  end

##########

  def meta_keys?
    MetaKey.exists?
  end
  
  def meta_keys_hash
    {
      valid: meta_keys?,
      title: "MetaKeys",
      success: "Success (some MetaKeys exist)",
      failure: "Failure: <a href='/admin/keys'>create on admin interface</a> or <a href='/admin/setup/meta_keys_do'>import zhdk preset (too much)</a>"
    }
  end

##########

  def required_contexts
    ["io_interface", "core", "upload", "media_set", "media_content", "media_object", "copyright"]
  end

  def meta_contexts?
    required_contexts.all? do |x|
      MetaContext.exists?(name: x)
    end
  end
  
  def meta_contexts_hash
    {
      valid: meta_contexts?,
      title: "MetaContexts (%s)" % required_contexts.join(', '),
      success: "Success",
      failure: "Failure: <a href='/admin/contexts'>create on admin interface</a> or <a href='/admin/setup/meta_contexts_do'>create missing ones automatically</a>"
    }
  end

##########

  def permission_presets?
    PermissionPreset.exists?
  end
  
  def permission_presets_hash
    {
      valid: permission_presets?,
      title: "Permission Presets",
      success: "Success (some exist)",
      failure: "Failure: <a href='/admin/permission_presets'>create on admin interface</a>"
    }
  end

##########

  def dropbox?
    AppSettings.dropbox_root_dir and File.directory?(AppSettings.dropbox_root_dir)
  end
  
  def dropbox_hash
    {
      valid: dropbox?,
      title: "Dropbox",
      success: "Success",
      failure: "Failure: <a href='/admin/settings/dropbox'>create on admin interface</a>"
    }
  end

##########

  def special_sets?
    AppSettings.featured_set_id and AppSettings.splashscreen_slideshow_set_id
  end
  
  def special_sets_hash
    {
      valid: special_sets?,
      title: "Special Sets",
      success: "Success",
      failure: "Failure: <a href='/admin/media_sets/special'>create on admin interface</a>"
    }
  end

##########

end
        

