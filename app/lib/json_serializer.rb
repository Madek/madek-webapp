module JsonSerializer
  class << self

    def load(data)
      begin
        JSON.parse data
      rescue
        {}
      end
    end

    def dump(obj)
      begin
        obj.to_json
      rescue
        "{}"
      end
    end

  end
end
