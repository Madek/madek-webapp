# -*- encoding : utf-8 -*-
class PermissionPresetsController < ApplicationController

  def index
    @presets = PermissionPreset.all
  end
  
end
