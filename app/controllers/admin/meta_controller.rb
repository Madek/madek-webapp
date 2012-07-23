# -*- encoding : utf-8 -*-
#
class Admin::MetaController < Admin::AdminController

=begin #old#
  def import
    if request.post? and params[:uploaded_data]
      DevelopmentHelpers::MetaDataPreset.import_hash params[:uploaded_data]
    end
  end
=end

  def export
    send_data DevelopmentHelpers::MetaDataPreset.create_hash.to_yaml, :filename => "meta.yml", :type => :yaml
  end

end
