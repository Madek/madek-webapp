class UploadSessionsController < ApplicationController

  def destroy

    @upload_session =  UploadSession.find params[:id]

    if @upload_session.user == current_user
      @upload_session.destroy
    else
      raise "only the owner can destroy a upload_session"
    end

    respond_to do |format|
      format.html{render :text => "JSON only API", :status => 406}
      format.json{render :json => {}}
    end

  end
  
end
