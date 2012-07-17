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

=begin
  def image_magick
    if image_magick?
      render :text => "TODO"
    else
      render :text => "TODO"
    end
  end
=end

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
  
  def admin_user?
    (g = Group.find_by_name("Admin")) and not g.members.empty?
  end
  
  def admin_user_hash
    {
      valid: admin_user?,
      title: "Admin user",
      success: "An admin user already exists",
      failure: "Create an admin user"
    }
  end

##########

  def directories?
    # TODO include tmp/...
    [FILE_STORAGE_DIR, THUMBNAIL_STORAGE_DIR].all? do |dir|
      File.exist?(dir) and [ '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' ].all? do |h|
        File.exist?(File.join(dir, h))
      end 
    end
  end
  
  def directories_hash
    {
      valid: directories?,
      title: "Directories",
      success: "Success",
      failure: "Failure"
    }
  end

##########

  def usage_terms?
    UsageTerm.exists?
  end
  
  def usage_terms_hash
    {
      valid: usage_terms?,
      title: "UsageTerm",
      success: "Success",
      failure: "Failure"
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
      failure: "Failure"
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
      failure: "Failure"
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
      failure: "Failure"
    }
  end

##########

end
        

