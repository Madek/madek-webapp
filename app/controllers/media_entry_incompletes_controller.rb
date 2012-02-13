class MediaEntryIncompletesController< ApplicationController

  def destroy

    @mei=MediaEntryIncomplete.find params[:id]

    if @mei.user == current_user
      @mei.destroy
    else
      raise "only the owner can destroy a MediaEntryIncomplete"
    end

    respond_to do |format|
      format.html{render :text => "JSON only API", :status => 406}
      format.json{render :json => {}}
    end

  end
  
end
