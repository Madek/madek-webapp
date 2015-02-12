class Presenter

  include Rails.application.routes.url_helpers

  def api
    self
      .class
      .ancestors
      .select { |a| a.to_s.match(/^Presenters/) }
      .map { |a| a.instance_methods(false) }
      .flatten
  end

  def dump
    Hash[
      api.map do |api_method|
        result = \
          begin
            send(api_method)
          rescue => e
            "ERROR: #{e.message}"
          end

        [api_method, Presenter.dump_recur(result)]
      end
    ]
  end

  def self.dump_recur(obj)
    if obj.is_a?(Presenter)
      dump(obj)
    elsif obj.is_a?(Array)
      obj.map { |elt| dump_recur(elt) }
    elsif obj.is_a?(Hash)
      obj
        .map { |k, v| [k, dump_recur(v)] }
        .to_h
    elsif obj.class.name.match(/ActiveRecord/)
      "!!!ACTIVE_RECORD!!! <##{obj.class}>"
    else
      obj
    end
  end
end
