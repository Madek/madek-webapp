class AppAdmin::BaseController < ApplicationController
  before_filter :authenticate_admin_user!
  layout 'app_admin'

end
