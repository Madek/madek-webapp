module ActivityStream

  def activity_stream_params
    conf = params.permit(stream: [:from, :range]).fetch(:stream, nil)
    if conf.present?
      begin
        timestamp = conf[:from].to_i
        raise '' unless timestamp
        from = Time.zone.at(timestamp)
      rescue => e
        raise(
          Errors::InvalidParameterValue,
          "'stream[from]' must be a valid unix timestamp! \n\n#{e}")
      end
      begin
        range = conf[:range].to_i
      rescue => e
        raise(
          Errors::InvalidParameterValue,
          "'stream[range]' must be an integer! \n\n#{e}")
      end
    end
    { from: from, range: range, paginated: true } if from
  end

end
