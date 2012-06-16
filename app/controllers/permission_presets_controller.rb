# -*- encoding : utf-8 -*-
class PermissionPresetsController < ApplicationController

  def index
    presets = PermissionPreset.all
    render :json => view_context.json_for(presets)
  end
  
end
