module UserModules
  module Dropbox
    extend ActiveSupport::Concern

    # returns the path as string or false if it doesn't exist
    def dropbox_dir 
      _dropbox_dir = dropbox_dir_path
      File.directory?(_dropbox_dir) and _dropbox_dir
    end

    # returns the path as string, even if it doesn't exist
    def dropbox_dir_path
      File.join(Settings.dropbox.root_dir, dropbox_dir_name)
    end

    def dropbox_files 
      if dd = dropbox_dir
        Dir.glob(File.join(dd, '**', '*')).
          select {|x| not File.directory?(x) }.
          map {|f| {:dirname=> File.dirname(f).gsub(dd, ''),
                    :filename=> File.basename(f),
                    :size => File.size(f) }}
      end
    end

    def dropbox_dir_name
      if persisted?
        sha = Digest::SHA1.hexdigest("#{id}#{created_at}")
        "#{id}_#{sha}"    
      else
        raise "The user record has to be persisted."
      end
    end


  end
end

