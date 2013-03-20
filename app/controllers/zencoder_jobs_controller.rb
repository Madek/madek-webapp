class ZencoderJobsController < ActionController::Base

  def post_notification
    begin 
      if  (@job = ZencoderJob.find params[:id]) and (@job.state == 'submitted')
        @job.update_attributes notification: params
        begin 
          if state = params.try(:[],'input').try(:[],'state')
            case state
            when 'finished'
              @job.import_previews #error handling within @job
            when 'failed'
              @job.update_attributes state: 'failed', 
                error: params['outputs'].select{|output| output['state'] == 'failed'} \
                .map{|output| output['error_message']}.join("\n\n")
            else
              @job.update_attributes state: 'failed', error: 'Unknown state in notification.'
            end
          end
        rescue => e
          @job.update_attributes state: 'failed', error: Formatter.error_to_s(e)
        end
      end
    ensure
      # always respond with OK 
      respond_to  do |format|
        format.json{ render json: {}.to_json }
      end
    end
  end

end
