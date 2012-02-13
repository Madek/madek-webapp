# -*- encoding : utf-8 -*-
class UserpermissionsController < ApplicationController

  skip_before_filter :login_required

  def index
    @userpermissions = Userpermission.where("user_id = ?", current_user.id)
  end

  def show
    @userpermission = Userpermission.find params['id']
  end

end


