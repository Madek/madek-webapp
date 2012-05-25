# -*- encoding : utf-8 -*-
require "metahelper"

class Admin::MetaController < Admin::AdminController

  def import
    @buffer = []
    if request.post? and params[:uploaded_data]
      @buffer = MetaHelper.import_initial_metadata params[:uploaded_data]
    end
  end

  def export
    send_data DevelopmentHelpers::MetaDataPreset.create_hash.to_yaml, :filename => "meta.yml", :type => :yaml
  end

end
