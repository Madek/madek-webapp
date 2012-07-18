# -*- encoding : utf-8 -*-
class Admin::SetupController < ActionController::Base
  protect_from_forgery

  #before_filter do
  # TODO reject if already setup
  #end

  def show
    methods = [:image_magick, :exiftool, :directories, :admin_user,
               :usage_terms, :copyrights, :meta_keys, :meta_mapping]
    @checks = methods.map {|m| send("#{m}_hash") }
  end


  def directories_do
    unless directories?
      # FIXME this should be :make_missing_directories ??
      system("rake madek:make_directories")
    end
    redirect_to admin_setup_path
  end

  def admin_user_do
    redirect_to admin_setup_path if admin_user?
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
    a = [TEMP_STORAGE_DIR, DOWNLOAD_STORAGE_DIR, ZIP_STORAGE_DIR].all? do |dir|
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
      failure: "Failure: <a href='/admin/setup/directories_do'>Create directories</a>"
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
      success: "Success",
      failure: "Failure: <a href='/admin/usage_term'>create or edit</a>"
    }
  end

##########

  def copyrights?
    Copyright.exists?
  end
  
  def copyrights_hash
    {
      valid: copyrights?,
      title: "Copyrights",
      success: "Success",
      failure: "Failure: <a href='/admin/copyrights'>create</a>"
    }
  end

##########

  def meta_keys?
    MetaKey.exists? and MetaContext.exists?
  end
  
  def meta_keys_hash
    {
      valid: meta_keys?,
      title: "MetaKeys and MetaContexts",
      success: "Success",
      failure: "Failure: <a href='/admin/keys'>create</a>"
    }
  end

##########

  def meta_mapping?
    MetaContext.exists?(name: "io_interface")
  end
  
  def meta_mapping_hash
    {
      valid: meta_mapping?,
      title: "File metadata mapping",
      success: "Success",
      failure: "Failure: <a href='/admin/contexts'>create</a>"
    }
  end

##########

end
        

